import 'reflect-metadata';
import { AppDataSource } from '../config/database';
import { Developer } from '../entities/Developer';
import * as fs from 'fs';

async function checkDeveloperDuplicates() {
  try {
    console.log('🔄 Connecting to database...');
    await AppDataSource.initialize();
    console.log('✅ Database connected');

    const developerRepository = AppDataSource.getRepository(Developer);

    // Load all developers
    const allDevelopers = await developerRepository.find();
    console.log(`📊 Total developers in database: ${allDevelopers.length}\n`);

    // Check for duplicates by name (case-insensitive)
    const nameMap = new Map<string, Developer[]>();
    
    allDevelopers.forEach(dev => {
      const key = dev.name.toLowerCase().trim();
      if (!nameMap.has(key)) {
        nameMap.set(key, []);
      }
      nameMap.get(key)!.push(dev);
    });

    // Find duplicates
    const duplicates: Array<{ name: string; count: number; developers: Developer[] }> = [];
    
    nameMap.forEach((developers, name) => {
      if (developers.length > 1) {
        duplicates.push({
          name,
          count: developers.length,
          developers
        });
      }
    });

    if (duplicates.length === 0) {
      console.log('✅ No duplicates found! All developers have unique names (case-insensitive).');
    } else {
      console.log(`⚠️  Found ${duplicates.length} duplicate name(s):\n`);
      
      // Sort by count (most duplicates first)
      duplicates.sort((a, b) => b.count - a.count);
      
      duplicates.forEach((dup, index) => {
        console.log(`${index + 1}. "${dup.name}" - ${dup.count} occurrence(s):`);
        dup.developers.forEach((dev, idx) => {
          console.log(`   ${idx + 1}. ID: ${dev.id}`);
          console.log(`      Name: "${dev.name}"`);
          console.log(`      Logo: ${dev.logo || 'N/A'}`);
          console.log(`      Description: ${dev.description ? dev.description.substring(0, 50) + '...' : 'N/A'}`);
          console.log(`      Images: ${dev.images ? dev.images.length : 0} photo(s)`);
          console.log(`      Created: ${dev.createdAt}`);
          console.log('');
        });
        console.log('');
      });

      // Generate summary
      const totalDuplicateCount = duplicates.reduce((sum, dup) => sum + dup.count, 0);
      const uniqueNames = allDevelopers.length - totalDuplicateCount + duplicates.length;
      console.log('\n📊 Summary:');
      console.log(`   Total developers: ${allDevelopers.length}`);
      console.log(`   Unique names: ${uniqueNames}`);
      console.log(`   Duplicate groups: ${duplicates.length}`);
      console.log(`   Developers in duplicate groups: ${totalDuplicateCount}`);
    }

    // Also check for exact duplicates (same name, logo, description)
    console.log('\n🔍 Checking for exact duplicates (same name, logo, description)...\n');
    const exactDuplicates: Array<{ name: string; developers: Developer[] }> = [];
    
    nameMap.forEach((developers) => {
      if (developers.length > 1) {
        // Group by exact match (name + logo + description)
        const exactGroups = new Map<string, Developer[]>();
        
        developers.forEach(dev => {
          const key = `${dev.name}|${dev.logo || ''}|${dev.description?.substring(0, 100) || ''}`;
          if (!exactGroups.has(key)) {
            exactGroups.set(key, []);
          }
          exactGroups.get(key)!.push(dev);
        });
        
        exactGroups.forEach((group, key) => {
          if (group.length > 1) {
            exactDuplicates.push({
              name: group[0].name,
              developers: group
            });
          }
        });
      }
    });

    if (exactDuplicates.length === 0) {
      console.log('✅ No exact duplicates found!');
    } else {
      console.log(`⚠️  Found ${exactDuplicates.length} exact duplicate group(s):\n`);
      
      exactDuplicates.forEach((dup, index) => {
        console.log(`${index + 1}. "${dup.name}" - ${dup.developers.length} exact duplicate(s):`);
        dup.developers.forEach((dev, idx) => {
          console.log(`   ${idx + 1}. ID: ${dev.id} (Created: ${dev.createdAt})`);
        });
        console.log('');
      });
    }

    await AppDataSource.destroy();
    console.log('\n✅ Check completed!');
  } catch (error: any) {
    console.error('❌ Error checking duplicates:', error);
    process.exit(1);
  }
}

checkDeveloperDuplicates();

