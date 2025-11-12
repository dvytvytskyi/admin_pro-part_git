import { AppDataSource } from '../config/database';
import { Country } from '../entities/Country';
import { City } from '../entities/City';
import { Area } from '../entities/Area';
import { Developer } from '../entities/Developer';
import { Facility } from '../entities/Facility';
import { Property, PropertyType } from '../entities/Property';
import { PropertyUnit } from '../entities/PropertyUnit';
import * as fs from 'fs';
import * as path from 'path';

// Шлях до експортованих даних (можна змінити через змінну середовища)
const IMPORT_DIR = process.env.IMPORT_DATA_DIR || path.join(__dirname, '../../../exported-offplan-data');

interface ImportResult {
  success: boolean;
  count: number;
  errors: string[];
}

async function importExportedData() {
  const results: Record<string, ImportResult> = {};
  
  try {
    console.log('🔄 Підключення до бази даних...');
    await AppDataSource.initialize();
    console.log('✅ База даних підключена\n');

    // Перевірити, чи існує директорія з даними
    if (!fs.existsSync(IMPORT_DIR)) {
      throw new Error(`Директорія з даними не знайдена: ${IMPORT_DIR}\nВстановіть змінну IMPORT_DATA_DIR або скопіюйте exported-offplan-data в корінь проекту`);
    }

    console.log(`📁 Імпорт даних з: ${IMPORT_DIR}\n`);

    // Порядок імпорту важливий через залежності!
    
    // 1. Countries - пропускаємо існуючі
    console.log('1️⃣ Імпорт Countries...');
    try {
      const countriesData = JSON.parse(fs.readFileSync(path.join(IMPORT_DIR, 'countries.json'), 'utf-8'));
      if (!Array.isArray(countriesData) || countriesData.length === 0) {
        console.log('   ⚠️  Countries: файл порожній або невалідний');
        results.countries = { success: false, count: 0, errors: ['Файл порожній'] };
      } else {
        const countryRepo = AppDataSource.getRepository(Country);
        let imported = 0;
        for (const country of countriesData) {
          const existing = await countryRepo.findOne({ where: { code: country.code } });
          if (!existing) {
            await countryRepo.save(country);
            imported++;
          }
        }
        results.countries = { success: true, count: imported, errors: [] };
        console.log(`   ✅ Countries: ${imported} нових, ${await countryRepo.count()} всього`);
      }
    } catch (error: any) {
      console.error(`   ❌ Помилка імпорту Countries: ${error.message}`);
      results.countries = { success: false, count: 0, errors: [error.message] };
    }

    // 2. Cities - пропускаємо існуючі та перевіряємо foreign keys
    console.log('2️⃣ Імпорт Cities...');
    try {
      const citiesData = JSON.parse(fs.readFileSync(path.join(IMPORT_DIR, 'cities.json'), 'utf-8'));
      if (!Array.isArray(citiesData) || citiesData.length === 0) {
        console.log('   ⚠️  Cities: файл порожній або невалідний');
        results.cities = { success: false, count: 0, errors: ['Файл порожній'] };
      } else {
        const cityRepo = AppDataSource.getRepository(City);
        const countryRepo = AppDataSource.getRepository(Country);
        let imported = 0;
        let skipped = 0;
        let updated = 0;
        for (const city of citiesData) {
          // Спочатку шукаємо за nameEn та countryId
          const country = await countryRepo.findOne({ where: { code: 'AE' } }); // UAE
          if (country) {
            const existing = await cityRepo.findOne({ 
              where: { nameEn: city.nameEn, countryId: country.id } 
            });
            if (existing) {
              // Оновлюємо ID в areas, якщо потрібно
              updated++;
            } else {
              // Створюємо новий city з правильним countryId
              const newCity = {
                ...city,
                countryId: country.id,
              };
              await cityRepo.save(newCity);
              imported++;
            }
          } else {
            skipped++;
          }
        }
        results.cities = { success: true, count: imported, errors: [] };
        console.log(`   ✅ Cities: ${imported} нових, ${skipped} пропущено (немає country), ${await cityRepo.count()} всього`);
      }
    } catch (error: any) {
      console.error(`   ❌ Помилка імпорту Cities: ${error.message}`);
      results.cities = { success: false, count: 0, errors: [error.message] };
    }

    // 3. Areas - пропускаємо існуючі та перевіряємо foreign keys
    console.log('3️⃣ Імпорт Areas...');
    try {
      const areasData = JSON.parse(fs.readFileSync(path.join(IMPORT_DIR, 'areas.json'), 'utf-8'));
      if (!Array.isArray(areasData) || areasData.length === 0) {
        console.log('   ⚠️  Areas: файл порожній або невалідний');
        results.areas = { success: false, count: 0, errors: ['Файл порожній'] };
      } else {
        const areaRepo = AppDataSource.getRepository(Area);
        const cityRepo = AppDataSource.getRepository(City);
        let imported = 0;
        let skipped = 0;
        
        // Створюємо маппінг старих cityId на нові
        const cityMapping: Record<string, string> = {};
        const citiesInFile = JSON.parse(fs.readFileSync(path.join(IMPORT_DIR, 'cities.json'), 'utf-8'));
        for (const cityFile of citiesInFile) {
          const cityInDb = await cityRepo.findOne({ 
            where: { nameEn: cityFile.nameEn },
            relations: ['country']
          });
          if (cityInDb && cityInDb.country?.code === 'AE') {
            cityMapping[cityFile.id] = cityInDb.id;
          }
        }
        
        for (const area of areasData) {
          // Спочатку шукаємо за старим cityId через маппінг
          const newCityId = cityMapping[area.cityId] || area.cityId;
          const city = await cityRepo.findOne({ where: { id: newCityId } });
          if (city) {
            const existing = await areaRepo.findOne({ where: { id: area.id } });
            if (!existing) {
              const areaToSave = {
                ...area,
                cityId: city.id,
              };
              await areaRepo.save(areaToSave);
              imported++;
              if (imported % 100 === 0) {
                console.log(`   ⏳ Прогрес: ${imported} areas імпортовано...`);
              }
            }
          } else {
            skipped++;
          }
        }
        results.areas = { success: true, count: imported, errors: [] };
        console.log(`   ✅ Areas: ${imported} нових, ${skipped} пропущено (немає city), ${await areaRepo.count()} всього`);
      }
    } catch (error: any) {
      console.error(`   ❌ Помилка імпорту Areas: ${error.message}`);
      results.areas = { success: false, count: 0, errors: [error.message] };
    }

    // 4. Developers
    console.log('4️⃣ Імпорт Developers...');
    try {
      const developersData = JSON.parse(fs.readFileSync(path.join(IMPORT_DIR, 'developers.json'), 'utf-8'));
      if (!Array.isArray(developersData) || developersData.length === 0) {
        console.log('   ⚠️  Developers: файл порожній або невалідний');
        results.developers = { success: false, count: 0, errors: ['Файл порожній'] };
      } else {
        const developerRepo = AppDataSource.getRepository(Developer);
        await developerRepo.save(developersData, { chunk: 100 });
        results.developers = { success: true, count: developersData.length, errors: [] };
        console.log(`   ✅ Імпортовано ${developersData.length} developers`);
      }
    } catch (error: any) {
      console.error(`   ❌ Помилка імпорту Developers: ${error.message}`);
      results.developers = { success: false, count: 0, errors: [error.message] };
    }

    // 5. Facilities
    console.log('5️⃣ Імпорт Facilities...');
    try {
      const facilitiesData = JSON.parse(fs.readFileSync(path.join(IMPORT_DIR, 'facilities.json'), 'utf-8'));
      if (!Array.isArray(facilitiesData) || facilitiesData.length === 0) {
        console.log('   ⚠️  Facilities: файл порожній або невалідний');
        results.facilities = { success: false, count: 0, errors: ['Файл порожній'] };
      } else {
        const facilityRepo = AppDataSource.getRepository(Facility);
        await facilityRepo.save(facilitiesData, { chunk: 100 });
        results.facilities = { success: true, count: facilitiesData.length, errors: [] };
        console.log(`   ✅ Імпортовано ${facilitiesData.length} facilities`);
      }
    } catch (error: any) {
      console.error(`   ❌ Помилка імпорту Facilities: ${error.message}`);
      results.facilities = { success: false, count: 0, errors: [error.message] };
    }

    // 6. Properties (off-plan)
    console.log('6️⃣ Імпорт Properties (off-plan)...');
    try {
      const propertiesData = JSON.parse(fs.readFileSync(path.join(IMPORT_DIR, 'properties-offplan.json'), 'utf-8'));
      if (!Array.isArray(propertiesData) || propertiesData.length === 0) {
        console.log('   ⚠️  Properties: файл порожній або невалідний');
        results.properties = { success: false, count: 0, errors: ['Файл порожній'] };
      } else {
        console.log(`   📊 Завантажено ${propertiesData.length} properties з файлу`);
        const propertyRepo = AppDataSource.getRepository(Property);
        
        let successCount = 0;
        let errorCount = 0;
        const errors: string[] = [];
        
        // Створюємо маппінг countries
        const countryRepo = AppDataSource.getRepository(Country);
        const countriesInFile = JSON.parse(fs.readFileSync(path.join(IMPORT_DIR, 'countries.json'), 'utf-8'));
        const countryMapping: Record<string, string> = {};
        for (const countryFile of countriesInFile) {
          const countryInDb = await countryRepo.findOne({ where: { code: countryFile.code } });
          if (countryInDb) {
            countryMapping[countryFile.id] = countryInDb.id;
          }
        }
        console.log(`   📋 Створено маппінг для ${Object.keys(countryMapping).length} countries`);
        
        // Створюємо маппінг cities
        const cityRepo = AppDataSource.getRepository(City);
        const citiesInFile = JSON.parse(fs.readFileSync(path.join(IMPORT_DIR, 'cities.json'), 'utf-8'));
        const cityMapping: Record<string, string> = {};
        for (const cityFile of citiesInFile) {
          const cityInDb = await cityRepo.findOne({ 
            where: { nameEn: cityFile.nameEn },
            relations: ['country']
          });
          if (cityInDb && cityInDb.country?.code === 'AE') {
            cityMapping[cityFile.id] = cityInDb.id;
          }
        }
        console.log(`   📋 Створено маппінг для ${Object.keys(cityMapping).length} cities`);
        
        // Створюємо маппінг areas (старі ID -> нові ID)
        const areaRepo = AppDataSource.getRepository(Area);
        const areasInFile = JSON.parse(fs.readFileSync(path.join(IMPORT_DIR, 'areas.json'), 'utf-8'));
        const areaMapping: Record<string, string> = {};
        for (const areaFile of areasInFile) {
          const areaInDb = await areaRepo.findOne({ where: { id: areaFile.id } });
          if (areaInDb) {
            areaMapping[areaFile.id] = areaInDb.id;
          }
        }
        console.log(`   📋 Створено маппінг для ${Object.keys(areaMapping).length} areas`);
        
        // Імпортуємо по частинах для кращого контролю
        const chunkSize = 50;
        for (let i = 0; i < propertiesData.length; i += chunkSize) {
          const chunk = propertiesData.slice(i, i + chunkSize);
          
          for (const p of chunk) {
            try {
              // Перевіряємо та оновлюємо areaId через маппінг
              let areaId = p.areaId;
              if (areaId && areaMapping[areaId]) {
                areaId = areaMapping[areaId];
              }
              
              if (areaId) {
                const area = await areaRepo.findOne({ where: { id: areaId } });
                if (!area) {
                  errorCount++;
                  const errorMsg = `ID ${p.id || 'unknown'}: areaId ${areaId} не знайдено`;
                  errors.push(errorMsg);
                  if (errorCount <= 10) {
                    console.error(`   ⚠️  Помилка: ${errorMsg}`);
                  }
                  continue;
                }
              }
              
              // Оновлюємо countryId через маппінг
              let countryId = p.countryId;
              if (countryId && countryMapping[countryId]) {
                countryId = countryMapping[countryId];
              }
              
              // Перевіряємо countryId
              if (countryId) {
                const country = await countryRepo.findOne({ where: { id: countryId } });
                if (!country) {
                  errorCount++;
                  const errorMsg = `ID ${p.id || 'unknown'}: countryId ${countryId} не знайдено`;
                  errors.push(errorMsg);
                  if (errorCount <= 10) {
                    console.error(`   ⚠️  Помилка: ${errorMsg}`);
                  }
                  continue;
                }
              }
              
              // Оновлюємо cityId через маппінг
              let cityId = p.cityId;
              if (cityId && cityMapping[cityId]) {
                cityId = cityMapping[cityId];
              }
              
              // Перевіряємо cityId
              if (cityId) {
                const city = await cityRepo.findOne({ where: { id: cityId } });
                if (!city) {
                  errorCount++;
                  const errorMsg = `ID ${p.id || 'unknown'}: cityId ${cityId} не знайдено`;
                  errors.push(errorMsg);
                  if (errorCount <= 10) {
                    console.error(`   ⚠️  Помилка: ${errorMsg}`);
                  }
                  continue;
                }
              }
              
              // Переконатися, що propertyType = 'off-plan'
              const propertyData = {
                ...p,
                propertyType: PropertyType.OFF_PLAN,
                areaId: areaId || p.areaId,
                countryId: countryId || p.countryId,
                cityId: cityId || p.cityId,
              };
              
              // Використовуємо save для кожного запису окремо, щоб відстежити помилки
              await propertyRepo.save(propertyData);
              successCount++;
              
              if ((successCount + errorCount) % 100 === 0) {
                console.log(`   ⏳ Прогрес: ${successCount + errorCount}/${propertiesData.length} (успішно: ${successCount}, помилок: ${errorCount})`);
              }
            } catch (error: any) {
              errorCount++;
              const errorMsg = `ID ${p.id || 'unknown'}: ${error.message}`;
              errors.push(errorMsg);
              
              // Показуємо перші 10 помилок
              if (errorCount <= 10) {
                console.error(`   ⚠️  Помилка імпорту property: ${errorMsg}`);
              }
            }
          }
        }
        
        if (errorCount > 10) {
          console.log(`   ⚠️  ... та ще ${errorCount - 10} помилок (всього: ${errorCount})`);
        }
        
        results.properties = { 
          success: successCount > 0, 
          count: successCount, 
          errors: errors.slice(0, 20) // Зберігаємо тільки перші 20 помилок
        };
        console.log(`   ✅ Імпортовано ${successCount}/${propertiesData.length} properties (off-plan)`);
        if (errorCount > 0) {
          console.log(`   ⚠️  Помилок: ${errorCount}`);
        }
      }
    } catch (error: any) {
      console.error(`   ❌ Помилка імпорту Properties: ${error.message}`);
      results.properties = { success: false, count: 0, errors: [error.message] };
    }

    // 7. PropertyUnits
    console.log('7️⃣ Імпорт PropertyUnits...');
    try {
      const unitsData = JSON.parse(fs.readFileSync(path.join(IMPORT_DIR, 'property-units-offplan.json'), 'utf-8'));
      if (!Array.isArray(unitsData) || unitsData.length === 0) {
        console.log('   ⚠️  PropertyUnits: файл порожній або невалідний');
        results.units = { success: false, count: 0, errors: ['Файл порожній'] };
      } else {
        const unitRepo = AppDataSource.getRepository(PropertyUnit);
        await unitRepo.save(unitsData, { chunk: 100 });
        results.units = { success: true, count: unitsData.length, errors: [] };
        console.log(`   ✅ Імпортовано ${unitsData.length} property units`);
      }
    } catch (error: any) {
      console.error(`   ❌ Помилка імпорту PropertyUnits: ${error.message}`);
      results.units = { success: false, count: 0, errors: [error.message] };
    }

    // 8. Property-Facility зв'язки (через raw SQL)
    console.log('8️⃣ Імпорт Property-Facility зв\'язків...');
    try {
      const linksFile = path.join(IMPORT_DIR, 'properties-facilities-offplan.json');
      if (fs.existsSync(linksFile)) {
        const linksData = JSON.parse(fs.readFileSync(linksFile, 'utf-8'));
        if (Array.isArray(linksData) && linksData.length > 0) {
          // Спробувати різні назви таблиць
          const tableNames = [
            'properties_facilities_facilities',
            'properties_facilities',
            'property_facilities',
          ];
          
          let inserted = 0;
          for (const tableName of tableNames) {
            try {
              for (const link of linksData) {
                await AppDataSource.query(
                  `INSERT INTO ${tableName} ("propertiesId", "facilitiesId") 
                   VALUES ($1, $2) 
                   ON CONFLICT DO NOTHING`,
                  [link.propertiesId, link.facilitiesId]
                );
                inserted++;
              }
              console.log(`   ✅ Імпортовано ${inserted} property-facility зв\'язків`);
              results.facilityLinks = { success: true, count: inserted, errors: [] };
              break;
            } catch (tableError: any) {
              // Спробувати наступну назву таблиці
              continue;
            }
          }
          
          if (inserted === 0) {
            console.log('   ⚠️  Не вдалося знайти правильну назву таблиці для зв\'язків');
            results.facilityLinks = { success: false, count: 0, errors: ['Таблиця не знайдена'] };
          }
        } else {
          console.log('   ⚠️  Немає зв\'язків для імпорту');
          results.facilityLinks = { success: true, count: 0, errors: [] };
        }
      } else {
        console.log('   ⚠️  Файл зі зв\'язками не знайдено (це нормально, якщо зв\'язків немає)');
        results.facilityLinks = { success: true, count: 0, errors: [] };
      }
    } catch (error: any) {
      console.error(`   ⚠️  Помилка імпорту зв'язків (не критично): ${error.message}`);
      results.facilityLinks = { success: false, count: 0, errors: [error.message] };
    }

    // Підсумок
    console.log('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('📊 Підсумок імпорту:');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    
    let totalSuccess = 0;
    let totalFailed = 0;
    
    for (const [key, result] of Object.entries(results)) {
      if (result.success) {
        console.log(`   ✅ ${key}: ${result.count} записів`);
        totalSuccess += result.count;
      } else {
        console.log(`   ❌ ${key}: помилка - ${result.errors.join(', ')}`);
        totalFailed++;
      }
    }
    
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log(`   Загалом імпортовано: ${totalSuccess} записів`);
    if (totalFailed > 0) {
      console.log(`   ⚠️  Помилок: ${totalFailed}`);
    }
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    // Перевірка в БД
    console.log('🔍 Перевірка даних в БД:');
    const propertyRepo = AppDataSource.getRepository(Property);
    const offPlanCount = await propertyRepo.count({ where: { propertyType: PropertyType.OFF_PLAN } });
    const secondaryCount = await propertyRepo.count({ where: { propertyType: PropertyType.SECONDARY } });
    
    console.log(`   Off-plan properties: ${offPlanCount}`);
    console.log(`   Secondary properties: ${secondaryCount}`);
    
    if (secondaryCount > 0) {
      console.log(`   ⚠️  Знайдено ${secondaryCount} secondary properties. Рекомендується видалити їх.`);
    }

    console.log('\n✅ Імпорт завершено!');
    await AppDataSource.destroy();
    process.exit(0);
  } catch (error: any) {
    console.error('\n❌ Критична помилка імпорту:', error);
    if (AppDataSource.isInitialized) {
      await AppDataSource.destroy();
    }
    process.exit(1);
  }
}

// Запуск імпорту
importExportedData();

