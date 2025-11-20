import express from 'express';
import { AppDataSource } from '../config/database';
import { News } from '../entities/News';
import { NewsContent } from '../entities/NewsContent';
import { authenticateJWT, authenticateAPIKey } from '../middleware/auth';
import { successResponse } from '../utils/response';

const router = express.Router();

router.use((req, res, next) => {
  const apiKey = req.headers['x-api-key'];
  if (apiKey) return authenticateAPIKey(req, res, next);
  return authenticateJWT(req, res, next);
});

router.get('/', async (req, res) => {
  try {
    const newsRepository = AppDataSource.getRepository(News);
    const news = await newsRepository.find({
      relations: ['contents'],
      order: {
        createdAt: 'DESC',
      },
    });
    
    console.log(`[News API] GET /news - Found ${news.length} articles`);
    res.json(successResponse(news));
  } catch (error: any) {
    console.error('[News API] Error fetching news:', error);
    res.status(500).json({ success: false, message: error.message || 'Failed to fetch news' });
  }
});

router.get('/:id', async (req, res) => {
  const newsItem = await AppDataSource.getRepository(News).findOne({
    where: { id: req.params.id },
    relations: ['contents'],
  });
  res.json(successResponse(newsItem));
});

router.post('/', async (req, res) => {
  try {
    console.log('[News API] POST /news - Request received');
    console.log('[News API] Request body:', {
      hasTitle: !!req.body.title,
      hasDescription: !!req.body.description,
      hasImageUrl: !!req.body.imageUrl,
      isPublished: req.body.isPublished,
      contentsCount: req.body.contents ? (Array.isArray(req.body.contents) ? req.body.contents.length : 'not array') : 0,
    });

    // Validation
    if (!req.body.title || typeof req.body.title !== 'string' || req.body.title.trim().length === 0) {
      console.error('[News API] ❌ Validation failed: title is required');
      return res.status(400).json({ 
        success: false, 
        message: 'Title is required and must be a non-empty string' 
      });
    }

    if (!req.body.description || typeof req.body.description !== 'string' || req.body.description.trim().length === 0) {
      console.error('[News API] ❌ Validation failed: description is required');
      return res.status(400).json({ 
        success: false, 
        message: 'Description is required and must be a non-empty string' 
      });
    }

    const newsRepository = AppDataSource.getRepository(News);
    const contentRepository = AppDataSource.getRepository(NewsContent);
    
    const { contents, ...newsData } = req.body;
    
    // Validate and prepare news data
    const isPublished = newsData.isPublished === true || newsData.isPublished === 'true';
    const publishedAt = isPublished ? (newsData.publishedAt ? new Date(newsData.publishedAt) : new Date()) : undefined;

    console.log('[News API] Creating news item:', {
      title: newsData.title.trim().substring(0, 50) + '...',
      descriptionLength: newsData.description.trim().length,
      hasImageUrl: !!newsData.imageUrl,
      isPublished: isPublished,
      hasPublishedAt: !!publishedAt,
    });
    
    // Create news item
    const newsItem = newsRepository.create({
      title: newsData.title.trim(),
      description: newsData.description.trim(),
      imageUrl: newsData.imageUrl && typeof newsData.imageUrl === 'string' ? newsData.imageUrl.trim() : null,
      isPublished: isPublished,
      publishedAt: publishedAt,
    });
    const savedNews = await newsRepository.save(newsItem);
    console.log('[News API] ✅ News item created with ID:', savedNews.id);
    
    // Create contents if provided
    if (contents && Array.isArray(contents) && contents.length > 0) {
      console.log('[News API] Creating contents:', contents.length);
      
      const newsContents = contents.map((content: any, index: number) => {
        // Validate content type
        const validTypes = ['text', 'image', 'video'];
        const contentType = validTypes.includes(content.type) ? content.type : 'text';
        
        // Validate required fields
        if (!content.title || typeof content.title !== 'string') {
          console.warn(`[News API] ⚠️ Content ${index} missing title, using default`);
        }

        return contentRepository.create({
          newsId: savedNews.id,
          type: contentType,
          title: content.title && typeof content.title === 'string' ? content.title.trim() : `Section ${index + 1}`,
          description: content.description && typeof content.description === 'string' ? content.description.trim() : null,
          imageUrl: content.imageUrl && typeof content.imageUrl === 'string' ? content.imageUrl.trim() : null,
          videoUrl: content.videoUrl && typeof content.videoUrl === 'string' ? content.videoUrl.trim() : null,
          order: typeof content.order === 'number' ? content.order : index,
        });
      });
      
      await contentRepository.save(newsContents);
      console.log('[News API] ✅ Contents created:', newsContents.length);
    } else {
      console.log('[News API] No contents provided');
    }
    
    // Fetch with relations to return complete data
    const completeNews = await newsRepository.findOne({
      where: { id: savedNews.id },
      relations: ['contents'],
    });
    
    if (!completeNews) {
      console.error('[News API] ❌ Failed to fetch created news');
      return res.status(500).json({ 
        success: false, 
        message: 'News was created but could not be retrieved' 
      });
    }

    console.log('[News API] ✅ News created successfully:', {
      id: completeNews.id,
      title: completeNews.title.substring(0, 50) + '...',
      contentsCount: completeNews.contents?.length || 0,
    });
    
    res.json(successResponse(completeNews));
  } catch (error: any) {
    console.error('[News API] ❌ Error creating news:', error);
    console.error('[News API] Error details:', {
      message: error.message,
      stack: error.stack,
      name: error.name,
    });
    
    // Check for specific database errors
    if (error.code === '23505') { // Unique constraint violation
      return res.status(400).json({ 
        success: false, 
        message: 'A news article with this title already exists' 
      });
    }
    
    if (error.code === '23502') { // Not null violation
      return res.status(400).json({ 
        success: false, 
        message: `Missing required field: ${error.column}` 
      });
    }
    
    res.status(500).json({ 
      success: false, 
      message: error.message || 'Failed to create news',
      error: process.env.NODE_ENV === 'development' ? error.stack : undefined,
    });
  }
});

router.patch('/:id', async (req, res) => {
  try {
    console.log('[News API] PATCH /news/:id - Request received', { id: req.params.id });
    
    const newsRepository = AppDataSource.getRepository(News);
    const contentRepository = AppDataSource.getRepository(NewsContent);
    
    const { contents, ...newsData } = req.body;
    
    // Check if news exists
    const existingNews = await newsRepository.findOne({
      where: { id: req.params.id },
      relations: ['contents'],
    });
    
    if (!existingNews) {
      console.error('[News API] ❌ News not found:', req.params.id);
      return res.status(404).json({ success: false, message: 'News not found' });
    }
    
    // Validate and update news fields
    if (newsData.title !== undefined) {
      if (typeof newsData.title !== 'string' || newsData.title.trim().length === 0) {
        return res.status(400).json({ 
          success: false, 
          message: 'Title must be a non-empty string' 
        });
      }
      existingNews.title = newsData.title.trim();
    }
    
    if (newsData.description !== undefined) {
      if (typeof newsData.description !== 'string' || newsData.description.trim().length === 0) {
        return res.status(400).json({ 
          success: false, 
          message: 'Description must be a non-empty string' 
        });
      }
      existingNews.description = newsData.description.trim();
    }
    
    if (newsData.imageUrl !== undefined) {
      existingNews.imageUrl = newsData.imageUrl && typeof newsData.imageUrl === 'string' 
        ? newsData.imageUrl.trim() 
        : null;
    }
    
    if (newsData.isPublished !== undefined) {
      existingNews.isPublished = newsData.isPublished === true || newsData.isPublished === 'true';
    }
    
    if (newsData.publishedAt !== undefined && newsData.publishedAt !== null) {
      existingNews.publishedAt = new Date(newsData.publishedAt);
    } else if (newsData.publishedAt === null) {
      existingNews.publishedAt = null as any;
    }
    
    await newsRepository.save(existingNews);
    console.log('[News API] ✅ News updated:', req.params.id);
    
    // Handle contents update
    if (contents !== undefined) {
      // Delete existing contents
      if (existingNews.contents && existingNews.contents.length > 0) {
        await contentRepository.remove(existingNews.contents);
        console.log('[News API] Removed old contents:', existingNews.contents.length);
      }
      
      // Create new contents if provided
      if (Array.isArray(contents) && contents.length > 0) {
        const validTypes = ['text', 'image', 'video'];
        const newsContents = contents.map((content: any, index: number) => {
          const contentType = validTypes.includes(content.type) ? content.type : 'text';
          
          return contentRepository.create({
            newsId: existingNews.id,
            type: contentType,
            title: content.title && typeof content.title === 'string' 
              ? content.title.trim() 
              : `Section ${index + 1}`,
            description: content.description && typeof content.description === 'string' 
              ? content.description.trim() 
              : null,
            imageUrl: content.imageUrl && typeof content.imageUrl === 'string' 
              ? content.imageUrl.trim() 
              : null,
            videoUrl: content.videoUrl && typeof content.videoUrl === 'string' 
              ? content.videoUrl.trim() 
              : null,
            order: typeof content.order === 'number' ? content.order : index,
          });
        });
        
        await contentRepository.save(newsContents);
        console.log('[News API] ✅ Contents updated:', newsContents.length);
      }
    }
    
    // Fetch updated news with relations
    const updatedNews = await newsRepository.findOne({
      where: { id: req.params.id },
      relations: ['contents'],
    });
    
    if (!updatedNews) {
      console.error('[News API] ❌ Failed to fetch updated news');
      return res.status(500).json({ 
        success: false, 
        message: 'News was updated but could not be retrieved' 
      });
    }
    
    res.json(successResponse(updatedNews));
  } catch (error: any) {
    console.error('[News API] ❌ Error updating news:', error);
    console.error('[News API] Error details:', {
      message: error.message,
      stack: error.stack,
      name: error.name,
    });
    
    res.status(500).json({ 
      success: false, 
      message: error.message || 'Failed to update news',
      error: process.env.NODE_ENV === 'development' ? error.stack : undefined,
    });
  }
});

router.delete('/:id', async (req, res) => {
  await AppDataSource.getRepository(News).delete(req.params.id);
  res.json(successResponse(null, 'News deleted'));
});

export default router;

