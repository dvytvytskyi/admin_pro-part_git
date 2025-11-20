import 'reflect-metadata';
import { AppDataSource } from './src/config/database';
import { News } from './src/entities/News';

async function checkNews() {
  await AppDataSource.initialize();
  const newsRepo = AppDataSource.getRepository(News);
  
  // Перевіряємо всі новини
  const allNews = await newsRepo.find({ 
    order: { publishedAt: 'DESC' },
    take: 10
  });
  
  console.log(`\n📊 Total news in DB: ${allNews.length}\n`);
  
  allNews.forEach((n, i) => {
    console.log(`${i + 1}. ${n.title.substring(0, 60)}...`);
    console.log(`   Published: ${n.isPublished ? '✅' : '❌'}`);
    console.log(`   PublishedAt: ${n.publishedAt?.toLocaleDateString() || 'N/A'}`);
    console.log(`   Image: ${n.imageUrl ? '✅' : '❌'}\n`);
  });
  
  // Перевіряємо публіковані новини
  const published = await newsRepo.count({ where: { isPublished: true } });
  console.log(`\n✅ Published news count: ${published}\n`);
  
  await AppDataSource.destroy();
}

checkNews();
