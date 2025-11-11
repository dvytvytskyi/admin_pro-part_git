import 'reflect-metadata';
import { AppDataSource } from '../config/database';
import { Property, PropertyType } from '../entities/Property';

async function removeSecondaryDuplicates() {
  try {
    await AppDataSource.initialize();
    console.log('✅ Database connected');

    const repo = AppDataSource.getRepository(Property);
    
    // Count before
    const totalBefore = await repo.count({ where: { propertyType: PropertyType.SECONDARY } });
    console.log(`\n📊 Secondary properties ДО очищення: ${totalBefore}`);
    
    // Find duplicates by name, latitude, longitude
    // Keep the one with the latest createdAt
    console.log('\n🔍 Знаходження дублікатів...');
    
    const duplicates = await AppDataSource.query(`
      WITH ranked_properties AS (
        SELECT 
          id,
          name,
          latitude,
          longitude,
          "createdAt",
          ROW_NUMBER() OVER (
            PARTITION BY name, latitude, longitude 
            ORDER BY "createdAt" DESC
          ) as rn
        FROM properties
        WHERE "propertyType" = 'secondary'
      )
      SELECT id
      FROM ranked_properties
      WHERE rn > 1
    `);
    
    const duplicateIds = duplicates.map((row: any) => row.id);
    console.log(`🔄 Знайдено ${duplicateIds.length} дублікатів для видалення`);
    
    if (duplicateIds.length === 0) {
      console.log('✅ Дублікатів не знайдено');
      await AppDataSource.destroy();
      process.exit(0);
    }
    
    // Ask for confirmation
    console.log(`\n⚠️  УВАГА: Буде видалено ${duplicateIds.length} дублікатів!`);
    console.log(`   Залишиться: ${totalBefore - duplicateIds.length} унікальних secondary properties`);
    
    // Delete duplicates in batches
    const BATCH_SIZE = 1000;
    let deletedCount = 0;
    
    console.log('\n🧹 Видалення дублікатів...');
    for (let i = 0; i < duplicateIds.length; i += BATCH_SIZE) {
      const batch = duplicateIds.slice(i, i + BATCH_SIZE);
      const result = await repo.delete(batch);
      deletedCount += result.affected || 0;
      
      const progress = ((i + batch.length) / duplicateIds.length) * 100;
      process.stdout.write(`\r   Прогрес: ${Math.floor(progress)}% (${i + batch.length}/${duplicateIds.length})`);
    }
    
    console.log('\n');
    
    // Count after
    const totalAfter = await repo.count({ where: { propertyType: PropertyType.SECONDARY } });
    
    console.log('\n📊 Результати:');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log(`📦 ДО очищення: ${totalBefore}`);
    console.log(`🗑️  Видалено: ${deletedCount}`);
    console.log(`✅ Після очищення: ${totalAfter}`);
    console.log(`📉 Різниця: ${totalBefore - totalAfter}`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    
    await AppDataSource.destroy();
    console.log('✅ Done');
    process.exit(0);
  } catch (error: any) {
    console.error('❌ Error:', error);
    if (AppDataSource.isInitialized) {
      await AppDataSource.destroy();
    }
    process.exit(1);
  }
}

removeSecondaryDuplicates();

