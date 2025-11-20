import 'reflect-metadata';
import { AppDataSource } from '../config/database';
import { Area } from '../entities/Area';

async function showAreaTranslationsExamples() {
  try {
    console.log('🔄 Connecting to database...');
    await AppDataSource.initialize();
    console.log('✅ Database connected\n');

    const queryRunner = AppDataSource.createQueryRunner();
    await queryRunner.connect();

    try {
      // Отримуємо приклади районів з перекладеними описами
      const exampleAreaNames = [
        'Al Barari',
        'Business Bay',
        'Downtown Dubai',
        'Dubai Marina',
        'Palm Jumeirah',
        'Jumeirah Village Circle (JVC)',
      ];

      console.log('📋 Приклади перекладених описів районів:\n');
      console.log('='.repeat(80));

      for (const areaName of exampleAreaNames) {
        const areaRaw = await queryRunner.query(
          `SELECT id, "nameEn", "nameRu", description, infrastructure 
           FROM areas 
           WHERE "nameEn" = $1 
           LIMIT 1`,
          [areaName]
        );

        if (areaRaw.length === 0) {
          console.log(`\n⚠️  Район "${areaName}" не знайдено\n`);
          continue;
        }

        const area = areaRaw[0];

        console.log(`\n🏘️  ${area.nameEn} (${area.nameRu})`);
        console.log('-'.repeat(80));

        if (area.description) {
          const desc = typeof area.description === 'string' 
            ? JSON.parse(area.description) 
            : area.description;

          console.log('\n📝 Description:');
          
          if (desc.en) {
            console.log('\n  🇬🇧 English:');
            console.log(`    Title: ${desc.en.title || 'N/A'}`);
            console.log(`    Text: ${(desc.en.description || '').substring(0, 150)}...`);
          }
          
          if (desc.ru) {
            console.log('\n  🇷🇺 Russian:');
            console.log(`    Заголовок: ${desc.ru.title || 'N/A'}`);
            console.log(`    Текст: ${(desc.ru.description || '').substring(0, 150)}...`);
          }
        } else {
          console.log('\n  ⚠️  Description відсутній');
        }

        if (area.infrastructure) {
          const infra = typeof area.infrastructure === 'string' 
            ? JSON.parse(area.infrastructure) 
            : area.infrastructure;

          if (infra.en && infra.en.description) {
            console.log('\n🏗️  Infrastructure:');
            console.log(`  🇬🇧 EN: ${(infra.en.description || '').substring(0, 100)}...`);
            if (infra.ru && infra.ru.description) {
              console.log(`  🇷🇺 RU: ${(infra.ru.description || '').substring(0, 100)}...`);
            }
          }
        }

        console.log('\n' + '='.repeat(80));
      }

    } finally {
      await queryRunner.release();
    }

    await AppDataSource.destroy();
    console.log('\n✅ Done!');
  } catch (error: any) {
    console.error('❌ Error:', error.message);
    if (error.stack) {
      console.error(error.stack);
    }
    if (AppDataSource.isInitialized) {
      await AppDataSource.destroy();
    }
    process.exit(1);
  }
}

showAreaTranslationsExamples();

