import 'reflect-metadata';
import { AppDataSource } from '../config/database';
import { Developer } from '../entities/Developer';
import * as fs from 'fs';
import * as path from 'path';

interface DeveloperData {
  title?: string;
  name?: string;
  name_en?: string;
}

async function removeDevelopersNotInJson() {
  try {
    console.log('🔄 Connecting to database...');
    await AppDataSource.initialize();
    console.log('✅ Database connected');

    const developerRepository = AppDataSource.getRepository(Developer);

    // Read developer.json
    const developersPath = path.join(__dirname, '../../../developer.json');
    if (!fs.existsSync(developersPath)) {
      throw new Error(`File not found: ${developersPath}`);
    }

    console.log('📖 Reading developer.json...');
    const developersData: DeveloperData[] = JSON.parse(fs.readFileSync(developersPath, 'utf-8'));
    console.log(`📊 Found ${developersData.length} developers in JSON`);

    // Create a set of developer names from JSON (case-insensitive)
    const jsonNames = new Set<string>();
    developersData.forEach(dev => {
      const name = (dev.title || dev.name_en || dev.name || '').trim();
      if (name) {
        jsonNames.add(name.toLowerCase());
      }
    });

    console.log(`📊 Found ${jsonNames.size} unique developer names in JSON\n`);

    // Load all developers from database
    const allDevelopers = await developerRepository.find();
    console.log(`📊 Found ${allDevelopers.length} developers in database\n`);

    // Find developers not in JSON
    const developersToDelete: Developer[] = [];
    const developersToKeep: Developer[] = [];

    allDevelopers.forEach(dev => {
      const devNameKey = dev.name.toLowerCase().trim();
      if (jsonNames.has(devNameKey)) {
        developersToKeep.push(dev);
      } else {
        developersToDelete.push(dev);
      }
    });

    console.log(`📊 Analysis:`);
    console.log(`  ✅ To keep: ${developersToKeep.length} developers`);
    console.log(`  ❌ To delete: ${developersToDelete.length} developers\n`);

    if (developersToDelete.length === 0) {
      console.log('✅ All developers in database exist in developer.json. Nothing to delete.');
      await AppDataSource.destroy();
      return;
    }

    // Show first 20 developers to be deleted
    console.log(`📋 Developers to be deleted (first 20):`);
    developersToDelete.slice(0, 20).forEach((dev, index) => {
      console.log(`  ${index + 1}. ${dev.name}`);
    });
    if (developersToDelete.length > 20) {
      console.log(`  ... and ${developersToDelete.length - 20} more`);
    }
    console.log('');

    // Delete developers
    const idsToDelete = developersToDelete.map(dev => dev.id);
    console.log(`🗑️  Deleting ${idsToDelete.length} developer(s)...\n`);

    const result = await AppDataSource.query(
      `DELETE FROM developers WHERE id = ANY($1::uuid[])`,
      [idsToDelete]
    );

    console.log(`✅ Deleted ${idsToDelete.length} developer(s)`);

    // Verify final count
    const finalCount = await developerRepository.count();
    console.log(`\n📈 Final developer count: ${finalCount}`);

    await AppDataSource.destroy();
    console.log('\n✅ Cleanup completed!');
  } catch (error: any) {
    console.error('❌ Error removing developers:', error);
    process.exit(1);
  }
}

removeDevelopersNotInJson();

