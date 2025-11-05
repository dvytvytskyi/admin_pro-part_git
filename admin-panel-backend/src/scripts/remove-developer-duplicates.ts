import 'reflect-metadata';
import { AppDataSource } from '../config/database';
import { Developer } from '../entities/Developer';

async function removeDeveloperDuplicates() {
  try {
    console.log('🔄 Connecting to database...');
    await AppDataSource.initialize();
    console.log('✅ Database connected');

    // Find duplicates by name (case-insensitive)
    const duplicates = await AppDataSource.query(`
      SELECT 
        LOWER(name) as name_lower,
        COUNT(*) as count,
        array_agg(id ORDER BY "createdAt" ASC) as ids,
        array_agg(name ORDER BY "createdAt" ASC) as names,
        array_agg("createdAt" ORDER BY "createdAt" ASC) as created_dates
      FROM developers
      GROUP BY LOWER(name)
      HAVING COUNT(*) > 1
      ORDER BY count DESC
    `);

    if (duplicates.length === 0) {
      console.log('✅ No duplicates found!');
      await AppDataSource.destroy();
      return;
    }

    console.log(`\n⚠️  Found ${duplicates.length} duplicate group(s)\n`);

    let totalDeleted = 0;
    const idsToDelete: string[] = [];

    for (const dup of duplicates) {
      const ids = dup.ids as string[];
      const names = dup.names as string[];
      const createdDates = dup.created_dates as Date[];
      
      // Keep the first (oldest) one, delete the rest
      const toKeep = ids[0];
      const toDelete = ids.slice(1);

      console.log(`📋 "${names[0]}" (${dup.count} duplicates):`);
      console.log(`   ✅ Keeping: ${toKeep} (created: ${createdDates[0]})`);
      
      toDelete.forEach((id, idx) => {
        console.log(`   ❌ Deleting: ${id} (created: ${createdDates[idx + 1]})`);
        idsToDelete.push(id);
      });
      console.log('');

      totalDeleted += toDelete.length;
    }

    if (idsToDelete.length === 0) {
      console.log('✅ No duplicates to delete!');
      await AppDataSource.destroy();
      return;
    }

    console.log(`\n🗑️  Deleting ${idsToDelete.length} duplicate(s)...\n`);

    // Delete duplicates
    const result = await AppDataSource.query(
      `DELETE FROM developers WHERE id = ANY($1::uuid[])`,
      [idsToDelete]
    );

    console.log(`✅ Deleted ${idsToDelete.length} duplicate(s)`);

    // Verify final count
    const finalCount = await AppDataSource.getRepository(Developer).count();
    console.log(`\n📈 Final developer count: ${finalCount}`);

    // Check if there are still duplicates
    const remainingDuplicates = await AppDataSource.query(`
      SELECT 
        LOWER(name) as name_lower,
        COUNT(*) as count
      FROM developers
      GROUP BY LOWER(name)
      HAVING COUNT(*) > 1
    `);

    if (remainingDuplicates.length === 0) {
      console.log('✅ No duplicates remaining!');
    } else {
      console.log(`⚠️  Still ${remainingDuplicates.length} duplicate group(s) remaining`);
    }

    await AppDataSource.destroy();
    console.log('\n✅ Cleanup completed!');
  } catch (error: any) {
    console.error('❌ Error removing duplicates:', error);
    process.exit(1);
  }
}

removeDeveloperDuplicates();

