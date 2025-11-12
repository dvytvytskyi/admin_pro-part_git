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
  description?: string;
  description_en?: string;
  logo?: {
    id?: number;
    src?: string;
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
    const developerPath = path.join(__dirname, '../../developer.json');
    if (!fs.existsSync(developerPath)) {
      throw new Error(`File not found: ${developerPath}`);
    }

    console.log('📖 Reading developer.json...');
    const developersData: DeveloperData[] = JSON.parse(fs.readFileSync(developerPath, 'utf-8'));
    console.log(`📊 Found ${developersData.length} developers in JSON`);

    // Load all developers from database
    const allDevelopers = await developerRepository.find();
    console.log(`📊 Found ${allDevelopers.length} developers in database`);

    // Create a map for quick lookup by name (case-insensitive, normalized)
    const developerMap = new Map<string, Developer>();
    allDevelopers.forEach(dev => {
      // Normalize: lowercase, trim, remove extra spaces
      const key = dev.name.toLowerCase().trim().replace(/\s+/g, ' ');
      if (!developerMap.has(key)) {
        developerMap.set(key, dev);
      }
      // Also add without spaces for better matching
      const keyNoSpaces = key.replace(/\s+/g, '');
      if (!developerMap.has(keyNoSpaces)) {
        developerMap.set(keyNoSpaces, dev);
      }
    });

    console.log('\n🔄 Starting import...\n');

    let updatedCount = 0;
    let notFoundCount = 0;
    const notFound: string[] = [];

    for (const devData of developersData) {
      const devName = devData.name_en || devData.name || devData.title;
      if (!devName) {
        continue;
      }

      // Try to find developer by name (case-insensitive, normalized)
      const normalizedName = devName.toLowerCase().trim().replace(/\s+/g, ' ');
      let developer = developerMap.get(normalizedName);
      
      // If not found, try without spaces
      if (!developer) {
        const nameNoSpaces = normalizedName.replace(/\s+/g, '');
        developer = developerMap.get(nameNoSpaces);
      }
      
      // If still not found, try partial match (contains)
      if (!developer) {
        for (const [key, mappedDev] of developerMap.entries()) {
          if (key.includes(normalizedName) || normalizedName.includes(key)) {
            developer = mappedDev;
            break;
          }
        }
      }

      if (!developer) {
        notFoundCount++;
        notFound.push(devName);
        continue;
      }

      // Prepare description (use description_en or description, remove HTML tags)
      let description: string | null = null;
      if (devData.description_en) {
        // Remove HTML tags but keep text content
        description = devData.description_en
          .replace(/<[^>]*>/g, '') // Remove HTML tags
          .replace(/&nbsp;/g, ' ')
          .replace(/&amp;/g, '&')
          .replace(/&lt;/g, '<')
          .replace(/&gt;/g, '>')
          .replace(/&quot;/g, '"')
          .replace(/\s+/g, ' ')
          .trim();
      } else if (devData.description) {
        description = devData.description
          .replace(/<[^>]*>/g, '')
          .replace(/&nbsp;/g, ' ')
          .replace(/&amp;/g, '&')
          .replace(/&lt;/g, '<')
          .replace(/&gt;/g, '>')
          .replace(/&quot;/g, '"')
          .replace(/\s+/g, ' ')
          .trim();
      }

      // Prepare logo URL
      let logo: string | null = null;
      if (devData.logo) {
        logo = devData.logo.src || devData.logo.logo || null;
      }

      // Prepare images array (use photo_urls or photos, keep ALL photos without truncating URLs)
      let images: string[] = [];
      if (devData.photo_urls && Array.isArray(devData.photo_urls)) {
        images = devData.photo_urls
          .filter(url => url && typeof url === 'string' && url.trim().length > 0)
          .map(url => url.trim()); // Keep full URL, only trim whitespace
      } else if (devData.photos && Array.isArray(devData.photos)) {
        images = devData.photos
          .map(photo => photo.src)
          .filter(src => src && typeof src === 'string' && src.trim().length > 0)
          .map(src => src.trim()); // Keep full URL, only trim whitespace
      }

      // Update developer using raw SQL to properly handle arrays
      const updateData: any[] = [];
      const setClauses: string[] = [];

      if (description) {
        setClauses.push(`description = $${updateData.length + 1}`);
        updateData.push(description);
      } else {
        setClauses.push(`description = NULL`);
      }

      if (logo) {
        setClauses.push(`logo = $${updateData.length + 1}`);
        updateData.push(logo);
      } else {
        setClauses.push(`logo = NULL`);
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

      if (updatedCount % 10 === 0) {
        console.log(`  ✓ Updated ${updatedCount} developers...`);
      }
    }

    console.log('\n📊 Import Summary:');
    console.log(`  ✅ Updated: ${updatedCount} developers`);
    console.log(`  ❌ Not found: ${notFoundCount} developers`);

    if (notFound.length > 0 && notFound.length <= 20) {
      console.log('\n  Developers not found in database:');
      notFound.slice(0, 20).forEach(name => console.log(`    - ${name}`));
      if (notFound.length > 20) {
        console.log(`    ... and ${notFound.length - 20} more`);
      }
    } else if (notFound.length > 20) {
      console.log(`\n  First 20 developers not found:`);
      notFound.slice(0, 20).forEach(name => console.log(`    - ${name}`));
      console.log(`    ... and ${notFound.length - 20} more`);
    }

    await AppDataSource.destroy();
    console.log('\n✅ Import completed successfully!');
  } catch (error: any) {
    console.error('❌ Error importing developers data:', error);
    if (AppDataSource.isInitialized) {
      await AppDataSource.destroy();
    }
    process.exit(1);
  }
}

importDevelopersData();
