import 'reflect-metadata';
import { AppDataSource } from '../config/database';
import { Property, PropertyType } from '../entities/Property';
import { PropertyUnit } from '../entities/PropertyUnit';
import * as process from 'process';

async function clearOffPlanProperties() {
  try {
    console.log('🔄 Connecting to database...');
    await AppDataSource.initialize();
    console.log('✅ Database connected');

    const propertyRepository = AppDataSource.getRepository(Property);
    const unitRepository = AppDataSource.getRepository(PropertyUnit);

    // Count off-plan properties before deletion
    const countBefore = await propertyRepository.count({
      where: { propertyType: PropertyType.OFF_PLAN }
    });
    console.log(`📊 Found ${countBefore} off-plan properties to delete`);

    if (countBefore === 0) {
      console.log('✅ No off-plan properties to delete');
      await AppDataSource.destroy();
      process.exit(0);
    }

    // Delete all off-plan properties (units will be deleted via CASCADE)
    console.log('🧹 Deleting off-plan properties...');
    const result = await propertyRepository.delete({
      propertyType: PropertyType.OFF_PLAN
    });

    // Verify deletion
    const countAfter = await propertyRepository.count({
      where: { propertyType: PropertyType.OFF_PLAN }
    });

    console.log(`✅ Deleted ${result.affected || 0} off-plan properties`);
    console.log(`📊 Remaining off-plan properties: ${countAfter}`);

    if (countAfter > 0) {
      console.warn('⚠️  Warning: Some off-plan properties were not deleted');
    }

    await AppDataSource.destroy();
    console.log('✅ Done');
    process.exit(0);
  } catch (error: any) {
    console.error('❌ Error clearing off-plan properties:', error);
    if (AppDataSource.isInitialized) {
      await AppDataSource.destroy();
    }
    process.exit(1);
  }
}

clearOffPlanProperties();

