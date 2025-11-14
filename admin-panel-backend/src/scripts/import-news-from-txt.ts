import 'reflect-metadata';
import * as fs from 'fs';
import * as path from 'path';
import { AppDataSource } from '../config/database';
import { News } from '../entities/News';
import { NewsContent, NewsContentType } from '../entities/NewsContent';

// Stock images from Unsplash (free stock photos)
const STOCK_IMAGES = [
  'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?w=1200&h=800&fit=crop',
  'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=1200&h=800&fit=crop',
  'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=1200&h=800&fit=crop',
  'https://images.unsplash.com/photo-1497366216548-37526070297c?w=1200&h=800&fit=crop',
  'https://images.unsplash.com/photo-1497366754035-f200968a6e72?w=1200&h=800&fit=crop',
  'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=1200&h=800&fit=crop',
  'https://images.unsplash.com/photo-1512918728675-ed5a9ecdebfd?w=1200&h=800&fit=crop',
  'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=1200&h=800&fit=crop',
  'https://images.unsplash.com/photo-1480714378408-67cf0d13bc1b?w=1200&h=800&fit=crop',
  'https://images.unsplash.com/photo-1499793983690-e29da59ef1c2?w=1200&h=800&fit=crop',
  'https://images.unsplash.com/photo-1503387762-592deb58ef4e?w=1200&h=800&fit=crop',
  'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=1200&h=800&fit=crop',
  'https://images.unsplash.com/photo-1513584684374-8bab748fbf90?w=1200&h=800&fit=crop',
  'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=1200&h=800&fit=crop',
  'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=1200&h=800&fit=crop',
  'https://images.unsplash.com/photo-1497366216548-37526070297c?w=1200&h=800&fit=crop',
  'https://images.unsplash.com/photo-1497366754035-f200968a6e72?w=1200&h=800&fit=crop',
  'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=1200&h=800&fit=crop',
  'https://images.unsplash.com/photo-1512918728675-ed5a9ecdebfd?w=1200&h=800&fit=crop',
  'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=1200&h=800&fit=crop',
  'https://images.unsplash.com/photo-1480714378408-67cf0d13bc1b?w=1200&h=800&fit=crop',
  'https://images.unsplash.com/photo-1499793983690-e29da59ef1c2?w=1200&h=800&fit=crop',
  'https://images.unsplash.com/photo-1503387762-592deb58ef4e?w=1200&h=800&fit=crop',
  'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=1200&h=800&fit=crop',
  'https://images.unsplash.com/photo-1513584684374-8bab748fbf90?w=1200&h=800&fit=crop',
  'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=1200&h=800&fit=crop',
  'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=1200&h=800&fit=crop',
  'https://images.unsplash.com/photo-1497366216548-37526070297c?w=1200&h=800&fit=crop',
  'https://images.unsplash.com/photo-1497366754035-f200968a6e72?w=1200&h=800&fit=crop',
  'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=1200&h=800&fit=crop',
  'https://images.unsplash.com/photo-1512918728675-ed5a9ecdebfd?w=1200&h=800&fit=crop',
];

interface NewsArticle {
  title: string;
  description: string;
  imageUrl: string;
  contents: Array<{
    type: NewsContentType;
    title: string;
    description: string | null;
    order: number;
  }>;
}

function parseNewsFile(filePath: string): NewsArticle[] {
  const content = fs.readFileSync(filePath, 'utf-8');
  const lines = content.split('\n');
  
  const articles: NewsArticle[] = [];
  let currentArticle: Partial<NewsArticle> | null = null;
  let currentContents: Array<{ type: NewsContentType; title: string; description: string | null; order: number }> = [];
  let currentSectionTitle: string | null = null;
  let currentSectionText: string[] = [];
  let orderCounter = 0;
  let articleIndex = 0;

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i].trim();
    
    // Check if this is a new article marker
    if (line.match(/^Стаття \d+$/)) {
      // Save previous article if exists
      if (currentArticle && currentArticle.title) {
        // Save last section if exists
        if (currentSectionTitle && currentSectionText.length > 0) {
          currentContents.push({
            type: NewsContentType.TEXT,
            title: currentSectionTitle,
            description: currentSectionText.join('\n').trim() || null,
            order: orderCounter++,
          });
        }
        
        articles.push({
          title: currentArticle.title,
          description: currentArticle.description || '',
          imageUrl: currentArticle.imageUrl || STOCK_IMAGES[articleIndex % STOCK_IMAGES.length],
          contents: currentContents,
        });
        articleIndex++;
      }
      
      // Start new article
      currentArticle = {};
      currentContents = [];
      currentSectionTitle = null;
      currentSectionText = [];
      orderCounter = 0;
      
      // Next line should be the title
      if (i + 1 < lines.length) {
        const titleLine = lines[i + 1].trim();
        if (titleLine && !titleLine.match(/^Стаття \d+$/)) {
          currentArticle.title = titleLine;
          currentArticle.description = ''; // Will be set from first paragraph
          currentArticle.imageUrl = STOCK_IMAGES[articleIndex % STOCK_IMAGES.length];
          i++; // Skip title line
        }
      }
      continue;
    }
    
    // Skip empty lines
    if (!line) {
      // If we have accumulated text, it might be end of section
      if (currentSectionText.length > 0 && currentSectionTitle) {
        currentContents.push({
          type: NewsContentType.TEXT,
          title: currentSectionTitle,
          description: currentSectionText.join('\n').trim() || null,
          order: orderCounter++,
        });
        currentSectionText = [];
        currentSectionTitle = null;
      }
      continue;
    }
    
    // Check if line looks like a section title (short, no period at end, might be followed by empty line)
    const isLikelyTitle = line.length < 100 && 
                         !line.endsWith('.') && 
                         !line.endsWith(';') &&
                         !line.match(/^[–—]/) &&
                         (i + 1 >= lines.length || lines[i + 1].trim() === '' || lines[i + 1].trim().match(/^[–—]/));
    
    if (isLikelyTitle && currentSectionText.length === 0 && !currentSectionTitle) {
      // This is likely a section title
      currentSectionTitle = line;
    } else {
      // This is content
      if (!currentSectionTitle) {
        // If no section title yet, use first line as title or create default
        if (currentContents.length === 0) {
          currentSectionTitle = 'Вступ';
          currentArticle!.description = line; // First paragraph as description
        } else {
          currentSectionTitle = 'Продовження';
        }
      }
      currentSectionText.push(line);
    }
  }
  
  // Save last article
  if (currentArticle && currentArticle.title) {
    if (currentSectionTitle && currentSectionText.length > 0) {
      currentContents.push({
        type: NewsContentType.TEXT,
        title: currentSectionTitle,
        description: currentSectionText.join('\n').trim() || null,
        order: orderCounter++,
      });
    }
    
    articles.push({
      title: currentArticle.title,
      description: currentArticle.description || '',
      imageUrl: currentArticle.imageUrl || STOCK_IMAGES[articleIndex % STOCK_IMAGES.length],
      contents: currentContents,
    });
  }
  
  return articles;
}

async function importNews() {
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
      console.log('   Skipping import. If you want to import anyway, clear the table first.\n');
      await AppDataSource.destroy();
      return;
    }

    // Find news-upload.txt file
    const possiblePaths = [
      path.resolve(__dirname, '../../../news-upload.txt'),
      path.resolve(process.cwd(), 'news-upload.txt'),
      '/app/news-upload.txt',
      path.join(process.cwd(), 'news-upload.txt'),
    ];

    let txtPath: string | null = null;
    for (const possiblePath of possiblePaths) {
      if (fs.existsSync(possiblePath)) {
        txtPath = possiblePath;
        break;
      }
    }

    if (!txtPath) {
      throw new Error(`File not found. Tried: ${possiblePaths.join(', ')}`);
    }

    console.log(`📖 Reading file: ${txtPath}`);
    const articles = parseNewsFile(txtPath);
    console.log(`✅ Parsed ${articles.length} articles\n`);

    console.log('🚀 Starting import...\n');

    let successCount = 0;
    let errorCount = 0;
    const errors: string[] = [];

    for (let i = 0; i < articles.length; i++) {
      const article = articles[i];
      
      try {
        // Create news article
        const news = newsRepository.create({
          title: article.title,
          description: article.description,
          imageUrl: article.imageUrl,
          isPublished: true,
          publishedAt: new Date(),
        });

        const savedNews = await newsRepository.save(news);

        // Create news contents
        if (article.contents.length > 0) {
          const contents = article.contents.map(content => 
            contentRepository.create({
              newsId: savedNews.id,
              type: content.type,
              title: content.title,
              description: content.description,
              order: content.order,
            })
          );

          await contentRepository.save(contents);
        }

        successCount++;
        console.log(`✅ [${i + 1}/${articles.length}] Imported: ${article.title.substring(0, 50)}...`);
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

importNews();

