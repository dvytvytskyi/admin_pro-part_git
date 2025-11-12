import express from 'express';
import { AppDataSource } from '../config/database';
import { Country } from '../entities/Country';
import { City } from '../entities/City';
import { Area } from '../entities/Area';
import { Facility } from '../entities/Facility';
import { Developer } from '../entities/Developer';
import { authenticateJWT, authenticateAPIKey } from '../middleware/auth';
import { successResponse } from '../utils/response';

const router = express.Router();

// Helper function to validate and clean URL
function validateAndCleanUrl(url: string): string | null {
  if (!url || typeof url !== 'string') return null;
  
  let cleaned = url.trim();
  
  // Remove null/undefined strings
  if (cleaned === 'null' || cleaned === 'undefined' || cleaned === '') return null;
  
  // Find first valid HTTPS URL (most common case)
  const httpsUrlMatch = cleaned.match(/https:\/\/[^\s"']+/);
  if (httpsUrlMatch) {
    cleaned = httpsUrlMatch[0];
  } else {
    // Try HTTP
    const httpUrlMatch = cleaned.match(/http:\/\/[^\s"']+/);
    if (httpUrlMatch) {
      cleaned = httpUrlMatch[0];
    }
  }
  
  // Remove trailing invalid characters (like ... or truncation markers)
  // Remove everything after file extension or common URL endings
  cleaned = cleaned.replace(/\.\.\..*$/, ''); // Remove ... and everything after
  cleaned = cleaned.replace(/(\.(jpg|jpeg|png|gif|webp))[^a-z0-9]*$/i, '$1'); // Clean after extension
  
  // Fix common truncation patterns in Cloudinary URLs
  // Pattern: ...oudinary.com or similar truncations that suggest URL corruption
  // Check if URL contains truncation markers or corrupted parts
  if (cleaned.includes('oudinary.com') || (cleaned.includes('cloudinary.com/dgv0') && !cleaned.includes('res.cloudinary.com'))) {
    // Try to extract valid Cloudinary URL pattern
    const cloudinaryMatch = cleaned.match(/https?:\/\/res\.cloudinary\.com\/[^\s"']+/);
    if (cloudinaryMatch) {
      cleaned = cloudinaryMatch[0];
    } else {
      // If we can't find valid pattern, return null
      return null;
    }
  }
  
  // Check for truncation in the middle of URL (like "...oudinary.com")
  // Extract only the part before truncation
  if (cleaned.includes('...') && !cleaned.endsWith('...')) {
    // URL has truncation in the middle - extract valid part
    const beforeTruncation = cleaned.substring(0, cleaned.indexOf('...'));
    // Try to find valid URL ending (file extension or path end)
    const extensionMatch = beforeTruncation.match(/^(.+\.(jpg|jpeg|png|gif|webp))/i);
    if (extensionMatch) {
      cleaned = extensionMatch[1];
    } else {
      // No extension, try to find last valid path segment
      const lastSlash = beforeTruncation.lastIndexOf('/');
      if (lastSlash > 0) {
        cleaned = beforeTruncation.substring(0, lastSlash + 1);
      } else {
        cleaned = beforeTruncation;
      }
    }
  }
  
  // Validate URL format
  try {
    const urlObj = new URL(cleaned);
    
    // Ensure it's a valid HTTP/HTTPS URL
    if (!['http:', 'https:'].includes(urlObj.protocol)) return null;
    
    // Ensure it has a valid hostname
    if (!urlObj.hostname || urlObj.hostname.length === 0) return null;
    
    // Ensure hostname doesn't contain truncation markers
    if (urlObj.hostname.includes('...') || urlObj.hostname.endsWith('.')) return null;
    
    // Ensure pathname is valid (doesn't contain truncation markers in the middle)
    if (urlObj.pathname.includes('...')) {
      // Try to extract valid part before truncation
      const validPath = urlObj.pathname.substring(0, urlObj.pathname.indexOf('...'));
      if (validPath.length > 0) {
        urlObj.pathname = validPath;
        cleaned = urlObj.toString();
      } else {
        return null;
      }
    }
    
    return cleaned;
  } catch (e) {
    // URL parsing failed - try simpler validation
    // Check if it looks like a valid URL
    if (cleaned.match(/^https?:\/\/[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}/)) {
      // Basic URL format is OK, but couldn't parse - might be valid
      // Try to extract just the domain and basic path
      const simpleMatch = cleaned.match(/^(https?:\/\/[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}[^\s"']*)/);
      if (simpleMatch) {
        return simpleMatch[1];
      }
    }
    return null;
  }
}

// Helper function to parse images from PostgreSQL text[] or simple-array
// Handles multiple formats and validates/cleans URLs
function parseImages(images: any): string[] | null {
  if (!images) return null;
  
  // If already an array (TypeORM automatically parsed or PostgreSQL text[] returned as array)
  if (Array.isArray(images)) {
    const parsed = images
      .map(img => {
        // Handle both string URLs and objects
        if (typeof img === 'string') return validateAndCleanUrl(img);
        if (typeof img === 'object' && img !== null && img.url) return validateAndCleanUrl(String(img.url));
        if (img !== null && img !== undefined) return validateAndCleanUrl(String(img));
        return null;
      })
      .filter((url): url is string => url !== null);
    return parsed.length > 0 ? parsed : null;
  }
  
  // If it's a string
  if (typeof images === 'string') {
    // PostgreSQL array format: "{url1,url2,url3}" or '{"url1","url2","url3"}'
    if (images.startsWith('{') && images.endsWith('}')) {
      const content = images.slice(1, -1); // Remove { and }
      if (content.trim().length === 0) return null;
      const urls = content
        .split(',')
        .map(url => url.trim().replace(/^["']|["']$/g, '')) // Remove quotes
        .map(url => validateAndCleanUrl(url))
        .filter((url): url is string => url !== null);
      return urls.length > 0 ? urls : null;
    }
    
    // JSON array string: '["url1","url2"]'
    if (images.startsWith('[') && images.endsWith(']')) {
      try {
        const parsed = JSON.parse(images);
        if (Array.isArray(parsed)) {
          const urls = parsed
            .map(url => validateAndCleanUrl(String(url)))
            .filter((url): url is string => url !== null);
          return urls.length > 0 ? urls : null;
        }
      } catch (e) {
        // Not valid JSON, continue to other formats
      }
    }
    
    // Comma-separated string (simple-array format): "url1,url2,url3"
    if (images.includes(',')) {
      const urls = images
        .split(',')
        .map(url => validateAndCleanUrl(url.trim()))
        .filter((url): url is string => url !== null);
      return urls.length > 0 ? urls : null;
    }
    
    // Single URL
    const cleaned = validateAndCleanUrl(images);
    return cleaned ? [cleaned] : null;
  }
  
  return null;
}

router.use((req, res, next) => {
  const apiKey = req.headers['x-api-key'];
  if (apiKey) return authenticateAPIKey(req, res, next);
  return authenticateJWT(req, res, next);
});

router.get('/countries', async (req, res) => {
  const countries = await AppDataSource.getRepository(Country).find({ relations: ['cities'] });
  res.json(successResponse(countries));
});

router.get('/cities', async (req, res) => {
  const { countryId } = req.query;
  const where: any = countryId ? { countryId } : {};
  const cities = await AppDataSource.getRepository(City).find({ where, relations: ['areas'] });
  res.json(successResponse(cities));
});

router.get('/areas', async (req, res) => {
  try {
    const { cityId } = req.query;
    
    // Use raw query to get areas with description, infrastructure, images
    const queryRunner = AppDataSource.createQueryRunner();
    await queryRunner.connect();
    
    try {
      let whereClause = '';
      const whereParams: any[] = [];
      if (cityId) {
        whereClause = 'WHERE area."cityId" = $1';
        whereParams.push(cityId);
      }
      
      const areasRaw = await queryRunner.query(`
        SELECT 
          area.id,
          area."cityId",
          area."nameEn",
          area."nameRu",
          area."nameAr",
          area.description,
          area.infrastructure,
          area.images
        FROM areas area
        ${whereClause}
        ORDER BY area."nameEn" ASC
      `, whereParams);
      
      // Convert raw results to Area-like objects
      const areas = areasRaw.map((row: any) => ({
        id: row.id,
        cityId: row.cityId,
        nameEn: row.nameEn,
        nameRu: row.nameRu,
        nameAr: row.nameAr,
        description: row.description || null,
        infrastructure: row.infrastructure || null,
        images: parseImages(row.images),
      }));
      
      res.json(successResponse(areas));
    } finally {
      await queryRunner.release();
    }
  } catch (error: any) {
    console.error('Error loading areas:', error);
    res.status(500).json({ success: false, message: error.message || 'Failed to load areas' });
  }
});

// Combined endpoint for locations (countries, cities, areas)
router.get('/locations', async (req, res) => {
  try {
    const countries = await AppDataSource.getRepository(Country).find({ relations: ['cities'] });
    const cities = await AppDataSource.getRepository(City).find({ relations: ['areas'] });
    
    // Use raw query to get areas with description, infrastructure, images
    // (handles case when columns might not exist in some environments)
    const queryRunner = AppDataSource.createQueryRunner();
    await queryRunner.connect();
    
    try {
      const areasRaw = await queryRunner.query(`
        SELECT 
          area.id,
          area."cityId",
          area."nameEn",
          area."nameRu",
          area."nameAr",
          area.description,
          area.infrastructure,
          area.images
        FROM areas area
        ORDER BY area."nameEn" ASC
      `);
      
      // Convert raw results to Area-like objects
      const areas = areasRaw.map((row: any) => ({
        id: row.id,
        cityId: row.cityId,
        nameEn: row.nameEn,
        nameRu: row.nameRu,
        nameAr: row.nameAr,
        description: row.description || null,
        infrastructure: row.infrastructure || null,
        images: parseImages(row.images),
      }));
      
      res.json(successResponse({
        countries,
        cities,
        areas
      }));
    } finally {
      await queryRunner.release();
    }
  } catch (error: any) {
    console.error('Error loading locations:', error);
    res.status(500).json({ success: false, message: error.message || 'Failed to load locations' });
  }
});

router.post('/countries', async (req, res) => {
  try {
    const { nameEn, nameRu, nameAr, code } = req.body;
    
    if (!nameEn || !code) {
      return res.status(400).json({ success: false, message: 'Country name (nameEn) and code are required' });
    }
    
    const country = await AppDataSource.getRepository(Country).save({
      nameEn: nameEn.trim(),
      nameRu: nameRu || nameEn.trim(),
      nameAr: nameAr || nameEn.trim(),
      code: code.trim().toUpperCase(),
    });
    
    res.json(successResponse(country));
  } catch (error: any) {
    console.error('Error creating country:', error);
    res.status(500).json({ success: false, message: error.message || 'Failed to create country' });
  }
});

router.post('/cities', async (req, res) => {
  try {
    const { nameEn, nameRu, nameAr, countryId } = req.body;
    
    if (!nameEn || !countryId) {
      return res.status(400).json({ success: false, message: 'City name (nameEn) and countryId are required' });
    }
    
    const city = await AppDataSource.getRepository(City).save({
      nameEn: nameEn.trim(),
      nameRu: nameRu || nameEn.trim(),
      nameAr: nameAr || nameEn.trim(),
      countryId: countryId,
    });
    
    res.json(successResponse(city));
  } catch (error: any) {
    console.error('Error creating city:', error);
    res.status(500).json({ success: false, message: error.message || 'Failed to create city' });
  }
});

router.post('/areas', async (req, res) => {
  try {
    const { nameEn, nameRu, nameAr, cityId } = req.body;
    
    if (!nameEn || !cityId) {
      return res.status(400).json({ success: false, message: 'Area name (nameEn) and cityId are required' });
    }
    
    const area = await AppDataSource.getRepository(Area).save({
      nameEn: nameEn.trim(),
      nameRu: nameRu || nameEn.trim(),
      nameAr: nameAr || nameEn.trim(),
      cityId: cityId,
    });
    
    res.json(successResponse(area));
  } catch (error: any) {
    console.error('Error creating area:', error);
    res.status(500).json({ success: false, message: error.message || 'Failed to create area' });
  }
});

router.delete('/countries/:id', async (req, res) => {
  try {
    const country = await AppDataSource.getRepository(Country).findOne({
      where: { id: req.params.id },
    });
    
    if (!country) {
      return res.status(404).json({ success: false, message: 'Country not found' });
    }
    
    await AppDataSource.getRepository(Country).remove(country);
    res.json(successResponse(null, 'Country deleted successfully'));
  } catch (error: any) {
    console.error('Error deleting country:', error);
    res.status(500).json({ success: false, message: error.message || 'Failed to delete country' });
  }
});

router.delete('/cities/:id', async (req, res) => {
  try {
    const city = await AppDataSource.getRepository(City).findOne({
      where: { id: req.params.id },
    });
    
    if (!city) {
      return res.status(404).json({ success: false, message: 'City not found' });
    }
    
    await AppDataSource.getRepository(City).remove(city);
    res.json(successResponse(null, 'City deleted successfully'));
  } catch (error: any) {
    console.error('Error deleting city:', error);
    res.status(500).json({ success: false, message: error.message || 'Failed to delete city' });
  }
});

// GET /settings/areas/:id - Get single area by ID
router.get('/areas/:id', async (req, res) => {
  try {
    const { id } = req.params;
    
    // Use raw query to get area with description, infrastructure, images
    const queryRunner = AppDataSource.createQueryRunner();
    await queryRunner.connect();
    
    try {
      const areaRaw = await queryRunner.query(`
        SELECT 
          area.id,
          area."cityId",
          area."nameEn",
          area."nameRu",
          area."nameAr",
          area.description,
          area.infrastructure,
          area.images
        FROM areas area
        WHERE area.id = $1
      `, [id]);
      
      if (areaRaw.length === 0) {
        return res.status(404).json({ success: false, message: 'Area not found' });
      }
      
      const row = areaRaw[0];
      const area = {
        id: row.id,
        cityId: row.cityId,
        nameEn: row.nameEn,
        nameRu: row.nameRu,
        nameAr: row.nameAr,
        description: row.description || null,
        infrastructure: row.infrastructure || null,
        images: parseImages(row.images),
      };
      
      res.json(successResponse(area));
    } finally {
      await queryRunner.release();
    }
  } catch (error: any) {
    console.error('Error loading area:', error);
    res.status(500).json({ success: false, message: error.message || 'Failed to load area' });
  }
});

router.put('/areas/:id', async (req, res) => {
  try {
    const { nameEn, nameRu, nameAr, cityId, description, infrastructure, images } = req.body;
    
    const area = await AppDataSource.getRepository(Area).findOne({
      where: { id: req.params.id },
    });
    
    if (!area) {
      return res.status(404).json({ success: false, message: 'Area not found' });
    }
    
    // Оновлюємо тільки передані поля
    if (nameEn !== undefined) area.nameEn = nameEn.trim();
    if (nameRu !== undefined) area.nameRu = nameRu.trim();
    if (nameAr !== undefined) area.nameAr = nameAr.trim();
    if (cityId !== undefined) area.cityId = cityId;
    if (description !== undefined) area.description = description;
    if (infrastructure !== undefined) area.infrastructure = infrastructure;
    if (images !== undefined) {
      // Validate images array
      if (!Array.isArray(images)) {
        return res.status(400).json({ success: false, message: 'Images must be an array' });
      }
      
      // Перевірка що не більше 8 фото
      if (images.length > 8) {
        return res.status(400).json({ success: false, message: 'Maximum 8 images allowed' });
      }
      
      // Validate and clean each URL
      const validatedImages = images
        .map((url: any) => validateAndCleanUrl(String(url)))
        .filter((url): url is string => url !== null);
      
      if (validatedImages.length !== images.length) {
        return res.status(400).json({ 
          success: false, 
          message: 'Some image URLs are invalid. Please check all URLs are valid HTTP/HTTPS URLs.' 
        });
      }
      
      area.images = validatedImages;
    }
    
    const updatedArea = await AppDataSource.getRepository(Area).save(area);
    res.json(successResponse(updatedArea));
  } catch (error: any) {
    console.error('Error updating area:', error);
    res.status(500).json({ success: false, message: error.message || 'Failed to update area' });
  }
});

router.delete('/areas/:id', async (req, res) => {
  try {
    const area = await AppDataSource.getRepository(Area).findOne({
      where: { id: req.params.id },
    });
    
    if (!area) {
      return res.status(404).json({ success: false, message: 'Area not found' });
    }
    
    await AppDataSource.getRepository(Area).remove(area);
    res.json(successResponse(null, 'Area deleted successfully'));
  } catch (error: any) {
    console.error('Error deleting area:', error);
    res.status(500).json({ success: false, message: error.message || 'Failed to delete area' });
  }
});

router.get('/facilities', async (req, res) => {
  const facilities = await AppDataSource.getRepository(Facility).find();
  res.json(successResponse(facilities));
});

router.post('/facilities', async (req, res) => {
  try {
    const { nameEn, nameRu, nameAr, iconName } = req.body;
    
    if (!nameEn || typeof nameEn !== 'string' || !nameEn.trim()) {
      return res.status(400).json({ success: false, message: 'Facility name (nameEn) is required' });
    }
    
    const facility = await AppDataSource.getRepository(Facility).save({
      nameEn: nameEn.trim(),
      nameRu: nameRu || nameEn.trim(),
      nameAr: nameAr || nameEn.trim(),
      iconName: iconName || nameEn.toLowerCase().replace(/\s+/g, '-'),
    });
    
    res.json(successResponse(facility));
  } catch (error: any) {
    console.error('Error creating facility:', error);
    res.status(500).json({ success: false, message: error.message || 'Failed to create facility' });
  }
});

router.delete('/facilities/:id', async (req, res) => {
  try {
    const facility = await AppDataSource.getRepository(Facility).findOne({
      where: { id: req.params.id },
    });
    
    if (!facility) {
      return res.status(404).json({ success: false, message: 'Facility not found' });
    }
    
    await AppDataSource.getRepository(Facility).remove(facility);
    res.json(successResponse(null, 'Facility deleted successfully'));
  } catch (error: any) {
    console.error('Error deleting facility:', error);
    res.status(500).json({ success: false, message: error.message || 'Failed to delete facility' });
  }
});

router.get('/developers', async (req, res) => {
  const developers = await AppDataSource.getRepository(Developer).find();
  res.json(successResponse(developers));
});

router.post('/developers', async (req, res) => {
  try {
    const { name } = req.body;
    
    if (!name || typeof name !== 'string' || !name.trim()) {
      return res.status(400).json({ success: false, message: 'Developer name is required' });
    }
    
    // Check if developer with this name already exists
    const existingDeveloper = await AppDataSource.getRepository(Developer).findOne({
      where: { name: name.trim() },
    });
    
    if (existingDeveloper) {
      return res.status(409).json({ success: false, message: 'Developer with this name already exists' });
    }
    
    const developer = await AppDataSource.getRepository(Developer).save({
      name: name.trim(),
    });
    
    res.json(successResponse(developer));
  } catch (error: any) {
    console.error('Error creating developer:', error);
    
    // Handle unique constraint violation
    if (error.code === '23505' || error.message?.includes('UNIQUE constraint')) {
      return res.status(409).json({ success: false, message: 'Developer with this name already exists' });
    }
    
    res.status(500).json({ success: false, message: error.message || 'Failed to create developer' });
  }
});

router.put('/developers/:id', async (req, res) => {
  try {
    const { name, logo, description, images } = req.body;

    const developer = await AppDataSource.getRepository(Developer).findOne({
      where: { id: req.params.id },
    });

    if (!developer) {
      return res.status(404).json({ success: false, message: 'Developer not found' });
    }

    // Update only provided fields
    if (name !== undefined) developer.name = name.trim();
    if (logo !== undefined) developer.logo = logo || '';
    if (description !== undefined) developer.description = description || '';
    if (images !== undefined) {
      // Validate images array
      if (Array.isArray(images)) {
        developer.images = images;
      } else {
        developer.images = undefined;
      }
    }

    const updatedDeveloper = await AppDataSource.getRepository(Developer).save(developer);
    res.json(successResponse(updatedDeveloper));
  } catch (error: any) {
    console.error('Error updating developer:', error);
    res.status(500).json({ success: false, message: error.message || 'Failed to update developer' });
  }
});

router.delete('/developers/:id', async (req, res) => {
  try {
    const developer = await AppDataSource.getRepository(Developer).findOne({
      where: { id: req.params.id },
    });
    
    if (!developer) {
      return res.status(404).json({ success: false, message: 'Developer not found' });
    }
    
    await AppDataSource.getRepository(Developer).remove(developer);
    res.json(successResponse(null, 'Developer deleted successfully'));
  } catch (error: any) {
    console.error('Error deleting developer:', error);
    res.status(500).json({ success: false, message: error.message || 'Failed to delete developer' });
  }
});

// Endpoint to clean up duplicate developers (keep only first occurrence of each name)
router.post('/developers/cleanup-duplicates', async (req, res) => {
  try {
    const developerRepository = AppDataSource.getRepository(Developer);
    const allDevelopers = await developerRepository.find({
      order: { createdAt: 'ASC' }, // Keep the oldest one
    });
    
    const seenNames = new Set<string>();
    const duplicatesToDelete: Developer[] = [];
    let kept = 0;
    let deleted = 0;
    
    for (const dev of allDevelopers) {
      const normalizedName = dev.name.trim().toLowerCase();
      
      if (seenNames.has(normalizedName)) {
        duplicatesToDelete.push(dev);
        deleted++;
      } else {
        seenNames.add(normalizedName);
        kept++;
      }
    }
    
    if (duplicatesToDelete.length > 0) {
      await developerRepository.remove(duplicatesToDelete);
    }
    
    res.json(successResponse({
      kept,
      deleted,
      totalBefore: allDevelopers.length,
      totalAfter: kept,
    }, `Removed ${deleted} duplicate developers, kept ${kept} unique developers`));
  } catch (error: any) {
    console.error('Error cleaning up duplicates:', error);
    res.status(500).json({ success: false, message: error.message || 'Failed to clean up duplicates' });
  }
});

export default router;

