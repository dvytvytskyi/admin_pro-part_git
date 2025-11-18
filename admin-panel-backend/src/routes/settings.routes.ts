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

// Helper function to parse PostgreSQL array string to JavaScript array
const parseArray = (arr: any): string[] | null => {
  if (!arr) return null;
  if (Array.isArray(arr)) {
    // Filter out invalid values and ensure all are valid URLs
    return arr
      .filter((item: any) => {
        // Remove empty values, null, undefined, '{}', '[]'
        if (!item || item === '{}' || item === '[]' || item === '') return false;
        // Check if it's a string
        if (typeof item !== 'string') return false;
        // Clean up: remove leading { if present
        let cleaned = item.trim();
        if (cleaned.startsWith('{')) {
          cleaned = cleaned.slice(1).trim();
        }
        // Check if it's a valid URL (starts with http/https)
        return cleaned.startsWith('http://') || cleaned.startsWith('https://');
      })
      .map((item: string) => {
        // Clean up: remove leading { if present
        let cleaned = item.trim();
        if (cleaned.startsWith('{')) {
          cleaned = cleaned.slice(1).trim();
        }
        // Remove trailing } if present (from malformed arrays)
        if (cleaned.endsWith('}')) {
          cleaned = cleaned.slice(0, -1).trim();
        }
        // Remove quotes if present
        cleaned = cleaned.replace(/^["']|["']$/g, '');
        return cleaned;
      });
  }
  if (typeof arr === 'string') {
    // Handle PostgreSQL array format: {"{url1","url2","url3}"} or {url1,url2,url3}
    let cleaned = arr.trim();
    
    // Remove outer braces if present
    if (cleaned.startsWith('{') && cleaned.endsWith('}')) {
      cleaned = cleaned.slice(1, -1);
    }
    
    // Handle JSON array format: ["url1","url2","url3"]
    if (cleaned.startsWith('[') && cleaned.endsWith(']')) {
      try {
        const parsed = JSON.parse(arr);
        if (Array.isArray(parsed)) {
          return parsed
            .filter((url: any) => {
              if (!url || typeof url !== 'string') return false;
              const trimmed = url.trim();
              return trimmed.startsWith('http://') || trimmed.startsWith('https://');
            })
            .map((url: string) => url.trim().replace(/^["']|["']$/g, ''));
        }
      } catch (e) {
        // Not valid JSON, continue with string parsing
      }
    }
    
    // Split by comma and clean each URL
    return cleaned
      .split(',')
      .map(url => {
        // Clean up: remove leading { if present
        let trimmed = url.trim();
        if (trimmed.startsWith('{')) {
          trimmed = trimmed.slice(1).trim();
        }
        // Remove trailing } if present
        if (trimmed.endsWith('}')) {
          trimmed = trimmed.slice(0, -1).trim();
        }
        // Remove quotes
        trimmed = trimmed.replace(/^["']|["']$/g, '');
        return trimmed;
      })
      .filter(url => {
        // Filter out empty values and ensure valid URLs
        if (!url || url === '{}' || url === '[]' || url === '') return false;
        return url.startsWith('http://') || url.startsWith('https://');
      });
  }
  return null;
};

router.use((req, res, next) => {
  const apiKey = req.headers['x-api-key'];
  if (apiKey) return authenticateAPIKey(req, res, next);
  return authenticateJWT(req, res, next);
});

router.get('/countries', async (req, res) => {
  try {
    if (!AppDataSource.isInitialized) {
      console.error('Database not initialized in /countries');
      return res.status(500).json({
        success: false,
        message: 'Database connection not initialized',
      });
    }
    const countries = await AppDataSource.getRepository(Country).find({ relations: ['cities'] });
    res.json(successResponse(countries));
  } catch (error: any) {
    console.error('Error loading countries:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to load countries',
    });
  }
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
        images: parseArray(row.images),
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
        images: parseArray(row.images),
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
        images: parseArray(row.images),
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
      // Перевірка що не більше 8 фото
      if (images.length > 8) {
        return res.status(400).json({ success: false, message: 'Maximum 8 images allowed' });
      }
      area.images = images;
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
  // Використовуємо raw query для отримання даних, щоб уникнути проблем з TypeORM simple-array
  const queryRunner = AppDataSource.createQueryRunner();
  await queryRunner.connect();
  
  try {
    const developersRaw = await queryRunner.query(`
      SELECT id, name, logo, description, images, "createdAt"
      FROM developers
      ORDER BY name ASC
    `);
    
    const developers = developersRaw.map((row: any) => {
      // Парсимо images з текстового поля через parseArray
      let images = parseArray(row.images) || [];
      
      // Додаткова очистка: видаляємо { з початку та } з кінця кожного URL
      images = images
        .map((url: string) => {
          if (typeof url === 'string') {
            let cleaned = url.trim();
            // Видаляємо { з початку (може бути кілька)
            while (cleaned.startsWith('{')) {
              cleaned = cleaned.slice(1).trim();
            }
            // Видаляємо } з кінця (може бути кілька)
            while (cleaned.endsWith('}')) {
              cleaned = cleaned.slice(0, -1).trim();
            }
            return cleaned;
          }
          return url;
        })
        .filter((url: string) => url && url.length > 0 && (url.startsWith('http://') || url.startsWith('https://')));
      
      return {
        id: row.id,
        name: row.name,
        logo: row.logo,
        description: row.description,
        images: images,
        createdAt: row.createdAt,
      };
    });
    
    res.json(successResponse(developers));
  } finally {
    await queryRunner.release();
  }
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

