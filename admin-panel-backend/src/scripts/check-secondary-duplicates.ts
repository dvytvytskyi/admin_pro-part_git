import 'reflect-metadata';
import { AppDataSource } from '../config/database';
import { Property, PropertyType } from '../entities/Property';

async function checkSecondaryDuplicates() {
  try {
    await AppDataSource.initialize();
    console.log('✅ Database connected');

    const repo = AppDataSource.getRepository(Property);
    
    // Count total secondary
    const totalSecondary = await repo.count({ where: { propertyType: PropertyType.SECONDARY } });
    console.log(`\n📊 Загальна кількість secondary: ${totalSecondary}`);
    
    // Check for duplicates by name
    const duplicates = await repo
      .createQueryBuilder('p')
      .select('p.name', 'name')
      .addSelect('COUNT(*)::int', 'count')
      .where('p.propertyType = :type', { type: PropertyType.SECONDARY })
      .groupBy('p.name')
      .having('COUNT(*) > 1')
      .getRawMany();
    
    console.log(`🔄 Дублікати по назві: ${duplicates.length}`);
    
    if (duplicates.length > 0) {
      console.log(`\nПриклади дублікатів (перші 20):`);
      duplicates.slice(0, 20).forEach((dup: any) => {
        console.log(`  - "${dup.name}": ${dup.count} разів`);
      });
      
      // Count total duplicates
      const totalDuplicates = duplicates.reduce((sum: number, dup: any) => sum + (dup.count - 1), 0);
      console.log(`\n📉 Загальна кількість дублікатів: ${totalDuplicates}`);
      console.log(`✅ Унікальних secondary properties: ${totalSecondary - totalDuplicates}`);
    } else {
      console.log(`✅ Дублікатів не знайдено`);
    }
    
    // Check by name + coordinates (more accurate)
    const duplicatesByLocation = await repo
      .createQueryBuilder('p')
      .select('p.name', 'name')
      .addSelect('p.latitude', 'latitude')
      .addSelect('p.longitude', 'longitude')
      .addSelect('COUNT(*)::int', 'count')
      .where('p.propertyType = :type', { type: PropertyType.SECONDARY })
      .groupBy('p.name')
      .addGroupBy('p.latitude')
      .addGroupBy('p.longitude')
      .having('COUNT(*) > 1')
      .getRawMany();
    
    console.log(`\n📍 Дублікати по назві + координатах: ${duplicatesByLocation.length}`);
    
    await AppDataSource.destroy();
    console.log('\n✅ Done');
    process.exit(0);
  } catch (error: any) {
    console.error('❌ Error:', error);
    if (AppDataSource.isInitialized) {
      await AppDataSource.destroy();
    }
    process.exit(1);
  }
}

checkSecondaryDuplicates();

