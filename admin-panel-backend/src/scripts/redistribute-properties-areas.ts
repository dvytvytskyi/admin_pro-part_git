import 'reflect-metadata';
import { AppDataSource } from '../config/database';
import { Property } from '../entities/Property';
import { Area } from '../entities/Area';
import { City } from '../entities/City';
import { Country } from '../entities/Country';

/**
 * Скрипт для розподілу об'єктів нерухомості між різними areas
 * Створює популярні areas з короткими назвами та розподіляє об'єкти
 */
async function redistributePropertiesAreas() {
  try {
    console.log('🔄 Підключення до БД...');
    await AppDataSource.initialize();
    console.log('✅ Підключено до БД\n');

    const propertyRepo = AppDataSource.getRepository(Property);
    const areaRepo = AppDataSource.getRepository(Area);
    const cityRepo = AppDataSource.getRepository(City);
    const countryRepo = AppDataSource.getRepository(Country);

    // Знаходимо або створюємо UAE та Dubai
    let country = await countryRepo.findOne({ where: { code: 'AE' } });
    if (!country) {
      country = await countryRepo.save({
        nameEn: 'United Arab Emirates',
        nameRu: 'Объединенные Арабские Эмираты',
        nameAr: 'الإمارات العربية المتحدة',
        code: 'AE',
      });
      console.log('✅ Створено країну: UAE');
    }

    let city = await cityRepo.findOne({ where: { nameEn: 'Dubai', countryId: country.id } });
    if (!city) {
      city = await cityRepo.save({
        nameEn: 'Dubai',
        nameRu: 'Дубай',
        nameAr: 'دبي',
        countryId: country.id,
      });
      console.log('✅ Створено місто: Dubai');
    }

    // Популярні areas з короткими назвами
    const popularAreas = [
      { nameEn: 'Downtown', nameRu: 'Даунтаун', nameAr: 'داون تاون' },
      { nameEn: 'Marina', nameRu: 'Марина', nameAr: 'مارينا' },
      { nameEn: 'JBR', nameRu: 'ДжБР', nameAr: 'جيه بي آر' },
      { nameEn: 'Business Bay', nameRu: 'Бізнес Бей', nameAr: 'بيزنس باي' },
      { nameEn: 'Palm Jumeirah', nameRu: 'Пальм Джумейра', nameAr: 'نخلة جميرا' },
      { nameEn: 'JLT', nameRu: 'ДжЛТ', nameAr: 'جيه إل تي' },
      { nameEn: 'Dubai Hills', nameRu: 'Дубай Хіллс', nameAr: 'دبي هيلز' },
      { nameEn: 'Arabian Ranches', nameRu: 'Арабські Ранчо', nameAr: 'المرابع العربية' },
      { nameEn: 'JVC', nameRu: 'ДжВС', nameAr: 'جيه في سي' },
      { nameEn: 'Dubai Silicon Oasis', nameRu: 'Дубай Сілікон Оазис', nameAr: 'دبي سيلكون أواسيس' },
    ];

    console.log('\n📊 Створення/перевірка areas...');
    const areas: Area[] = [];

    for (const areaData of popularAreas) {
      let area = await areaRepo.findOne({
        where: {
          cityId: city.id,
          nameEn: areaData.nameEn,
        },
      });

      if (!area) {
        area = await areaRepo.save({
          cityId: city.id,
          nameEn: areaData.nameEn,
          nameRu: areaData.nameRu,
          nameAr: areaData.nameAr,
        });
        console.log(`✅ Створено area: ${areaData.nameEn}`);
      } else {
        console.log(`⊘ Існує area: ${areaData.nameEn}`);
      }

      areas.push(area);
    }

    // Отримуємо всі об'єкти
    console.log('\n📊 Отримання всіх об\'єктів...');
    const allProperties = await propertyRepo.find({
      select: ['id', 'name', 'areaId'],
    });

    console.log(`   Знайдено об'єктів: ${allProperties.length}`);

    if (allProperties.length === 0) {
      console.log('⚠️  Об\'єктів не знайдено. Завершення.');
      await AppDataSource.destroy();
      return;
    }

    // Розподіляємо об'єкти рівномірно між areas
    console.log('\n🔄 Розподіл об\'єктів між areas...');
    const propertiesPerArea = Math.ceil(allProperties.length / areas.length);

    // Групуємо об'єкти по target areaId для batch оновлення
    const updatesByArea: { [areaId: string]: string[] } = {};
    let skippedCount = 0;

    for (let i = 0; i < allProperties.length; i++) {
      const property = allProperties[i];
      const targetAreaIndex = Math.floor(i / propertiesPerArea) % areas.length;
      const targetArea = areas[targetAreaIndex];

      // Оновлюємо тільки якщо areaId змінився
      if (property.areaId !== targetArea.id) {
        if (!updatesByArea[targetArea.id]) {
          updatesByArea[targetArea.id] = [];
        }
        updatesByArea[targetArea.id].push(property.id);
      } else {
        skippedCount++;
      }
    }

    // Виконуємо batch оновлення через SQL для швидкості
    console.log(`   Буде оновлено: ${allProperties.length - skippedCount} об\'єктів`);
    console.log(`   Пропущено: ${skippedCount} об\'єктів`);
    
    let updatedCount = 0;

    // Використовуємо SQL CASE для оновлення всіх за один запит
    const queryRunner = AppDataSource.createQueryRunner();
    await queryRunner.connect();
    await queryRunner.startTransaction();

    try {
      // Створюємо SQL з CASE для оновлення
      for (const [areaId, propertyIds] of Object.entries(updatesByArea)) {
        if (propertyIds.length === 0) continue;
        
        // Оновлюємо через SQL для швидкості
        const placeholders = propertyIds.map((_, idx) => `$${idx + 1}`).join(', ');
        await queryRunner.query(
          `UPDATE properties SET "areaId" = $1 WHERE id IN (${placeholders})`,
          [areaId, ...propertyIds]
        );
        
        updatedCount += propertyIds.length;
        console.log(`   Оновлено ${updatedCount}/${allProperties.length - skippedCount}...`);
      }

      await queryRunner.commitTransaction();
    } catch (error) {
      await queryRunner.rollbackTransaction();
      throw error;
    } finally {
      await queryRunner.release();
    }

    console.log(`\n✅ Оновлення завершено!`);
    console.log(`   - Оновлено об\'єктів: ${updatedCount}`);
    console.log(`   - Пропущено (вже правильний areaId): ${skippedCount}`);

    // Перевірка результатів
    console.log('\n📊 Перевірка результатів:');
    for (const area of areas) {
      const count = await propertyRepo.count({ where: { areaId: area.id } });
      console.log(`   - ${area.nameEn}: ${count} об\'єктів`);
    }

    // Загальна статистика
    const totalUniqueAreas = await propertyRepo
      .createQueryBuilder('property')
      .select('COUNT(DISTINCT property.areaId)', 'count')
      .getRawOne();

    console.log(`\n📈 Загальна статистика:`);
    console.log(`   - Всього об\'єктів: ${allProperties.length}`);
    console.log(`   - Унікальних areaId: ${totalUniqueAreas.count}`);

    await AppDataSource.destroy();
    console.log('\n✅ Готово!');
  } catch (error: any) {
    console.error('❌ Помилка:', error);
    if (AppDataSource.isInitialized) {
      await AppDataSource.destroy();
    }
    process.exit(1);
  }
}

// Запуск скрипта
redistributePropertiesAreas();

