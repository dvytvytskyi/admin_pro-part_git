import 'reflect-metadata';
import { AppDataSource } from '../config/database';

// Script to fix broken image URLs (with trailing braces or other issues)
async function fixBrokenImageUrls() {
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

      let totalFixed = 0;
      let totalAreasUpdated = 0;

      for (const area of areasRaw) {
        const areaId = area.id;
        const areaName = area.nameEn;
        let images = area.images;

        // Parse images
        let parsedImages: string[] = [];
        
        if (Array.isArray(images)) {
          parsedImages = images;
        } else if (typeof images === 'string') {
          // Parse like parseArray function
          let cleaned = images.trim();
          
          if (cleaned.startsWith('{') && cleaned.endsWith('}')) {
            cleaned = cleaned.slice(1, -1);
            const urls: string[] = [];
            let current = '';
            let inQuotes = false;
            
            for (let i = 0; i < cleaned.length; i++) {
              const char = cleaned[i];
              if (char === '"' && (i === 0 || cleaned[i - 1] !== '\\')) {
                inQuotes = !inQuotes;
              } else if (char === ',' && !inQuotes) {
                const url = current.trim();
                if (url) {
                  urls.push(url.replace(/^["']|["']$/g, ''));
                }
                current = '';
              } else {
                current += char;
              }
            }
            
            if (current.trim()) {
              const url = current.trim();
              urls.push(url.replace(/^["']|["']$/g, ''));
            }
            
            parsedImages = urls.filter(url => url.length > 0);
          } else {
            const singleUrl = cleaned.replace(/^["']|["']$/g, '');
            parsedImages = singleUrl ? [singleUrl] : [];
          }
        }

        // Fix broken URLs
        let hasChanges = false;
        const fixedImages = parsedImages.map(url => {
          // Remove trailing braces, quotes, and other invalid characters
          let fixed = url.trim();
          
          // Remove trailing } or {
          fixed = fixed.replace(/[{}]+$/, '');
          fixed = fixed.replace(/^[{}]+/, '');
          
          // Remove trailing quotes
          fixed = fixed.replace(/^["']+|["']+$/g, '');
          
          // Remove any trailing commas or spaces
          fixed = fixed.replace(/[, ]+$/, '');
          
          // Check if URL is valid
          if (!fixed.startsWith('http://') && !fixed.startsWith('https://')) {
            console.log(`  ⚠️  Invalid URL in ${areaName}: ${url.substring(0, 60)}`);
            return null;
          }
          
          if (fixed !== url) {
            hasChanges = true;
            console.log(`  🔧 Fixed URL in ${areaName}:`);
            console.log(`     Before: ${url.substring(0, 80)}${url.length > 80 ? '...' : ''}`);
            console.log(`     After:  ${fixed.substring(0, 80)}${fixed.length > 80 ? '...' : ''}`);
            totalFixed++;
          }
          
          return fixed;
        }).filter((url): url is string => url !== null);

        // Update if there were changes
        if (hasChanges || fixedImages.length !== parsedImages.length) {
          if (fixedImages.length > 0) {
            await queryRunner.query(
              `UPDATE areas SET images = $1::text[] WHERE id = $2`,
              [fixedImages, areaId]
            );
            console.log(`  ✅ Updated ${areaName} with ${fixedImages.length} fixed images`);
            totalAreasUpdated++;
          } else {
            // If no valid images left, set to NULL
            await queryRunner.query(
              `UPDATE areas SET images = NULL WHERE id = $1`,
              [areaId]
            );
            console.log(`  ⚠️  Removed all invalid images from ${areaName}`);
            totalAreasUpdated++;
          }
        }
      }

      console.log('\n' + '='.repeat(60));
      console.log('✅ FIX COMPLETED!');
      console.log('='.repeat(60));
      console.log(`📊 Areas checked: ${areasRaw.length}`);
      console.log(`🔧 URLs fixed: ${totalFixed}`);
      console.log(`✅ Areas updated: ${totalAreasUpdated}`);
      console.log('='.repeat(60) + '\n');

    } finally {
      await queryRunner.release();
    }

    await AppDataSource.destroy();
    process.exit(0);
  } catch (error: any) {
    console.error('❌ Error fixing broken image URLs:', error);
    if (AppDataSource.isInitialized) {
      await AppDataSource.destroy();
    }
    process.exit(1);
  }
}

fixBrokenImageUrls();

