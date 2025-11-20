import 'reflect-metadata';
import { AppDataSource } from '../config/database';

async function fixDeveloperImageUrls() {
  try {
    console.log('🔄 Connecting to database...');
    await AppDataSource.initialize();
    console.log('✅ Database connected\n');

    // Отримуємо всіх девелоперів з images
    const developers = await AppDataSource.query(`
      SELECT id, name, images
      FROM developers
      WHERE images IS NOT NULL
    `);

    console.log(`📊 Found ${developers.length} developers with images\n`);

    let totalFixed = 0;
    let totalUrlsFixed = 0;

    for (const developer of developers) {
      const developerId = developer.id;
      const developerName = developer.name;
      const images = developer.images;

      if (!images || !Array.isArray(images)) {
        continue;
      }

      let hasFixed = false;
      const fixedImages = images.map((url: string) => {
        if (typeof url === 'string' && url.endsWith('}')) {
          hasFixed = true;
          totalUrlsFixed++;
          return url.slice(0, -1); // Remove the last character
        }
        return url;
      });

      if (hasFixed) {
        // Оновлюємо images через raw SQL для правильного збереження масиву
        await AppDataSource.query(
          `UPDATE developers SET images = $1::text[] WHERE id = $2`,
          [fixedImages, developerId]
        );
        console.log(`  ✅ Updated ${developerName}: fixed ${fixedImages.length} images`);
        totalFixed++;
      }
    }

    console.log('\n📊 Summary:');
    console.log(`  ✅ Developers updated: ${totalFixed}`);
    console.log(`  🔧 URLs fixed: ${totalUrlsFixed}`);

    await AppDataSource.destroy();
    console.log('\n✅ Fix completed successfully!');
  } catch (error: any) {
    console.error('❌ Error fixing developer image URLs:', error);
    if (AppDataSource.isInitialized) {
      await AppDataSource.destroy();
    }
    process.exit(1);
  }
}

fixDeveloperImageUrls();

