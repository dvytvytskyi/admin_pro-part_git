import 'reflect-metadata';
import { AppDataSource } from '../config/database';
import { Area } from '../entities/Area';
import * as fs from 'fs';
import * as path from 'path';

interface DistrictData {
  id: number;
  city_id: number;
  title: string;
  description?: string;
  infrastructure_description?: string;
  photos?: Array<{ id: number; src: string; logo?: string; size?: number }>;
  name?: string;
  name_en?: string;
}

async function importDistrictsData() {
  try {
    console.log('🔄 Connecting to database...');
    await AppDataSource.initialize();
    console.log('✅ Database connected');

    const areaRepository = AppDataSource.getRepository(Area);

    // Read districts.json
    const districtsPath = path.join(__dirname, '../../districts.json');
    if (!fs.existsSync(districtsPath)) {
      throw new Error(`File not found: ${districtsPath}`);
    }

    console.log('📖 Reading districts.json...');
    const districtsData: DistrictData[] = JSON.parse(fs.readFileSync(districtsPath, 'utf-8'));
    console.log(`📊 Found ${districtsData.length} districts in JSON`);

    let updatedCount = 0;
    let notFoundCount = 0;
    const notFound: string[] = [];

    // Load all areas from database
    const allAreas = await areaRepository.find();
    console.log(`📊 Found ${allAreas.length} areas in database`);

    // Create a map for quick lookup by nameEn (case-insensitive)
    const areaMap = new Map<string, Area>();
    allAreas.forEach(area => {
      const key = area.nameEn.toLowerCase().trim();
      if (!areaMap.has(key)) {
        areaMap.set(key, area);
      }
    });

    console.log('\n🔄 Starting import...\n');

    for (const district of districtsData) {
      const districtTitle = district.title?.trim();
      if (!districtTitle) {
        continue;
      }

      // Try to find area by nameEn (case-insensitive)
      const areaKey = districtTitle.toLowerCase();
      const area = areaMap.get(areaKey);

      if (!area) {
        notFoundCount++;
        notFound.push(districtTitle);
        continue;
      }

      // Prepare description object
      const description: { title?: string; description?: string } = {};
      if (district.description) {
        // Use title as description title if available, otherwise use district title
        description.title = district.title || undefined;
        description.description = district.description;
      }

      // Prepare infrastructure object
      const infrastructure: { title?: string; description?: string } = {};
      if (district.infrastructure_description) {
        infrastructure.title = 'Інфраструктура'; // Default title
        infrastructure.description = district.infrastructure_description;
      }

      // Prepare images array (limit to 8 photos)
      let images: string[] = [];
      if (district.photos && Array.isArray(district.photos)) {
        images = district.photos
          .slice(0, 8) // Limit to 8 photos
          .map(photo => photo.src)
          .filter(src => src && typeof src === 'string');
      }

      // Update area using raw SQL to properly handle JSONB and arrays
      const updateData: any[] = [];
      const setClauses: string[] = [];

      if (Object.keys(description).length > 0) {
        setClauses.push(`description = $${updateData.length + 1}::jsonb`);
        updateData.push(JSON.stringify(description));
      } else {
        setClauses.push(`description = NULL`);
      }

      if (Object.keys(infrastructure).length > 0) {
        setClauses.push(`infrastructure = $${updateData.length + 1}::jsonb`);
        updateData.push(JSON.stringify(infrastructure));
      } else {
        setClauses.push(`infrastructure = NULL`);
      }

      if (images.length > 0) {
        setClauses.push(`images = $${updateData.length + 1}::text[]`);
        updateData.push(images);
      } else {
        setClauses.push(`images = NULL`);
      }

      updateData.push(area.id);

      await AppDataSource.query(
        `UPDATE areas SET ${setClauses.join(', ')} WHERE id = $${updateData.length}`,
        updateData
      );

      updatedCount++;

      if (updatedCount % 10 === 0) {
        console.log(`  ✓ Updated ${updatedCount} areas...`);
      }
    }

    console.log('\n📊 Import Summary:');
    console.log(`  ✅ Updated: ${updatedCount} areas`);
    console.log(`  ❌ Not found: ${notFoundCount} districts`);

    if (notFound.length > 0 && notFound.length <= 20) {
      console.log('\n  Districts not found in database:');
      notFound.slice(0, 20).forEach(name => console.log(`    - ${name}`));
      if (notFound.length > 20) {
        console.log(`    ... and ${notFound.length - 20} more`);
      }
    } else if (notFound.length > 20) {
      console.log(`\n  First 20 districts not found:`);
      notFound.slice(0, 20).forEach(name => console.log(`    - ${name}`));
      console.log(`    ... and ${notFound.length - 20} more`);
    }

    await AppDataSource.destroy();
    console.log('\n✅ Import completed successfully!');
  } catch (error: any) {
    console.error('❌ Error importing districts data:', error);
    process.exit(1);
  }
}

importDistrictsData();

