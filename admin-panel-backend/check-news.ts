import 'reflect-metadata';
import { AppDataSource } from './src/config/database';
import { News } from './src/entities/News';

async function checkNews() {
  await AppDataSource.initialize();
  const newsRepo = AppDataSource.getRepository(News);
  const allNews = await newsRepo.find({ order: { publishedAt: 'DESC' } });
  
  console.log(`\n📊 Total news: ${allNews.length}`);
  const published = allNews.filter(n => n.isPublished);
  console.log(`✅ Published: ${published.length}`);
  console.log(`\n📰 Latest 5 published articles:\n`);
  
  published.slice(0, 5).forEach((n, i) => {
    console.log(`${i + 1}. ${n.title.substring(0, 60)}...`);
    console.log(`   Published: ${n.publishedAt?.toLocaleDateString() || 'N/A'}`);
    console.log(`   Image: ${n.imageUrl ? '✅' : '❌'}\n`);
  });
  
  await AppDataSource.destroy();
}

checkNews();
