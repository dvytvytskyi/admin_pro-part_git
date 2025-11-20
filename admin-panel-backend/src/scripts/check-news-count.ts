import 'reflect-metadata';
import { AppDataSource } from '../config/database';
import { News } from '../entities/News';

async function checkNewsCount() {
  try {
    console.log('🔄 Connecting to database...');
    await AppDataSource.initialize();
    console.log('✅ Database connected\n');

    const newsRepository = AppDataSource.getRepository(News);
    
    const totalCount = await newsRepository.count();
    console.log(`📊 Total news count: ${totalCount}\n`);

    const allNews = await newsRepository.find({
      relations: ['contents'],
      order: {
        createdAt: 'DESC',
      },
      take: 10, // Show first 10
    });

    console.log(`📰 First ${allNews.length} news articles:\n`);
    allNews.forEach((news, index) => {
      console.log(`${index + 1}. ${news.title}`);
      console.log(`   ID: ${news.id}`);
      console.log(`   Published: ${news.isPublished}`);
      console.log(`   Created: ${news.createdAt}`);
      console.log(`   Contents: ${news.contents?.length || 0}`);
      console.log('');
    });

    await AppDataSource.destroy();
    console.log('✅ Check completed!');
  } catch (error: any) {
    console.error('❌ Error:', error.message);
    if (error.stack) {
      console.error(error.stack);
    }
    if (AppDataSource.isInitialized) {
      await AppDataSource.destroy();
    }
    process.exit(1);
  }
}

checkNewsCount();

