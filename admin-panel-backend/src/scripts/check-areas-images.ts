import 'reflect-metadata';
import { AppDataSource } from '../config/database';

// Script to check areas images in database and API format
async function checkAreasImages() {
  try {
    console.log('🔄 Connecting to database...');
    await AppDataSource.initialize();
    console.log('✅ Database connected\n');

    const queryRunner = AppDataSource.createQueryRunner();
    await queryRunner.connect();

    try {
      // Get all areas with images info
      const areasRaw = await queryRunner.query(`
        SELECT 
          id,
          "nameEn",
          images,
          CASE 
            WHEN images IS NULL THEN 'NULL'
            WHEN images = '{}' THEN 'EMPTY_ARRAY'
            WHEN images::text LIKE '{%}' THEN 'POSTGRES_ARRAY'
            ELSE 'UNKNOWN'
          END as images_type
        FROM areas
        ORDER BY "nameEn" ASC
        LIMIT 20
      `);

      console.log(`📊 Found ${areasRaw.length} areas (showing first 20)\n`);
      console.log('='.repeat(80));

      let areasWithImages = 0;
      let areasWithoutImages = 0;
      let areasWithNull = 0;
      let areasWithEmptyArray = 0;

      for (const area of areasRaw) {
        const areaId = area.id;
        const areaName = area.nameEn;
        const imagesRaw = area.images;
        const imagesType = area.images_type;

        console.log(`\n📍 Area: ${areaName}`);
        console.log(`   ID: ${areaId}`);
        console.log(`   Images Type in DB: ${imagesType}`);

        // Parse images like API does
        let parsedImages: string[] = [];
        
        if (!imagesRaw) {
          parsedImages = [];
          areasWithNull++;
          areasWithoutImages++;
          console.log(`   Parsed: [] (null in DB)`);
        } else if (Array.isArray(imagesRaw)) {
          parsedImages = imagesRaw;
          if (parsedImages.length > 0) {
            areasWithImages++;
            console.log(`   Parsed: [${parsedImages.length} images]`);
            parsedImages.slice(0, 3).forEach((url, idx) => {
              console.log(`     ${idx + 1}. ${url.substring(0, 80)}${url.length > 80 ? '...' : ''}`);
            });
            if (parsedImages.length > 3) {
              console.log(`     ... and ${parsedImages.length - 3} more`);
            }
          } else {
            areasWithEmptyArray++;
            areasWithoutImages++;
            console.log(`   Parsed: [] (empty array)`);
          }
        } else if (typeof imagesRaw === 'string') {
          // Parse like parseArray function
          let cleaned = imagesRaw.trim();
          
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

          if (parsedImages.length > 0) {
            areasWithImages++;
            console.log(`   Parsed: [${parsedImages.length} images]`);
            parsedImages.slice(0, 3).forEach((url, idx) => {
              console.log(`     ${idx + 1}. ${url.substring(0, 80)}${url.length > 80 ? '...' : ''}`);
            });
            if (parsedImages.length > 3) {
              console.log(`     ... and ${parsedImages.length - 3} more`);
            }
          } else {
            areasWithEmptyArray++;
            areasWithoutImages++;
            console.log(`   Parsed: [] (empty after parsing)`);
          }
        }

        // Check URL format
        if (parsedImages.length > 0) {
          const invalidUrls = parsedImages.filter(url => {
            return !url.startsWith('http://') && !url.startsWith('https://');
          });
          
          if (invalidUrls.length > 0) {
            console.log(`   ⚠️  Invalid URLs found: ${invalidUrls.length}`);
            invalidUrls.forEach(url => {
              console.log(`     - ${url.substring(0, 60)}`);
            });
          }

          const cloudinaryUrls = parsedImages.filter(url => url.includes('res.cloudinary.com'));
          const alnairUrls = parsedImages.filter(url => url.includes('files.alnair.ae'));
          const reellyUrls = parsedImages.filter(url => url.includes('api.reelly.io'));
          const otherUrls = parsedImages.filter(url => 
            !url.includes('res.cloudinary.com') && 
            !url.includes('files.alnair.ae') && 
            !url.includes('api.reelly.io')
          );

          console.log(`   📊 URL Sources:`);
          console.log(`      Cloudinary: ${cloudinaryUrls.length}`);
          console.log(`      Alnair: ${alnairUrls.length}`);
          console.log(`      Reelly: ${reellyUrls.length}`);
          console.log(`      Other: ${otherUrls.length}`);
        }
      }

      console.log('\n' + '='.repeat(80));
      console.log('📊 SUMMARY:');
      console.log('='.repeat(80));
      console.log(`Total areas checked: ${areasRaw.length}`);
      console.log(`Areas with images: ${areasWithImages}`);
      console.log(`Areas without images: ${areasWithoutImages}`);
      console.log(`  - NULL in DB: ${areasWithNull}`);
      console.log(`  - Empty array: ${areasWithEmptyArray}`);
      console.log('='.repeat(80) + '\n');

      // Test API format
      console.log('🧪 Testing API format (first area with images):');
      const areaWithImages = areasRaw.find((a: any) => {
        if (!a.images) return false;
        if (Array.isArray(a.images) && a.images.length > 0) return true;
        if (typeof a.images === 'string' && a.images.trim() !== '{}' && a.images.trim() !== '') return true;
        return false;
      });

      if (areaWithImages) {
        // Parse like API does
        let apiImages: string[] = [];
        if (!areaWithImages.images) {
          apiImages = [];
        } else if (Array.isArray(areaWithImages.images)) {
          apiImages = areaWithImages.images;
        } else if (typeof areaWithImages.images === 'string') {
          let cleaned = areaWithImages.images.trim();
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
            apiImages = urls.filter(url => url.length > 0);
          } else {
            const singleUrl = cleaned.replace(/^["']|["']$/g, '');
            apiImages = singleUrl ? [singleUrl] : [];
          }
        }

        console.log(`\nArea: ${areaWithImages.nameEn}`);
        console.log(`API Response format:`);
        console.log(JSON.stringify({
          id: areaWithImages.id,
          nameEn: areaWithImages.nameEn,
          images: apiImages
        }, null, 2));
      } else {
        console.log('No areas with images found in sample');
      }

    } finally {
      await queryRunner.release();
    }

    await AppDataSource.destroy();
    process.exit(0);
  } catch (error: any) {
    console.error('❌ Error checking areas images:', error);
    if (AppDataSource.isInitialized) {
      await AppDataSource.destroy();
    }
    process.exit(1);
  }
}

checkAreasImages();

