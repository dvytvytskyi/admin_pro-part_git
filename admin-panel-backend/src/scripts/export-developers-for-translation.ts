import 'reflect-metadata';
import * as fs from 'fs';
import * as path from 'path';
import { AppDataSource } from '../config/database';
import { Developer } from '../entities/Developer';

async function exportDevelopersForTranslation() {
  try {
    console.log('🔄 Connecting to database...');
    await AppDataSource.initialize();
    console.log('✅ Database connected\n');

    const queryRunner = AppDataSource.createQueryRunner();
    await queryRunner.connect();

    try {
      // Отримуємо всіх девелоперів з описом
      const developersRaw = await queryRunner.query(`
        SELECT id, name, description
        FROM developers
        WHERE description IS NOT NULL
          AND description::text != 'null'
          AND description::text != ''
        ORDER BY name ASC
      `);

      console.log(`📖 Found ${developersRaw.length} developers with descriptions\n`);

      const developersList: Array<{
        name: string;
        descriptionEn: string;
        needsTranslation: boolean;
      }> = [];

      for (const row of developersRaw) {
        let descriptionEn = '';
        let needsTranslation = true;

        if (row.description) {
          let descObj: any = null;
          
          if (typeof row.description === 'string') {
            try {
              descObj = JSON.parse(row.description);
            } catch {
              descObj = { en: { description: row.description }, ru: {} };
            }
          } else if (typeof row.description === 'object') {
            descObj = row.description;
          }

          if (descObj && descObj.en && descObj.en.description) {
            descriptionEn = descObj.en.description;
            // Перевіряємо, чи є вже російський переклад
            if (descObj.ru && descObj.ru.description && descObj.ru.description.trim().length > 0) {
              needsTranslation = false;
            }
          }
        }

        if (descriptionEn) {
          developersList.push({
            name: row.name,
            descriptionEn: descriptionEn.substring(0, 300) + (descriptionEn.length > 300 ? '...' : ''),
            needsTranslation,
          });
        }
      }

      console.log('📊 Summary:');
      console.log(`   Total with descriptions: ${developersList.length}`);
      console.log(`   Already have RU: ${developersList.filter(d => !d.needsTranslation).length}`);
      console.log(`   Need RU translation: ${developersList.filter(d => d.needsTranslation).length}`);
      
      console.log('\n📋 Developers that need translation (first 30):\n');
      developersList
        .filter(d => d.needsTranslation)
        .slice(0, 30)
        .forEach((dev, index) => {
          console.log(`${index + 1}. ${dev.name}`);
          console.log(`   EN: ${dev.descriptionEn.substring(0, 150)}...`);
          console.log('');
        });

      // Зберігаємо список у файл для подальшого використання
      const outputPath = path.join(__dirname, '../../developers-for-translation.json');
      fs.writeFileSync(outputPath, JSON.stringify(developersList, null, 2), 'utf-8');
      console.log(`\n💾 Saved full list to: ${outputPath}`);
      console.log(`   Total: ${developersList.length} developers`);

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

exportDevelopersForTranslation();

