import { AppDataSource } from '../config/database';
import { News } from '../entities/News';
import { NewsContent, NewsContentType } from '../entities/NewsContent';
import * as fs from 'fs';
import * as path from 'path';

interface NewsContentData {
  type: 'text' | 'image' | 'video';
  title: string;
  description?: string | null;
  imageUrl?: string | null;
  videoUrl?: string | null;
  order: number;
}

interface NewsData {
  title: string;
  description: string;
  imageUrl?: string;
  isPublished?: boolean;
  publishedAt?: string;
  contents?: NewsContentData[];
}

interface NewsJsonData {
  news: NewsData[];
}

async function importNews() {
  try {
    // Initialize database connection
    await AppDataSource.initialize();
    console.log('✅ Database connected');

    const newsRepository = AppDataSource.getRepository(News);
    const contentRepository = AppDataSource.getRepository(NewsContent);

    // Read news.json file (from admin-panel-backend root)
    const jsonPath = path.resolve(__dirname, '../../news.json');
    if (!fs.existsSync(jsonPath)) {
      throw new Error(`File not found: ${jsonPath}`);
    }

    const jsonContent = fs.readFileSync(jsonPath, 'utf-8');
    const data: NewsJsonData = JSON.parse(jsonContent);

    if (!data.news || !Array.isArray(data.news)) {
      throw new Error('Invalid JSON format. Expected { "news": [...] }');
    }

    console.log(`📰 Found ${data.news.length} news articles to import\n`);

    let imported = 0;
    let updated = 0;
    let skipped = 0;
    let errors = 0;

    for (let i = 0; i < data.news.length; i++) {
      const newsData = data.news[i];
      try {
        // Check if news with same title already exists
        const existing = await newsRepository.findOne({
          where: { title: newsData.title },
          relations: ['contents'],
        });

        let savedNews: News;
        let isUpdate = false;

        if (existing) {
          // Update existing news
          existing.description = newsData.description;
          if (newsData.imageUrl) {
            existing.imageUrl = newsData.imageUrl;
          }
          existing.isPublished = newsData.isPublished ?? true;
          if (newsData.publishedAt) {
            existing.publishedAt = new Date(newsData.publishedAt);
          } else if (newsData.isPublished !== false && !existing.publishedAt) {
            existing.publishedAt = new Date();
          }

          savedNews = await newsRepository.save(existing);
          
          // Delete old contents
          if (existing.contents && existing.contents.length > 0) {
            await contentRepository.remove(existing.contents);
          }

          isUpdate = true;
          console.log(`🔄 [${i + 1}/${data.news.length}] Updated news: "${newsData.title}"`);
        } else {
          // Create new news article
          const news = new News();
          news.title = newsData.title;
          news.description = newsData.description;
          if (newsData.imageUrl) {
            news.imageUrl = newsData.imageUrl;
          }
          news.isPublished = newsData.isPublished ?? true;
          if (newsData.publishedAt) {
            news.publishedAt = new Date(newsData.publishedAt);
          } else if (newsData.isPublished !== false) {
            news.publishedAt = new Date();
          }

          savedNews = await newsRepository.save(news);
          console.log(`✅ [${i + 1}/${data.news.length}] Created news: "${newsData.title}"`);
        }

        // Create contents if provided
        if (newsData.contents && newsData.contents.length > 0) {
          const contents = newsData.contents.map((contentData) => {
            const content = new NewsContent();
            content.newsId = savedNews.id;
            content.type = contentData.type as NewsContentType;
            content.title = contentData.title || '';
            if (contentData.description) {
              content.description = contentData.description;
            }
            if (contentData.imageUrl) {
              content.imageUrl = contentData.imageUrl;
            }
            if (contentData.videoUrl) {
              content.videoUrl = contentData.videoUrl;
            }
            content.order = contentData.order;
            return content;
          });

          await contentRepository.save(contents);
          console.log(`   📝 ${isUpdate ? 'Updated' : 'Added'} ${contents.length} content blocks`);
        }

        if (isUpdate) {
          updated++;
        } else {
          imported++;
        }
      } catch (error: any) {
        console.error(`❌ [${i + 1}/${data.news.length}] Error importing "${newsData.title}":`, error.message);
        errors++;
      }
    }

    console.log('\n📊 Import Summary:');
    console.log(`   ✅ Imported: ${imported}`);
    console.log(`   🔄 Updated: ${updated}`);
    console.log(`   ⏭️  Skipped: ${skipped}`);
    console.log(`   ❌ Errors: ${errors}`);
    console.log(`   📰 Total: ${data.news.length}`);

    await AppDataSource.destroy();
    console.log('\n✅ Import completed');
    process.exit(0);
  } catch (error: any) {
    console.error('❌ Import failed:', error);
    if (error.stack) {
      console.error('Stack trace:', error.stack);
    }
    process.exit(1);
  }
}

importNews();

