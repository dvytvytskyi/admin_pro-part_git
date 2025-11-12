import express from 'express';
import { AppDataSource } from '../config/database';
import { Property } from '../entities/Property';
import { Country } from '../entities/Country';
import { City } from '../entities/City';
import { Area } from '../entities/Area';
import { Developer } from '../entities/Developer';
import { Facility } from '../entities/Facility';
import { Course } from '../entities/Course';
import { News } from '../entities/News';
import { successResponse, errorResponse } from '../utils/response';
import { Conversions } from '../utils/conversions';
import { authenticateApiKeyWithSecret, AuthRequest } from '../middleware/auth';

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
        let urlToValidate: string | null = null;
        if (typeof img === 'string') {
          urlToValidate = img;
        } else if (typeof img === 'object' && img !== null && img.url) {
          urlToValidate = String(img.url);
        } else if (img !== null && img !== undefined) {
          urlToValidate = String(img);
        }
        
        if (!urlToValidate) return null;
        
        const cleaned = validateAndCleanUrl(urlToValidate);
        if (!cleaned && urlToValidate) {
          // Log invalid URLs for debugging (only in development)
          if (process.env.NODE_ENV === 'development') {
            console.warn(`[parseImages] Invalid URL filtered out: ${urlToValidate.substring(0, 100)}...`);
          }
        }
        return cleaned;
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

// GET /api/public/data - Get all public data (returns ALL properties from ALL areas, no filtering)
router.get('/data', authenticateApiKeyWithSecret, async (req: AuthRequest, res) => {
  try {
    console.log('[Public API] GET /api/public/data request:', {
      hasApiKey: !!req.apiKey,
      apiKeyName: req.apiKey?.name,
    });

    // Fetch ALL properties without any areaId filtering - this is intentional for client-side filtering
    const [properties, countries, cities, areas, developers, facilities, courses] = await Promise.all([
      AppDataSource.getRepository(Property).find({
        relations: ['country', 'city', 'area', 'developer', 'facilities', 'units'],
        order: { createdAt: 'DESC' },
        // No where clause - returns all properties from all areas
      }),
      AppDataSource.getRepository(Country).find({
        order: { nameEn: 'ASC' },
      }),
      AppDataSource.getRepository(City).find({
        relations: ['country'],
        order: { nameEn: 'ASC' },
      }),
      AppDataSource.getRepository(Area).find({
        relations: ['city', 'city.country'],
        order: { nameEn: 'ASC' },
      }),
      AppDataSource.getRepository(Developer).find({
        order: { name: 'ASC' },
      }),
      AppDataSource.getRepository(Facility).find({
        order: { nameEn: 'ASC' },
      }),
      AppDataSource.getRepository(Course).find({
        relations: ['contents', 'links'],
        order: { order: 'ASC' },
      }),
    ]);

    // Transform properties with conversions
    const transformedProperties = properties.map(p => {
      // Для off-plan properties: area має бути рядком "areaName, cityName"
      // Для secondary properties: area залишається об'єктом
      let areaField: any = null;
      if (p.area) {
        if (p.propertyType === 'off-plan') {
          // Для off-plan: формат "areaName, cityName" (наприклад "JVC, Dubai")
          const areaName = p.area.nameEn || '';
          const cityName = p.city?.nameEn || '';
          areaField = cityName ? `${areaName}, ${cityName}` : areaName;
        } else {
          // Для secondary: об'єкт як раніше
          areaField = {
            id: p.area.id,
            nameEn: p.area.nameEn,
            nameRu: p.area.nameRu,
            nameAr: p.area.nameAr,
          };
        }
      }

      return {
        id: p.id,
        propertyType: p.propertyType,
        name: p.name,
        description: p.description,
        price: p.price,
        priceFrom: p.priceFrom,
        priceAED: p.price ? Conversions.usdToAed(p.price) : null,
        priceFromAED: p.priceFrom ? Conversions.usdToAed(p.priceFrom) : null,
        size: p.size,
        sizeFrom: p.sizeFrom,
        sizeTo: p.sizeTo,
        sizeSqft: p.size ? Conversions.sqmToSqft(p.size) : null,
        sizeFromSqft: p.sizeFrom ? Conversions.sqmToSqft(p.sizeFrom) : null,
        sizeToSqft: p.sizeTo ? Conversions.sqmToSqft(p.sizeTo) : null,
        bedrooms: p.bedrooms,
        bedroomsFrom: p.bedroomsFrom,
        bedroomsTo: p.bedroomsTo,
        bathrooms: p.bathrooms,
        bathroomsFrom: p.bathroomsFrom,
        bathroomsTo: p.bathroomsTo,
        paymentPlan: p.paymentPlan,
        latitude: p.latitude,
        longitude: p.longitude,
        country: p.country ? {
          id: p.country.id,
          nameEn: p.country.nameEn,
          nameRu: p.country.nameRu,
          nameAr: p.country.nameAr,
          code: p.country.code,
        } : null,
        city: p.city ? {
          id: p.city.id,
          nameEn: p.city.nameEn,
          nameRu: p.city.nameRu,
          nameAr: p.city.nameAr,
        } : null,
        area: areaField,
        developer: p.developer ? {
          id: p.developer.id,
          name: p.developer.name,
        } : null,
        facilities: p.facilities?.map(f => ({
          id: f.id,
          nameEn: f.nameEn,
          nameRu: f.nameRu,
          nameAr: f.nameAr,
          iconName: f.iconName,
        })) || [],
        units: p.units?.map(u => ({
          id: u.id,
          unitId: u.unitId,
          type: u.type,
          price: u.price,
          priceAED: u.price ? Conversions.usdToAed(u.price) : null,
          totalSize: u.totalSize,
          totalSizeSqft: u.totalSize ? Conversions.sqmToSqft(u.totalSize) : null,
          balconySize: u.balconySize,
          balconySizeSqft: u.balconySize ? Conversions.sqmToSqft(u.balconySize) : null,
          planImage: u.planImage,
        })) || [],
        photos: p.photos || [],
        createdAt: p.createdAt,
        updatedAt: p.updatedAt,
      };
    });

    const secondaryCount = transformedProperties.filter(p => p.propertyType === 'secondary').length;
    const offPlanCount = transformedProperties.filter(p => p.propertyType === 'off-plan').length;
    
    console.log('[Public API] ✅ Response sent:', {
      totalProperties: transformedProperties.length,
      secondaryProperties: secondaryCount,
      offPlanProperties: offPlanCount,
    });

    res.json(successResponse({
      properties: transformedProperties,
      countries: countries.map(c => ({
        id: c.id,
        nameEn: c.nameEn,
        nameRu: c.nameRu,
        nameAr: c.nameAr,
        code: c.code,
      })),
      cities: cities.map(c => ({
        id: c.id,
        nameEn: c.nameEn,
        nameRu: c.nameRu,
        nameAr: c.nameAr,
        countryId: c.countryId,
        country: c.country ? {
          id: c.country.id,
          nameEn: c.country.nameEn,
          nameRu: c.country.nameRu,
          nameAr: c.country.nameAr,
          code: c.country.code,
        } : null,
      })),
      areas: areas.map(a => ({
        id: a.id,
        nameEn: a.nameEn,
        nameRu: a.nameRu,
        nameAr: a.nameAr,
        cityId: a.cityId,
        city: a.city ? {
          id: a.city.id,
          nameEn: a.city.nameEn,
          nameRu: a.city.nameRu,
          nameAr: a.city.nameAr,
          countryId: a.city.countryId,
          country: a.city.country ? {
            id: a.city.country.id,
            nameEn: a.city.country.nameEn,
            nameRu: a.city.country.nameRu,
            nameAr: a.city.country.nameAr,
            code: a.city.country.code,
          } : null,
        } : null,
        description: a.description || null,
        infrastructure: a.infrastructure || null,
        images: parseImages(a.images),
      })),
      developers: developers.map(d => ({
        id: d.id,
        name: d.name,
        logo: d.logo,
        description: d.description,
        createdAt: d.createdAt,
      })),
      facilities: facilities.map(f => ({
        id: f.id,
        nameEn: f.nameEn,
        nameRu: f.nameRu,
        nameAr: f.nameAr,
        iconName: f.iconName,
        createdAt: f.createdAt,
      })),
      courses: courses.map(c => ({
        id: c.id,
        title: c.title,
        description: c.description,
        order: c.order,
        contents: c.contents?.sort((a, b) => a.order - b.order).map(content => ({
          id: content.id,
          type: content.type,
          title: content.title,
          description: content.description,
          imageUrl: content.imageUrl,
          videoUrl: content.videoUrl,
          order: content.order,
        })) || [],
        links: c.links?.sort((a, b) => a.order - b.order).map(link => ({
          id: link.id,
          title: link.title,
          url: link.url,
          order: link.order,
        })) || [],
        createdAt: c.createdAt,
        updatedAt: c.updatedAt,
      })),
      meta: {
        totalProperties: transformedProperties.length,
        totalSecondaryProperties: secondaryCount,
        totalOffPlanProperties: offPlanCount,
        totalCountries: countries.length,
        totalCities: cities.length,
        totalAreas: areas.length,
        totalDevelopers: developers.length,
        totalFacilities: facilities.length,
        totalCourses: courses.length,
        lastUpdated: new Date().toISOString(),
      },
    }));
  } catch (error: any) {
    console.error('Error fetching public data:', error);
    res.status(500).json(errorResponse('Failed to fetch data', error.message));
  }
});

// GET /api/public/courses - Get all courses (public access with API key)
router.get('/courses', authenticateApiKeyWithSecret, async (req, res) => {
  try {
    const courses = await AppDataSource.getRepository(Course).find({
      relations: ['contents', 'links'],
      order: { order: 'ASC' },
    });

    const transformedCourses = courses.map(c => ({
      id: c.id,
      title: c.title,
      description: c.description,
      order: c.order,
      contents: c.contents?.sort((a, b) => a.order - b.order).map(content => ({
        id: content.id,
        type: content.type,
        title: content.title,
        description: content.description,
        imageUrl: content.imageUrl,
        videoUrl: content.videoUrl,
        order: content.order,
      })) || [],
      links: c.links?.sort((a, b) => a.order - b.order).map(link => ({
        id: link.id,
        title: link.title,
        url: link.url,
        order: link.order,
      })) || [],
      createdAt: c.createdAt,
      updatedAt: c.updatedAt,
    }));

    res.json(successResponse(transformedCourses));
  } catch (error: any) {
    console.error('Error fetching courses:', error);
    res.status(500).json(errorResponse('Failed to fetch courses', error.message));
  }
});

// GET /api/public/courses/:id - Get single course by ID
router.get('/courses/:id', authenticateApiKeyWithSecret, async (req, res) => {
  try {
    const course = await AppDataSource.getRepository(Course).findOne({
      where: { id: req.params.id },
      relations: ['contents', 'links'],
    });

    if (!course) {
      return res.status(404).json(errorResponse('Course not found'));
    }

    const transformedCourse = {
      id: course.id,
      title: course.title,
      description: course.description,
      order: course.order,
      contents: course.contents?.sort((a, b) => a.order - b.order).map(content => ({
        id: content.id,
        type: content.type,
        title: content.title,
        description: content.description,
        imageUrl: content.imageUrl,
        videoUrl: content.videoUrl,
        order: content.order,
      })) || [],
      links: course.links?.sort((a, b) => a.order - b.order).map(link => ({
        id: link.id,
        title: link.title,
        url: link.url,
        order: link.order,
      })) || [],
      createdAt: course.createdAt,
      updatedAt: course.updatedAt,
    };

    res.json(successResponse(transformedCourse));
  } catch (error: any) {
    console.error('Error fetching course:', error);
    res.status(500).json(errorResponse('Failed to fetch course', error.message));
  }
});

// GET /api/public/areas - Get all areas with project counts
router.get('/areas', authenticateApiKeyWithSecret, async (req: AuthRequest, res) => {
  try {
    console.log('[Public API] GET /api/public/areas request:', {
      hasApiKey: !!req.apiKey,
      apiKeyName: req.apiKey?.name,
      cityId: req.query.cityId,
    });

    const { cityId } = req.query;

    // Використовуємо query builder з явним вибором тільки основних полів
    const where: any = {};
    if (cityId) {
      where.cityId = cityId;
    }
    
    // Використовуємо raw query для безпечного вибору (обходимо TypeORM entity mapping)
    const queryRunner = AppDataSource.createQueryRunner();
    await queryRunner.connect();
    
    let areas: any[] = [];
    try {
      let whereClause = '';
      const whereParams: any[] = [];
      if (cityId) {
        whereClause = 'WHERE area."cityId" = $1';
        whereParams.push(cityId);
      }
      
          // Вибираємо всі поля areas, включаючи description, infrastructure, images
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
      
      // Отримуємо повну інформацію про city та country через TypeORM
      const areaIds = areasRaw.map((a: any) => a.id);
      let areasWithRelations: any[] = [];
      if (areaIds.length > 0) {
        // Використовуємо raw query для city та country, щоб уникнути проблем з entity
        const citiesData = await queryRunner.query(`
          SELECT DISTINCT
            city.id,
            city."nameEn",
            city."nameRu",
            city."nameAr",
            city."countryId"
          FROM cities city
          WHERE city.id IN (
            SELECT DISTINCT "cityId" FROM areas WHERE id = ANY($1::uuid[])
          )
        `, [areaIds]);
        
        const countryIds = [...new Set(citiesData.map((c: any) => c.countryId))];
        const countriesData = countryIds.length > 0 ? await queryRunner.query(`
          SELECT 
            country.id,
            country."nameEn",
            country."nameRu",
            country."nameAr",
            country.code
          FROM countries country
          WHERE country.id = ANY($1::uuid[])
        `, [countryIds]) : [];
        
        // Формуємо структуру areas з relations
        const citiesMap = new Map(citiesData.map((c: any) => [c.id, c]));
        const countriesMap = new Map(countriesData.map((c: any) => [c.id, c]));
        
        areas = areasRaw.map((areaRaw: any) => {
          const city: any = citiesMap.get(areaRaw.cityId);
          const country: any = city ? countriesMap.get(city.countryId) : null;
          
          return {
            id: areaRaw.id,
            cityId: areaRaw.cityId,
            nameEn: areaRaw.nameEn,
            nameRu: areaRaw.nameRu,
            nameAr: areaRaw.nameAr,
            city: city ? {
              id: city.id,
              nameEn: city.nameEn,
              nameRu: city.nameRu,
              nameAr: city.nameAr,
              countryId: city.countryId,
              country: country ? {
                id: country.id,
                nameEn: country.nameEn,
                nameRu: country.nameRu,
                nameAr: country.nameAr,
                code: country.code,
              } : null,
            } : null,
            description: areaRaw.description || null,
            infrastructure: areaRaw.infrastructure || null,
            images: parseImages(areaRaw.images),
          };
        });
      } else {
        areas = [];
      }
    } finally {
      await queryRunner.release();
    }

    // Отримуємо підрахунок properties по areas через SQL агрегацію (більш ефективно)
    const areaIds = areas.map(a => a.id);
    
    // Підрахунок через SQL запит для кращої продуктивності
    let countsQuery: any[] = [];
    if (areaIds.length > 0) {
      countsQuery = await AppDataSource
        .getRepository(Property)
        .createQueryBuilder('property')
        .select('property.areaId', 'areaId')
        .addSelect('COUNT(property.id)', 'total')
        .addSelect(
          "SUM(CASE WHEN property.propertyType = 'off-plan' THEN 1 ELSE 0 END)",
          'offPlan'
        )
        .addSelect(
          "SUM(CASE WHEN property.propertyType = 'secondary' THEN 1 ELSE 0 END)",
          'secondary'
        )
        .where('property.areaId IN (:...areaIds)', { areaIds })
        .groupBy('property.areaId')
        .getRawMany();
    }

    // Створюємо мапу для швидкого доступу
    const areaPropertyCounts = new Map<string, {
      total: number;
      offPlan: number;
      secondary: number;
    }>();

    // Ініціалізуємо всі areas з нульовими значеннями
    areas.forEach(area => {
      areaPropertyCounts.set(area.id, {
        total: 0,
        offPlan: 0,
        secondary: 0,
      });
    });

    // Заповнюємо мапу з результатів SQL запиту
    countsQuery.forEach((row: any) => {
      areaPropertyCounts.set(row.areaId, {
        total: parseInt(row.total, 10) || 0,
        offPlan: parseInt(row.offPlan, 10) || 0,
        secondary: parseInt(row.secondary, 10) || 0,
      });
    });

    // Формуємо відповідь з підрахунками
    const areasWithCounts = areas.map(area => {
      const counts = areaPropertyCounts.get(area.id) || {
        total: 0,
        offPlan: 0,
        secondary: 0,
      };

      return {
        id: area.id,
        nameEn: area.nameEn,
        nameRu: area.nameRu,
        nameAr: area.nameAr,
        cityId: area.cityId,
        city: area.city ? {
          id: area.city.id,
          nameEn: area.city.nameEn,
          nameRu: area.city.nameRu,
          nameAr: area.city.nameAr,
          countryId: area.city.countryId,
          country: area.city.country ? {
            id: area.city.country.id,
            nameEn: area.city.country.nameEn,
            nameRu: area.city.country.nameRu,
            nameAr: area.city.country.nameAr,
            code: area.city.country.code,
          } : null,
        } : null,
        projectsCount: {
          total: counts.total,
          offPlan: counts.offPlan,
          secondary: counts.secondary,
        },
        description: (area as any).description || null,
        infrastructure: (area as any).infrastructure || null,
        images: parseImages((area as any).images),
      };
    });

    // Фільтруємо areas без projects (опціонально, можна залишити всі)
    // const areasWithProjects = areasWithCounts.filter(a => a.projectsCount.total > 0);

    console.log('[Public API] ✅ Areas response sent:', {
      totalAreas: areasWithCounts.length,
      areasWithProjects: areasWithCounts.filter(a => a.projectsCount.total > 0).length,
    });

    res.json(successResponse(areasWithCounts));
  } catch (error: any) {
    console.error('Error fetching areas:', error);
    res.status(500).json(errorResponse('Failed to fetch areas', error.message));
  }
});

// GET /api/public/developers - Get all developers with project counts
router.get('/developers', authenticateApiKeyWithSecret, async (req: AuthRequest, res) => {
  try {
    console.log('[Public API] GET /api/public/developers request:', {
      hasApiKey: !!req.apiKey,
      apiKeyName: req.apiKey?.name,
    });

    // Отримуємо всіх developers
    const developers = await AppDataSource.getRepository(Developer).find({
      order: { name: 'ASC' },
    });

    // Отримуємо підрахунок properties по developers через SQL агрегацію
    const developerIds = developers.map(d => d.id);
    
    // Підрахунок через SQL запит для кращої продуктивності
    let countsQuery: any[] = [];
    if (developerIds.length > 0) {
      countsQuery = await AppDataSource
        .getRepository(Property)
        .createQueryBuilder('property')
        .select('property.developerId', 'developerId')
        .addSelect('COUNT(property.id)', 'total')
        .addSelect(
          "SUM(CASE WHEN property.propertyType = 'off-plan' THEN 1 ELSE 0 END)",
          'offPlan'
        )
        .addSelect(
          "SUM(CASE WHEN property.propertyType = 'secondary' THEN 1 ELSE 0 END)",
          'secondary'
        )
        .where('property.developerId IN (:...developerIds)', { developerIds })
        .groupBy('property.developerId')
        .getRawMany();
    }

    // Створюємо мапу для швидкого доступу
    const developerPropertyCounts = new Map<string, {
      total: number;
      offPlan: number;
      secondary: number;
    }>();

    // Ініціалізуємо всі developers з нульовими значеннями
    developers.forEach(developer => {
      developerPropertyCounts.set(developer.id, {
        total: 0,
        offPlan: 0,
        secondary: 0,
      });
    });

    // Заповнюємо мапу з результатів SQL запиту
    countsQuery.forEach((row: any) => {
      developerPropertyCounts.set(row.developerId, {
        total: parseInt(row.total, 10) || 0,
        offPlan: parseInt(row.offPlan, 10) || 0,
        secondary: parseInt(row.secondary, 10) || 0,
      });
    });

    // Формуємо відповідь з підрахунками
    const developersWithCounts = developers.map(developer => {
      const counts = developerPropertyCounts.get(developer.id) || {
        total: 0,
        offPlan: 0,
        secondary: 0,
      };

      // Парсимо description як JSON, якщо це можливо, інакше повертаємо як рядок
      let descriptionField: any = null;
      if (developer.description) {
        try {
          // Спробуємо парсити як JSON
          const parsed = JSON.parse(developer.description);
          if (typeof parsed === 'object' && parsed !== null) {
            descriptionField = parsed;
          } else {
            descriptionField = developer.description;
          }
        } catch {
          // Якщо не JSON, повертаємо як рядок
          descriptionField = developer.description;
        }
      }

      return {
        id: developer.id,
        name: developer.name,
        logo: developer.logo || null,
        description: descriptionField,
        images: developer.images || null,
        projectsCount: {
          total: counts.total,
          offPlan: counts.offPlan,
          secondary: counts.secondary,
        },
        createdAt: developer.createdAt,
      };
    });

    console.log('[Public API] ✅ Developers response sent:', {
      totalDevelopers: developersWithCounts.length,
      developersWithProjects: developersWithCounts.filter(d => d.projectsCount.total > 0).length,
    });

    res.json(successResponse(developersWithCounts));
  } catch (error: any) {
    console.error('Error fetching developers:', error);
    res.status(500).json(errorResponse('Failed to fetch developers', error.message));
  }
});

// Helper function to generate slug from title
function generateSlug(title: string): string {
  return title
    .toLowerCase()
    .trim()
    .replace(/[^\w\s-]/g, '') // Remove special characters
    .replace(/[\s_-]+/g, '-') // Replace spaces and underscores with hyphens
    .replace(/^-+|-+$/g, ''); // Remove leading/trailing hyphens
}

// GET /api/public/news - Get all published news with pagination
router.get('/news', authenticateApiKeyWithSecret, async (req: AuthRequest, res) => {
  try {
    console.log('[Public API] GET /api/public/news request:', {
      hasApiKey: !!req.apiKey,
      apiKeyName: req.apiKey?.name,
      page: req.query.page,
      limit: req.query.limit,
    });

    // Пагінація
    const pageNum = req.query.page ? parseInt(req.query.page.toString(), 10) : 1;
    const limitNum = req.query.limit ? parseInt(req.query.limit.toString(), 10) : 20;
    const MAX_LIMIT = 100;
    const finalLimit = Math.min(Math.max(limitNum, 1), MAX_LIMIT);
    const skip = (pageNum - 1) * finalLimit;

    // Створюємо query builder для опублікованих новин
    const queryBuilder = AppDataSource.getRepository(News)
      .createQueryBuilder('news')
      .where('news.isPublished = :isPublished', { isPublished: true })
      .andWhere('news.publishedAt IS NOT NULL')
      .andWhere('news.publishedAt <= :now', { now: new Date() });

    // Отримуємо загальну кількість перед пагінацією
    const totalCount = await queryBuilder.getCount();

    // Застосовуємо пагінацію та сортування
    const news = await queryBuilder
      .orderBy('news.publishedAt', 'DESC')
      .skip(skip)
      .take(finalLimit)
      .getMany();

    // Формуємо відповідь
    const newsList = news.map(item => ({
      id: item.id,
      slug: generateSlug(item.title), // Генеруємо slug з title
      title: item.title,
      titleRu: (item as any).titleRu || null, // Підтримка titleRu якщо є
      description: item.description,
      descriptionRu: (item as any).descriptionRu || null, // Підтримка descriptionRu якщо є
      image: item.imageUrl || null,
      publishedAt: item.publishedAt,
    }));

    console.log('[Public API] ✅ News response sent:', {
      totalNews: totalCount,
      returnedNews: newsList.length,
      page: pageNum,
      limit: finalLimit,
    });

    res.json(successResponse({
      data: newsList,
      total: totalCount,
      page: pageNum,
      limit: finalLimit,
      totalPages: Math.ceil(totalCount / finalLimit),
    }));
  } catch (error: any) {
    console.error('Error fetching news:', error);
    res.status(500).json(errorResponse('Failed to fetch news', error.message));
  }
});

// GET /api/public/news/:slug - Get single news item by slug
router.get('/news/:slug', authenticateApiKeyWithSecret, async (req: AuthRequest, res) => {
  try {
    const { slug } = req.params;

    console.log('[Public API] GET /api/public/news/:slug request:', {
      hasApiKey: !!req.apiKey,
      apiKeyName: req.apiKey?.name,
      slug,
    });

    // Спочатку пробуємо знайти за id (якщо slug виглядає як UUID)
    const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
    let newsItem: News | null = null;

    if (uuidRegex.test(slug)) {
      // Якщо slug виглядає як UUID, шукаємо за id
      newsItem = await AppDataSource.getRepository(News)
        .createQueryBuilder('news')
        .leftJoinAndSelect('news.contents', 'contents')
        .where('news.id = :id', { id: slug })
        .andWhere('news.isPublished = :isPublished', { isPublished: true })
        .andWhere('news.publishedAt IS NOT NULL')
        .andWhere('news.publishedAt <= :now', { now: new Date() })
        .orderBy('contents.order', 'ASC')
        .getOne();
    }

    // Якщо не знайдено за id, шукаємо за slug (якщо поле є в БД) або генеруємо slug з title
    if (!newsItem) {
      const allNews = await AppDataSource.getRepository(News)
        .createQueryBuilder('news')
        .leftJoinAndSelect('news.contents', 'contents')
        .where('news.isPublished = :isPublished', { isPublished: true })
        .andWhere('news.publishedAt IS NOT NULL')
        .andWhere('news.publishedAt <= :now', { now: new Date() })
        .orderBy('contents.order', 'ASC')
        .getMany();

      // Шукаємо за slug в БД або генеруємо slug з title
      newsItem = allNews.find(item => {
        const dbSlug = (item as any).slug;
        const generatedSlug = generateSlug(item.title);
        return dbSlug === slug || generatedSlug === slug;
      }) || null;
    }

    if (!newsItem) {
      return res.status(404).json(errorResponse('News not found'));
    }

    // Формуємо відповідь з повною інформацією
    const newsResponse = {
      id: newsItem.id,
      slug: (newsItem as any).slug || generateSlug(newsItem.title),
      title: newsItem.title,
      titleRu: (newsItem as any).titleRu || null,
      description: newsItem.description,
      descriptionRu: (newsItem as any).descriptionRu || null,
      image: newsItem.imageUrl || null,
      publishedAt: newsItem.publishedAt,
      contents: (newsItem.contents || []).sort((a, b) => a.order - b.order).map(content => ({
        type: content.type,
        title: content.title,
        description: content.description || null,
        imageUrl: content.imageUrl || null,
        videoUrl: content.videoUrl || null,
        order: content.order,
      })),
    };

    console.log('[Public API] ✅ News detail response sent:', {
      newsId: newsItem.id,
      contentsCount: newsResponse.contents.length,
    });

    res.json(successResponse(newsResponse));
  } catch (error: any) {
    console.error('Error fetching news detail:', error);
    res.status(500).json(errorResponse('Failed to fetch news detail', error.message));
  }
});

export default router;

