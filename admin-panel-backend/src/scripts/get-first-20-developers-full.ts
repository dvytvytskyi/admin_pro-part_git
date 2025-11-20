import 'reflect-metadata';
import { AppDataSource } from '../config/database';

async function getFirst20DevelopersFull() {
  try {
    console.log('🔄 Connecting to database...');
    await AppDataSource.initialize();
    console.log('✅ Database connected\n');

    const queryRunner = AppDataSource.createQueryRunner();
    await queryRunner.connect();

    try {
      // Отримуємо перші 20 девелоперів з повними описами
      const developersRaw = await queryRunner.query(`
        SELECT id, name, description
        FROM developers
        WHERE description IS NOT NULL
          AND description::text != 'null'
          AND description::text != ''
        ORDER BY name ASC
        LIMIT 20
      `);

      console.log(`📖 Found ${developersRaw.length} developers\n`);
      console.log('='.repeat(80));

      const developers: Array<{ name: string; descriptionEn: string }> = [];

      for (const row of developersRaw) {
        let descriptionEn = '';

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
          }
        }

        if (descriptionEn) {
          developers.push({
            name: row.name.trim(),
            descriptionEn: descriptionEn,
          });

          console.log(`\n${developers.length}. ${row.name.trim()}`);
          console.log(`   EN: ${descriptionEn.substring(0, 150)}${descriptionEn.length > 150 ? '...' : ''}`);
        }
      }

      console.log('\n' + '='.repeat(80));
      console.log(`\n📊 Total: ${developers.length} developers with full descriptions`);

      // Виводимо JSON для копіювання
      console.log('\n📋 JSON for copy:\n');
      console.log(JSON.stringify(developers, null, 2));

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

getFirst20DevelopersFull();

