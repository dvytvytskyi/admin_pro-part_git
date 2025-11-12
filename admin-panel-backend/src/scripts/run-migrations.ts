import { AppDataSource } from '../config/database';

async function runMigrations() {
  try {
    console.log('🔄 Підключення до бази даних...');
    await AppDataSource.initialize();
    console.log('✅ База даних підключена\n');

    console.log('🔄 Запуск міграцій...');
    const migrations = await AppDataSource.runMigrations();
    
    if (migrations.length === 0) {
      console.log('✅ Всі міграції вже виконані');
    } else {
      console.log(`✅ Виконано ${migrations.length} міграцій:`);
      migrations.forEach((migration, index) => {
        console.log(`   ${index + 1}. ${migration.name}`);
      });
    }

    await AppDataSource.destroy();
    console.log('\n✅ Міграції завершено');
    process.exit(0);
  } catch (error: any) {
    console.error('❌ Помилка виконання міграцій:', error);
    if (AppDataSource.isInitialized) {
      await AppDataSource.destroy();
    }
    process.exit(1);
  }
}

runMigrations();

