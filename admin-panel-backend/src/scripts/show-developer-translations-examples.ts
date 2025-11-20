import 'reflect-metadata';
import { AppDataSource } from '../config/database';
import { Developer } from '../entities/Developer';

async function showDeveloperTranslationsExamples() {
  try {
    console.log('🔄 Connecting to database...');
    await AppDataSource.initialize();
    console.log('✅ Database connected\n');

    const queryRunner = AppDataSource.createQueryRunner();
    await queryRunner.connect();

    try {
      // Отримуємо приклади девелоперів з перекладеними описами
      const exampleDeveloperNames = [
        'Emaar Properties',
        'Damac Properties',
        'Nakheel',
        'Sobha Realty',
      ];

      console.log('📋 Приклади перекладених описів девелоперів:\n');
      console.log('='.repeat(80));

      for (const devName of exampleDeveloperNames) {
        const devRaw = await queryRunner.query(
          `SELECT id, name, description 
           FROM developers 
           WHERE name = $1 
           LIMIT 1`,
          [devName]
        );

        if (devRaw.length === 0) {
          console.log(`\n⚠️  Девелопер "${devName}" не знайдено\n`);
          continue;
        }

        const dev = devRaw[0];

        console.log(`\n🏢 ${dev.name}`);
        console.log('-'.repeat(80));

        if (dev.description) {
          let descObj: any = null;
          if (typeof dev.description === 'string') {
            try {
              descObj = JSON.parse(dev.description);
            } catch {
              descObj = { en: { description: dev.description }, ru: {} };
            }
          } else if (typeof dev.description === 'object') {
            descObj = dev.description;
          }

          console.log('\n📝 Description:');
          
          if (descObj && descObj.en && descObj.en.description) {
            console.log('\n  🇬🇧 English:');
            console.log(`    ${(descObj.en.description || '').substring(0, 200)}...`);
          }
          
          if (descObj && descObj.ru && descObj.ru.description) {
            console.log('\n  🇷🇺 Russian:');
            console.log(`    ${(descObj.ru.description || '').substring(0, 200)}...`);
          } else {
            console.log('\n  ⚠️  Russian: відсутній (потрібен переклад)');
          }
        } else {
          console.log('\n  ⚠️  Description відсутній');
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

showDeveloperTranslationsExamples();

