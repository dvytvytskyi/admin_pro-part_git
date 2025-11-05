import 'reflect-metadata';
import { AppDataSource } from '../config/database';
import { Developer } from '../entities/Developer';
import * as fs from 'fs';
import * as path from 'path';

interface DeveloperData {
  id: number;
  title?: string;
  name?: string;
  name_en?: string;
  description_en?: string;
  logo?: {
    id: number;
    src: string;
    logo?: string;
  };
  photos?: Array<{ id: number; src: string; logo?: string; size?: number }>;
  photo_urls?: string[];
}

async function importDevelopersData() {
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

    // Load all existing developers from database
    const allDevelopers = await developerRepository.find();
    console.log(`📊 Found ${allDevelopers.length} developers in database`);

    // Create a map for quick lookup by name (case-insensitive)
    const developerMap = new Map<string, Developer>();
    allDevelopers.forEach(dev => {
      const key = dev.name.toLowerCase().trim();
      if (!developerMap.has(key)) {
        developerMap.set(key, dev);
      }
    });

    let updatedCount = 0;
    let createdCount = 0;
    const errors: string[] = [];

    console.log('\n🔄 Starting import...\n');

    for (const devData of developersData) {
      try {
        // Get developer name (prefer title, then name_en, then name)
        const devName = (devData.title || devData.name_en || devData.name || '').trim();
        if (!devName) {
          continue;
        }

        // Try to find existing developer by name (case-insensitive)
        const devKey = devName.toLowerCase();
        let developer = developerMap.get(devKey);

        // Prepare logo URL
        let logoUrl: string | null = null;
        if (devData.logo) {
          logoUrl = devData.logo.src || devData.logo.logo || null;
        }

        // Prepare description (use description_en, strip HTML tags)
        let description: string | null = null;
        if (devData.description_en) {
          // Remove HTML tags
          description = devData.description_en
            .replace(/<[^>]*>/g, '')
            .replace(/&nbsp;/g, ' ')
            .replace(/&amp;/g, '&')
            .replace(/&lt;/g, '<')
            .replace(/&gt;/g, '>')
            .replace(/&quot;/g, '"')
            .trim();
          if (description === '') {
            description = null;
          }
        }

        // Prepare images array (prefer photo_urls, then photos)
        let images: string[] = [];
        if (devData.photo_urls && Array.isArray(devData.photo_urls)) {
          images = devData.photo_urls.filter(url => url && typeof url === 'string');
        } else if (devData.photos && Array.isArray(devData.photos)) {
          images = devData.photos
            .map(photo => photo.src)
            .filter(src => src && typeof src === 'string');
        }

        // Update or create developer
        if (developer) {
          // Update existing developer
          const updateData: any[] = [];
          const setClauses: string[] = [];

          if (logoUrl) {
            setClauses.push(`logo = $${updateData.length + 1}`);
            updateData.push(logoUrl);
          } else {
            setClauses.push(`logo = NULL`);
          }

          if (description) {
            setClauses.push(`description = $${updateData.length + 1}`);
            updateData.push(description);
          } else {
            setClauses.push(`description = NULL`);
          }

          if (images.length > 0) {
            setClauses.push(`images = $${updateData.length + 1}::text[]`);
            updateData.push(images);
          } else {
            setClauses.push(`images = NULL`);
          }

          updateData.push(developer.id);

          await AppDataSource.query(
            `UPDATE developers SET ${setClauses.join(', ')} WHERE id = $${updateData.length}`,
            updateData
          );

          updatedCount++;
        } else {
          // Create new developer using raw SQL to properly handle arrays
          const insertData: any[] = [devName];
          const insertClauses: string[] = ['name'];
          const insertValues: string[] = ['$1'];

          if (logoUrl) {
            insertClauses.push('logo');
            insertValues.push(`$${insertData.length + 1}`);
            insertData.push(logoUrl);
          } else {
            insertClauses.push('logo');
            insertValues.push('NULL');
          }

          if (description) {
            insertClauses.push('description');
            insertValues.push(`$${insertData.length + 1}`);
            insertData.push(description);
          } else {
            insertClauses.push('description');
            insertValues.push('NULL');
          }

          if (images.length > 0) {
            insertClauses.push('images');
            insertValues.push(`$${insertData.length + 1}::text[]`);
            insertData.push(images);
          } else {
            insertClauses.push('images');
            insertValues.push('NULL');
          }

          await AppDataSource.query(
            `INSERT INTO developers (${insertClauses.join(', ')}, "createdAt") VALUES (${insertValues.join(', ')}, DEFAULT) RETURNING id`,
            insertData
          );

          createdCount++;
        }

        if ((updatedCount + createdCount) % 50 === 0) {
          console.log(`  ✓ Processed ${updatedCount + createdCount} developers...`);
        }
      } catch (error: any) {
        const devName = devData.title || devData.name_en || devData.name || 'Unknown';
        errors.push(`${devName}: ${error.message}`);
        console.error(`  ✗ Error processing "${devName}":`, error.message);
      }
    }

    console.log('\n📊 Import Summary:');
    console.log(`  ✅ Updated: ${updatedCount} developers`);
    console.log(`  ➕ Created: ${createdCount} developers`);
    console.log(`  ❌ Errors: ${errors.length}`);

    if (errors.length > 0 && errors.length <= 20) {
      console.log('\n  Errors:');
      errors.forEach(err => console.log(`    - ${err}`));
    } else if (errors.length > 20) {
      console.log(`\n  First 20 errors:`);
      errors.slice(0, 20).forEach(err => console.log(`    - ${err}`));
      console.log(`    ... and ${errors.length - 20} more`);
    }

    const finalCount = await developerRepository.count();
    console.log(`\n📈 Total developers in database: ${finalCount}`);

    await AppDataSource.destroy();
    console.log('\n✅ Import completed successfully!');
  } catch (error: any) {
    console.error('❌ Error importing developers data:', error);
    process.exit(1);
  }
}

importDevelopersData();

