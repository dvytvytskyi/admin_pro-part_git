import 'reflect-metadata';
import { AppDataSource } from '../config/database';
import { Developer } from '../entities/Developer';

async function listDevelopersWithDescriptions() {
  try {
    console.log('🔄 Connecting to database...');
    await AppDataSource.initialize();
    console.log('✅ Database connected\n');

    const queryRunner = AppDataSource.createQueryRunner();
    await queryRunner.connect();

    try {
      // Отримуємо всіх девелоперів з описами
      // Використовуємо CAST для безпечної конвертації
      const developersRaw = await queryRunner.query(`
        SELECT id, name, 
               CASE 
                 WHEN description IS NULL THEN NULL
                 WHEN pg_typeof(description) = 'text'::regtype THEN description::text
                 ELSE description::text
               END as description
        FROM developers
        WHERE description IS NOT NULL 
          AND (description::text != '' AND description::text != 'null' AND description::text IS NOT NULL)
        ORDER BY name ASC
      `);

      console.log(`📖 Found ${developersRaw.length} developers with descriptions\n`);
      console.log('='.repeat(80));
      console.log('📋 Developers list for translation:\n');

      developersRaw.forEach((dev: any, index: number) => {
        let description = '';
        if (typeof dev.description === 'string') {
          description = dev.description.substring(0, 150) + (dev.description.length > 150 ? '...' : '');
        } else if (dev.description && typeof dev.description === 'object') {
          if (dev.description.en && dev.description.en.description) {
            description = dev.description.en.description.substring(0, 150) + 
                         (dev.description.en.description.length > 150 ? '...' : '');
          } else if (dev.description.description) {
            description = dev.description.description.substring(0, 150) + 
                         (dev.description.description.length > 150 ? '...' : '');
          }
        }

        console.log(`${index + 1}. ${dev.name}`);
        console.log(`   Description: ${description || 'N/A'}`);
        console.log('');
      });

      console.log('='.repeat(80));
      console.log(`\n📊 Total: ${developersRaw.length} developers with descriptions`);

      // Виводимо список імен для копіювання
      console.log('\n📋 Developer names list:');
      developersRaw.forEach((dev: any, index: number) => {
        console.log(`  '${dev.name}',`);
      });

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

listDevelopersWithDescriptions();

