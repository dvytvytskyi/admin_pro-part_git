import 'reflect-metadata';
import * as fs from 'fs';
import * as path from 'path';
import { AppDataSource } from '../config/database';
import { News } from '../entities/News';
import { NewsContent, NewsContentType } from '../entities/NewsContent';

interface NewsArticle {
  title: string;
  description: string;
  imageUrl: string;
  isPublished: boolean;
  publishedAt: string;
  contents: Array<{
    type: string;
    title: string;
    description: string | null;
    order: number;
  }>;
}

interface NewsJson {
  news: NewsArticle[];
}

async function importNewsFromJson() {
  try {
    console.log('🔄 Connecting to database...');
    await AppDataSource.initialize();
    console.log('✅ Database connected\n');

    const newsRepository = AppDataSource.getRepository(News);
    const contentRepository = AppDataSource.getRepository(NewsContent);

    // Check if news table is empty
    const existingNewsCount = await newsRepository.count();
    if (existingNewsCount > 0) {
      console.log(`⚠️  News table already contains ${existingNewsCount} articles.`);
      console.log('   Will add new articles to existing ones.\n');
    }

    // Find news-import.json or news.json file
    const possiblePaths = [
      path.resolve(__dirname, '../../../news-import.json'),
      path.resolve(process.cwd(), 'news-import.json'),
      '/app/news-import.json',
      path.join(process.cwd(), 'news-import.json'),
      path.resolve(__dirname, '../../news-import.json'),
      path.resolve(__dirname, '../../../news.json'),
      path.resolve(process.cwd(), 'news.json'),
      '/app/news.json',
      path.join(process.cwd(), 'news.json'),
      path.resolve(__dirname, '../../news.json'),
    ];

    let jsonPath: string | null = null;
    for (const possiblePath of possiblePaths) {
      if (fs.existsSync(possiblePath)) {
        jsonPath = possiblePath;
        break;
      }
    }

    if (!jsonPath) {
      throw new Error(`File not found. Tried: ${possiblePaths.join(', ')}`);
    }

    console.log(`📖 Reading file: ${jsonPath}`);
    const jsonContent = fs.readFileSync(jsonPath, 'utf-8');
    const data: any = JSON.parse(jsonContent);
    
    // Handle both formats: { news: [...] } and [...]
    let articlesArray: any[] = [];
    if (Array.isArray(data)) {
      articlesArray = data;
    } else if (data.news && Array.isArray(data.news)) {
      articlesArray = data.news;
    } else {
      throw new Error('Invalid JSON format. Expected array or object with "news" property containing array.');
    }
    
    console.log(`✅ Parsed ${articlesArray.length} articles\n`);

    console.log('🚀 Starting import...\n');

    let successCount = 0;
    let errorCount = 0;
    const errors: string[] = [];

    for (let i = 0; i < articlesArray.length; i++) {
      const article = articlesArray[i];
      
      try {
        // Create news article
        const news = newsRepository.create({
          title: article.title,
          description: article.description || '',
          imageUrl: article.imageUrl,
          isPublished: article.isPublished !== undefined ? article.isPublished : true,
          publishedAt: article.publishedAt ? new Date(article.publishedAt) : new Date(),
        });

        const savedNews = await newsRepository.save(news);

        // Create news contents
        if (article.contents && article.contents.length > 0) {
          const contents = article.contents.map((content: any) => {
            const contentType = content.type === 'image' ? NewsContentType.IMAGE :
                               content.type === 'video' ? NewsContentType.VIDEO :
                               NewsContentType.TEXT;
            
            const newsContent = contentRepository.create({
              newsId: savedNews.id,
              type: contentType,
              title: content.title || '',
              description: content.description || null,
              imageUrl: content.imageUrl || null,
              videoUrl: content.videoUrl || null,
              order: content.order !== undefined ? content.order : 0,
            });
            return newsContent;
          });

          await contentRepository.save(contents);
        }

        successCount++;
        console.log(`✅ [${i + 1}/${articlesArray.length}] Imported: ${article.title.substring(0, 50)}...`);
      } catch (error: any) {
        errorCount++;
        const errorMsg = `Article ${i + 1} (${article.title.substring(0, 30)}...): ${error.message}`;
        errors.push(errorMsg);
        console.error(`❌ ${errorMsg}`);
      }
    }

    console.log('\n📊 Import Summary:');
    console.log(`   ✅ Successfully imported: ${successCount}`);
    console.log(`   ❌ Failed: ${errorCount}`);
    
    if (errors.length > 0) {
      console.log('\n❌ Errors:');
      errors.forEach(err => console.log(`   • ${err}`));
    }

    await AppDataSource.destroy();
    console.log('\n✅ Import completed!');
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

importNewsFromJson();

