import { AppDataSource } from '../config/database';
import { Property, PropertyType } from '../entities/Property';

async function clearOffPlanProperties() {
  try {
    console.log('🔄 Підключення до бази даних...');
    await AppDataSource.initialize();
    console.log('✅ База даних підключена\n');

    const propertyRepo = AppDataSource.getRepository(Property);
    
    // Підрахунок перед видаленням
    const count = await propertyRepo.count({ where: { propertyType: PropertyType.OFF_PLAN } });
    console.log(`📊 Знайдено ${count} off-plan properties для видалення`);
    
    if (count === 0) {
      console.log('✅ Немає off-plan properties для видалення');
      await AppDataSource.destroy();
      process.exit(0);
    }
    
    // Видалити всі off-plan properties
    const result = await propertyRepo.delete({ propertyType: PropertyType.OFF_PLAN });
    console.log(`✅ Видалено ${result.affected || 0} off-plan properties`);
    
    // Перевірка
    const remainingCount = await propertyRepo.count({ where: { propertyType: PropertyType.OFF_PLAN } });
    console.log(`🔍 Залишилося off-plan properties: ${remainingCount}`);
    
    await AppDataSource.destroy();
    console.log('\n✅ Готово!');
    process.exit(0);
  } catch (error: any) {
    console.error('\n❌ Помилка:', error);
    if (AppDataSource.isInitialized) {
      await AppDataSource.destroy();
    }
    process.exit(1);
  }
}

clearOffPlanProperties();
