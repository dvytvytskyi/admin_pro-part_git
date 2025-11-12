import { AppDataSource } from '../config/database';
import { Country } from '../entities/Country';
import { City } from '../entities/City';
import { Area } from '../entities/Area';
import * as fs from 'fs';
import * as path from 'path';

const IMPORT_DIR = process.env.IMPORT_DATA_DIR || path.join(__dirname, '../../../exported-offplan-data');

async function fixImport() {
  try {
    await AppDataSource.initialize();
    console.log('✅ Database connected\n');

    // 1. Countries - імпортуємо з перевіркою
    console.log('1️⃣ Імпорт Countries...');
    const countriesData = JSON.parse(fs.readFileSync(path.join(IMPORT_DIR, 'countries.json'), 'utf-8'));
    const countryRepo = AppDataSource.getRepository(Country);
    let countriesCount = 0;
    
    for (const country of countriesData) {
      const existing = await countryRepo.findOne({ where: { code: country.code } });
      if (!existing) {
        await countryRepo.save(country);
        countriesCount++;
      }
    }
    console.log(`   ✅ Countries: ${countriesCount} нових, ${await countryRepo.count()} всього\n`);

    // 2. Cities - імпортуємо з перевіркою countryId
    console.log('2️⃣ Імпорт Cities...');
    const citiesData = JSON.parse(fs.readFileSync(path.join(IMPORT_DIR, 'cities.json'), 'utf-8'));
    const cityRepo = AppDataSource.getRepository(City);
    let citiesCount = 0;
    
    for (const city of citiesData) {
      const country = await countryRepo.findOne({ where: { id: city.countryId } });
      if (country) {
        const existing = await cityRepo.findOne({ where: { id: city.id } });
        if (!existing) {
          await cityRepo.save(city);
          citiesCount++;
        }
      } else {
        console.log(`   ⚠️  City ${city.nameEn} пропущено - countryId ${city.countryId} не знайдено`);
      }
    }
    console.log(`   ✅ Cities: ${citiesCount} нових, ${await cityRepo.count()} всього\n`);

    // 3. Areas - імпортуємо з перевіркою cityId
    console.log('3️⃣ Імпорт Areas...');
    const areasData = JSON.parse(fs.readFileSync(path.join(IMPORT_DIR, 'areas.json'), 'utf-8'));
    const areaRepo = AppDataSource.getRepository(Area);
    let areasCount = 0;
    let skipped = 0;
    
    for (const area of areasData) {
      const city = await cityRepo.findOne({ where: { id: area.cityId } });
      if (city) {
        const existing = await areaRepo.findOne({ where: { id: area.id } });
        if (!existing) {
          await areaRepo.save(area);
          areasCount++;
          if (areasCount % 100 === 0) {
            console.log(`   ... імпортовано ${areasCount} areas`);
          }
        }
      } else {
        skipped++;
      }
    }
    console.log(`   ✅ Areas: ${areasCount} нових, ${skipped} пропущено, ${await areaRepo.count()} всього\n`);

    console.log('✅ Імпорт базових даних завершено!');
    await AppDataSource.destroy();
    process.exit(0);
  } catch (error) {
    console.error('❌ Помилка:', error);
    await AppDataSource.destroy();
    process.exit(1);
  }
}

fixImport();

