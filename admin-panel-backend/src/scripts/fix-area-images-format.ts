import 'reflect-metadata';
import { AppDataSource } from '../config/database';
import { Area } from '../entities/Area';

// Script to fix area images format in database
// This ensures images are stored as proper PostgreSQL array, not as string
async function fixAreaImagesFormat() {
  try {
    console.log('🔄 Connecting to database...');
    await AppDataSource.initialize();
    console.log('✅ Database connected\n');

    const queryRunner = AppDataSource.createQueryRunner();
    await queryRunner.connect();

    try {
      // Get all areas with images
      const areasRaw = await queryRunner.query(`
        SELECT 
          id,
          "nameEn",
          images
        FROM areas
        WHERE images IS NOT NULL
      `);

      console.log(`📊 Found ${areasRaw.length} areas with images\n`);

      let fixedCount = 0;
      let skippedCount = 0;

      for (const area of areasRaw) {
        const areaId = area.id;
        const areaName = area.nameEn;
        let images = area.images;

        // If images is already an array, skip
        if (Array.isArray(images)) {
          // Verify all items are valid URLs
          const validImages = images.filter((img: any) => {
            if (typeof img !== 'string') return false;
            const cleaned = img.trim().replace(/^["']|["']$/g, '');
            return cleaned.startsWith('http://') || cleaned.startsWith('https://');
          }).map((img: string) => {
            return img.trim().replace(/^["']|["']$/g, '');
          });

          if (validImages.length === images.length) {
            skippedCount++;
            continue; // Already correct format
          } else {
            images = validImages;
          }
        } else if (typeof images === 'string') {
          // Parse string format
          let cleaned = images.trim();
          
          // Remove outer braces if present
          if (cleaned.startsWith('{') && cleaned.endsWith('}')) {
            cleaned = cleaned.slice(1, -1);
          }
          
          // Split by comma and clean up
          const urls: string[] = [];
          let current = '';
          let inQuotes = false;
          
          for (let i = 0; i < cleaned.length; i++) {
            const char = cleaned[i];
            if (char === '"' && (i === 0 || cleaned[i - 1] !== '\\')) {
              inQuotes = !inQuotes;
            } else if (char === ',' && !inQuotes) {
              const url = current.trim().replace(/^["']|["']$/g, '');
              if (url && (url.startsWith('http://') || url.startsWith('https://'))) {
                urls.push(url);
              }
              current = '';
            } else {
              current += char;
            }
          }
          
          // Add last URL
          if (current.trim()) {
            const url = current.trim().replace(/^["']|["']$/g, '');
            if (url && (url.startsWith('http://') || url.startsWith('https://'))) {
              urls.push(url);
            }
          }
          
          images = urls;
        } else {
          skippedCount++;
          continue;
        }

        // Update with proper array format
        if (images.length > 0) {
          await queryRunner.query(
            `UPDATE areas SET images = $1::text[] WHERE id = $2`,
            [images, areaId]
          );
          console.log(`  ✅ Fixed: ${areaName} (${images.length} images)`);
          fixedCount++;
        } else {
          // Set to NULL if no valid images
          await queryRunner.query(
            `UPDATE areas SET images = NULL WHERE id = $1`,
            [areaId]
          );
          console.log(`  ⚠️  Removed invalid images: ${areaName}`);
          fixedCount++;
        }
      }

      console.log('\n' + '='.repeat(60));
      console.log('✅ FIX COMPLETED!');
      console.log('='.repeat(60));
      console.log(`📊 Areas checked: ${areasRaw.length}`);
      console.log(`✅ Areas fixed: ${fixedCount}`);
      console.log(`⏭️  Areas skipped (already correct): ${skippedCount}`);
      console.log('='.repeat(60) + '\n');

    } finally {
      await queryRunner.release();
    }

    await AppDataSource.destroy();
    process.exit(0);
  } catch (error: any) {
    console.error('❌ Error fixing area images format:', error);
    if (AppDataSource.isInitialized) {
      await AppDataSource.destroy();
    }
    process.exit(1);
  }
}

fixAreaImagesFormat();

