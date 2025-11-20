import 'reflect-metadata';
import { AppDataSource } from '../config/database';

async function checkDevelopersFormat() {
  try {
    console.log('🔄 Connecting to database...');
    await AppDataSource.initialize();
    console.log('✅ Database connected\n');

    const queryRunner = AppDataSource.createQueryRunner();
    await queryRunner.connect();

    try {
      // Перевіряємо тип колонки description
      const columnInfo = await queryRunner.query(`
        SELECT column_name, data_type, udt_name
        FROM information_schema.columns
        WHERE table_name = 'developers' AND column_name = 'description'
      `);
      
      console.log('📋 Column info:', columnInfo);
      console.log('');

      // Отримуємо всіх девелоперів (навіть без описів)
      const allDevs = await queryRunner.query(`
        SELECT id, name, 
               pg_typeof(description) as desc_type,
               description,
               LENGTH(COALESCE(description::text, '')) as desc_length
        FROM developers
        ORDER BY name ASC
        LIMIT 20
      `);

      console.log(`📊 Found ${allDevs.length} developers (showing first 20)\n`);
      console.log('='.repeat(80));

      allDevs.forEach((dev: any, index: number) => {
        console.log(`\n${index + 1}. ${dev.name}`);
        console.log(`   Type: ${dev.desc_type}`);
        console.log(`   Length: ${dev.desc_length}`);
        if (dev.description) {
          const descStr = typeof dev.description === 'string' 
            ? dev.description.substring(0, 100) 
            : JSON.stringify(dev.description).substring(0, 100);
          console.log(`   Preview: ${descStr}...`);
        } else {
          console.log(`   Description: NULL`);
        }
      });

      // Підрахунок
      const stats = await queryRunner.query(`
        SELECT 
          COUNT(*) as total,
          COUNT(description) as with_desc,
          COUNT(CASE WHEN description IS NOT NULL AND description::text != '' THEN 1 END) as with_non_empty_desc
        FROM developers
      `);

      console.log('\n' + '='.repeat(80));
      console.log('\n📊 Statistics:');
      console.log(`   Total developers: ${stats[0].total}`);
      console.log(`   With description (not null): ${stats[0].with_desc}`);
      console.log(`   With non-empty description: ${stats[0].with_non_empty_desc}`);

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

checkDevelopersFormat();

