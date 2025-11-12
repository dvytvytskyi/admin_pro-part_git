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
  accessibility_description?: string;
  photos?: Array<{ id: number; src: string; logo?: string; size?: number }>;
  name?: string;
  name_en?: string;
}

async function importDistrictsData() {
  try {
    console.log('🔄 Connecting to database...');
    await AppDataSource.initialize();
    console.log('✅ Database connected');

    // Check and create columns if they don't exist
    console.log('🔍 Checking database columns...');
    const queryRunner = AppDataSource.createQueryRunner();
    await queryRunner.connect();
    
    try {
      // Check if columns exist
      const columns = await queryRunner.query(`
        SELECT column_name 
        FROM information_schema.columns 
        WHERE table_name = 'areas'
      `);
      const columnNames = columns.map((row: any) => row.column_name);
      
      // Add description column if missing
      if (!columnNames.includes('description')) {
        console.log('  ➕ Adding description column...');
        await queryRunner.query(`
          ALTER TABLE areas 
          ADD COLUMN description JSONB
        `);
        console.log('  ✅ description column added');
      }
      
      // Add infrastructure column if missing
      if (!columnNames.includes('infrastructure')) {
        console.log('  ➕ Adding infrastructure column...');
        await queryRunner.query(`
          ALTER TABLE areas 
          ADD COLUMN infrastructure JSONB
        `);
        console.log('  ✅ infrastructure column added');
      }
      
      // Add images column if missing
      if (!columnNames.includes('images')) {
        console.log('  ➕ Adding images column...');
        await queryRunner.query(`
          ALTER TABLE areas 
          ADD COLUMN images TEXT[]
        `);
        console.log('  ✅ images column added');
      }
    } finally {
      await queryRunner.release();
    }

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

    // Create a map for quick lookup by nameEn (case-insensitive, normalized)
    const areaMap = new Map<string, Area>();
    allAreas.forEach(area => {
      // Normalize: lowercase, trim, remove extra spaces
      const key = area.nameEn.toLowerCase().trim().replace(/\s+/g, ' ');
      if (!areaMap.has(key)) {
        areaMap.set(key, area);
      }
      // Also add without spaces for better matching
      const keyNoSpaces = key.replace(/\s+/g, '');
      if (!areaMap.has(keyNoSpaces)) {
        areaMap.set(keyNoSpaces, area);
      }
    });

    console.log('\n🔄 Starting import...\n');

    for (const district of districtsData) {
      const districtTitle = district.title?.trim();
      if (!districtTitle) {
        continue;
      }

      // Try to find area by nameEn (case-insensitive, normalized)
      const normalizedTitle = districtTitle.toLowerCase().trim().replace(/\s+/g, ' ');
      let area = areaMap.get(normalizedTitle);
      
      // If not found, try without spaces
      if (!area) {
        const titleNoSpaces = normalizedTitle.replace(/\s+/g, '');
        area = areaMap.get(titleNoSpaces);
      }
      
      // If still not found, try partial match (contains)
      if (!area) {
        for (const [key, mappedArea] of areaMap.entries()) {
          if (key.includes(normalizedTitle) || normalizedTitle.includes(key)) {
            area = mappedArea;
            break;
          }
        }
      }

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
        // Combine description and accessibility_description if both exist
        let fullDescription = district.description;
        if (district.accessibility_description) {
          fullDescription += '\n\n' + district.accessibility_description;
        }
        description.description = fullDescription;
      } else if (district.accessibility_description) {
        // If only accessibility_description exists, use it as description
        description.title = district.title || undefined;
        description.description = district.accessibility_description;
      }

      // Prepare infrastructure object
      const infrastructure: { title?: string; description?: string } = {};
      if (district.infrastructure_description) {
        infrastructure.title = 'Infrastructure'; // Default title
        infrastructure.description = district.infrastructure_description;
      }

      // Prepare images array (keep ALL photos without truncating URLs)
      let images: string[] = [];
      if (district.photos && Array.isArray(district.photos)) {
        images = district.photos
          .map(photo => photo.src)
          .filter(src => src && typeof src === 'string' && src.trim().length > 0)
          .map(src => src.trim()); // Keep full URL, only trim whitespace
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

