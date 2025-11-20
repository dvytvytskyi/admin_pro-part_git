import 'reflect-metadata';
import * as fs from 'fs';
import * as path from 'path';
import { AppDataSource } from '../config/database';
import { News } from '../entities/News';

interface Article {
  number: number;
  title: string;
  description: string;
  fullText: string;
}

// Стікші фото з Unsplash для різних тем
const stockImages = [
  'https://images.unsplash.com/photo-1518770660439-4636190af475?w=1200&h=800&fit=crop', // Dubai skyline
  'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?w=1200&h=800&fit=crop', // Luxury building
  'https://images.unsplash.com/photo-1582407947304-fd86f028f716?w=1200&h=800&fit=crop', // Modern architecture
  'https://images.unsplash.com/photo-1497366216548-37526070297c?w=1200&h=800&fit=crop', // Business district
  'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=1200&h=800&fit=crop', // Real estate
  'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?w=1200&h=800&fit=crop', // Tourism
  'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=1200&h=800&fit=crop', // Business center
  'https://images.unsplash.com/photo-1480714378408-67cf0d13bc1b?w=1200&h=800&fit=crop', // City view
  'https://images.unsplash.com/photo-1526304640581-d334cdbbf45e?w=1200&h=800&fit=crop', // Modern office
  'https://images.unsplash.com/photo-1497366754035-f200968a6e72?w=1200&h=800&fit=crop', // Urban development
  'https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=1200&h=800&fit=crop', // Luxury property
  'https://images.unsplash.com/photo-1521791136064-7986c2920216?w=1200&h=800&fit=crop', // Modern architecture 2
  'https://images.unsplash.com/photo-1487958449943-2429e8be8625?w=1200&h=800&fit=crop', // Real estate 2
  'https://images.unsplash.com/photo-1512918728675-ed5a9ecdebfd?w=1200&h=800&fit=crop', // Construction
  'https://images.unsplash.com/photo-1503387762-592deb58ef4e?w=1200&h=800&fit=crop', // Business
  'https://images.unsplash.com/photo-1497366811353-6870744d04b2?w=1200&h=800&fit=crop', // Investment
  'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=1200&h=800&fit=crop', // Finance
  'https://images.unsplash.com/photo-1497366216548-37526070297c?w=1200&h=800&fit=crop', // Development
  'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=1200&h=800&fit=crop', // Economy
  'https://images.unsplash.com/photo-1553877522-43269d4ea984?w=1200&h=800&fit=crop', // Innovation
  'https://images.unsplash.com/photo-1558036117-15d82a90b9b1?w=1200&h=800&fit=crop', // Technology
  'https://images.unsplash.com/photo-1497366754035-f200968a6e72?w=1200&h=800&fit=crop', // Tourism 2
  'https://images.unsplash.com/photo-1480714378408-67cf0d13bc1b?w=1200&h=800&fit=crop', // City life
  'https://images.unsplash.com/photo-1512918728675-ed5a9ecdebfd?w=1200&h=800&fit=crop', // Construction 2
  'https://images.unsplash.com/photo-1487958449943-2429e8be8625?w=1200&h=800&fit=crop', // Property
  'https://images.unsplash.com/photo-1497366216548-37526070297c?w=1200&h=800&fit=crop', // Business district 2
  'https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=1200&h=800&fit=crop', // Luxury
  'https://images.unsplash.com/photo-1521791136064-7986c2920216?w=1200&h=800&fit=crop', // Modern
  'https://images.unsplash.com/photo-1518770660439-4636190af475?w=1200&h=800&fit=crop', // Dubai
  'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?w=1200&h=800&fit=crop', // Architecture
];

function parseArticles(filePath: string): Article[] {
  const content = fs.readFileSync(filePath, 'utf-8');
  const articles: Article[] = [];
  
  // Розділяємо по "Стаття N"
  const articlePattern = /Стаття\s+(\d+)/g;
  const matches = [...content.matchAll(articlePattern)];
  
  for (let i = 0; i < matches.length; i++) {
    const match = matches[i];
    const articleNumber = parseInt(match[1]);
    const startIndex = match.index! + match[0].length;
    const endIndex = i < matches.length - 1 ? matches[i + 1].index! : content.length;
    
    const articleText = content.substring(startIndex, endIndex).trim();
    
    if (!articleText) continue;
    
    // Перший рядок - заголовок
    const lines = articleText.split('\n').map(l => l.trim()).filter(l => l);
    if (lines.length === 0) continue;
    
    const title = lines[0];
    const description = lines.slice(1, 4).join(' ').substring(0, 300); // Перші 3 рядки як опис
    const fullText = lines.join('\n\n');
    
    articles.push({
      number: articleNumber,
      title,
      description: description || title,
      fullText,
    });
  }
  
  return articles;
}

function getStockImage(index: number): string {
  return stockImages[index % stockImages.length];
}

async function importNews() {
  try {
    console.log('🔄 Connecting to database...');
    await AppDataSource.initialize();
    console.log('✅ Database connected\n');

    const filePath = path.join(__dirname, '../../../news-upload.txt');
    
    if (!fs.existsSync(filePath)) {
      console.error(`❌ File not found: ${filePath}`);
      process.exit(1);
    }

    console.log('📖 Parsing articles from file...');
    const articles = parseArticles(filePath);
    console.log(`✅ Found ${articles.length} articles\n`);

    const newsRepository = AppDataSource.getRepository(News);
    
    // Перевіряємо, чи вже є новини з такими заголовками
    const existingTitles = new Set(
      (await newsRepository.find({ select: ['title'] })).map(n => n.title)
    );

    let imported = 0;
    let skipped = 0;
    let updated = 0;

    for (let i = 0; i < articles.length; i++) {
      const article = articles[i];
      
      // Перевіряємо, чи вже існує стаття з таким заголовком
      const existing = await newsRepository.findOne({
        where: { title: article.title },
      });

      const imageUrl = getStockImage(i);
      const publishedAt = new Date();
      
      if (existing) {
        // Оновлюємо існуючу статтю
        existing.description = article.description;
        existing.imageUrl = imageUrl;
        existing.isPublished = true;
        existing.publishedAt = publishedAt;
        await newsRepository.save(existing);
        updated++;
        console.log(`📝 [${i + 1}/${articles.length}] Updated: ${article.title.substring(0, 50)}...`);
      } else {
        // Створюємо нову статтю
        const news = newsRepository.create({
          title: article.title,
          description: article.description,
          imageUrl: imageUrl,
          isPublished: true,
          publishedAt: publishedAt,
        });
        
        await newsRepository.save(news);
        imported++;
        console.log(`✅ [${i + 1}/${articles.length}] Imported: ${article.title.substring(0, 50)}...`);
      }
    }

    console.log(`\n✅ Import completed!`);
    console.log(`   - Imported: ${imported}`);
    console.log(`   - Updated: ${updated}`);
    console.log(`   - Skipped: ${skipped}`);
    console.log(`   - Total: ${articles.length}`);

    await AppDataSource.destroy();
    console.log('\n✅ Done!');
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

importNews();
