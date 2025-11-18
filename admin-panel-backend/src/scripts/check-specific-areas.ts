import 'reflect-metadata';
import { AppDataSource } from '../config/database';

// Script to check specific areas for images
async function checkSpecificAreas() {
  try {
    console.log('🔄 Connecting to database...');
    await AppDataSource.initialize();
    console.log('✅ Database connected\n');

    const queryRunner = AppDataSource.createQueryRunner();
    await queryRunner.connect();

    try {
      // List of areas to check
      const areaNames = [
        'Arjan',
        'Cherrywoods',
        'City of Arabia',
        'Damac Lagoons',
        'Dubai Harbour',
        'Dubai Industrial City',
        'Dubai Marina',
        'Dubai Investment Park',
        'Dubai Science Park',
        'Dubai Silicon Oasis',
        'Dubai Studio City',
        'International City',
        'Jumeirah Village Triangle (JVT)',
        'Mohammed Bin Rashid City (MBR)'
      ];

      console.log(`📊 Checking ${areaNames.length} specific areas\n`);
      console.log('='.repeat(80));

      for (const areaName of areaNames) {
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
          WHERE "nameEn" = $1
        `, [areaName]);

        if (areasRaw.length === 0) {
          console.log(`\n❌ Area not found: ${areaName}`);
          continue;
        }

        const area = areasRaw[0];
        console.log(`\n📍 Area: ${area.nameEn}`);
        console.log(`   ID: ${area.id}`);
        console.log(`   Images Type in DB: ${area.images_type}`);

        // Parse images like API does
        let parsedImages: string[] = [];
        
        if (!area.images) {
          parsedImages = [];
          console.log(`   Parsed: [] (null in DB)`);
        } else if (Array.isArray(area.images)) {
          parsedImages = area.images;
          if (parsedImages.length > 0) {
            console.log(`   Parsed: [${parsedImages.length} images]`);
            parsedImages.slice(0, 3).forEach((url, idx) => {
              console.log(`     ${idx + 1}. ${url.substring(0, 80)}${url.length > 80 ? '...' : ''}`);
            });
            if (parsedImages.length > 3) {
              console.log(`     ... and ${parsedImages.length - 3} more`);
            }
          } else {
            console.log(`   Parsed: [] (empty array)`);
          }
        } else if (typeof area.images === 'string') {
          // Parse like parseArray function
          let cleaned = area.images.trim();
          
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
            console.log(`   Parsed: [${parsedImages.length} images]`);
            parsedImages.slice(0, 3).forEach((url, idx) => {
              console.log(`     ${idx + 1}. ${url.substring(0, 80)}${url.length > 80 ? '...' : ''}`);
            });
            if (parsedImages.length > 3) {
              console.log(`     ... and ${parsedImages.length - 3} more`);
            }
          } else {
            console.log(`   Parsed: [] (empty after parsing)`);
            console.log(`   ⚠️  Raw value: ${area.images.substring(0, 100)}${area.images.length > 100 ? '...' : ''}`);
          }
        }

        // Test API format
        console.log(`\n   🧪 API Response format:`);
        const apiImages = parsedImages.length > 0 ? parsedImages : [];
        console.log(JSON.stringify({
          id: area.id,
          nameEn: area.nameEn,
          images: apiImages
        }, null, 2));
      }

      console.log('\n' + '='.repeat(80));
      console.log('✅ Check completed!');
      console.log('='.repeat(80) + '\n');

    } finally {
      await queryRunner.release();
    }

    await AppDataSource.destroy();
    process.exit(0);
  } catch (error: any) {
    console.error('❌ Error checking specific areas:', error);
    if (AppDataSource.isInitialized) {
      await AppDataSource.destroy();
    }
    process.exit(1);
  }
}

checkSpecificAreas();

