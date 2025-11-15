import express from 'express';
import { AppDataSource } from '../config/database';
import { Property, PropertyType } from '../entities/Property';
import { Facility } from '../entities/Facility';
import { authenticateJWT, authenticateApiKeyWithSecret, AuthRequest } from '../middleware/auth';
import { successResponse } from '../utils/response';
import { Conversions } from '../utils/conversions';

const router = express.Router();

// Support both JWT and API Key/Secret authentication
router.use((req: AuthRequest, res, next) => {
  const apiKey = req.headers['x-api-key'] as string;
  const apiSecret = req.headers['x-api-secret'] as string;
  
  // If both API key and secret are provided, use API Key/Secret authentication
  if (apiKey && apiSecret) {
    // authenticateApiKeyWithSecret is async and handles errors internally
    authenticateApiKeyWithSecret(req, res, next).catch((error) => {
      console.error('Error in authenticateApiKeyWithSecret:', error);
      // Error should already be handled in middleware, but just in case
      if (!res.headersSent) {
        res.status(500).json({ message: 'Authentication error' });
      }
    });
    return;
  }
  
  // Otherwise, use JWT authentication
  return authenticateJWT(req, res, next);
});

router.get('/', async (req: AuthRequest, res) => {
  try {
    console.log('[Properties API] GET /api/properties request:', {
      query: req.query,
      propertyType: req.query.propertyType,
      hasApiKey: !!req.apiKey,
      authMethod: req.apiKey ? 'API Key' : (req.user ? 'JWT' : 'Unknown'),
    });

    const { 
      propertyType, 
      developerId, 
      cityId, 
      areaId,
      bedrooms,
      sizeFrom,
      sizeTo,
      priceFrom,
      priceTo,
      search,
      sortBy,
      sortOrder,
      page,
      limit
    } = req.query;
    
    const where: any = {};
    
    // Базові фільтри
    if (propertyType) where.propertyType = propertyType;
    if (developerId) where.developerId = developerId;
    if (cityId) where.cityId = cityId;
    if (areaId) where.areaId = areaId;

    // Перевірка чи підключено до БД
    if (!AppDataSource.isInitialized) {
      console.error('Database not initialized');
      return res.status(500).json({
        success: false,
        message: 'Database connection not initialized',
      });
    }

    // Базовий query builder для гнучкої фільтрації
    const queryBuilder = AppDataSource.getRepository(Property)
      .createQueryBuilder('property')
      .leftJoinAndSelect('property.country', 'country')
      .leftJoinAndSelect('property.city', 'city')
      .leftJoinAndSelect('property.area', 'area')
      .leftJoinAndSelect('property.developer', 'developer')
      .leftJoinAndSelect('property.facilities', 'facilities')
      .leftJoinAndSelect('property.units', 'units');

    // Застосовуємо базові фільтри
    Object.keys(where).forEach(key => {
      queryBuilder.andWhere(`property.${key} = :${key}`, { [key]: where[key] });
    });

    // Фільтр по кількості спалень (multiselect - можна передати кілька значень через кому)
    if (bedrooms) {
      // Нормалізуємо bedrooms до масиву рядків
      const bedroomsArray: string[] = Array.isArray(bedrooms) 
        ? bedrooms.map(b => String(b))
        : String(bedrooms).split(',');
      
      const bedroomsConditions = bedroomsArray.map((bed: string, index: number) => {
        const bedNum = parseInt(bed.trim(), 10);
        if (isNaN(bedNum)) return null;
        
        // Для off-plan: перевіряємо bedroomsFrom та bedroomsTo
        // Для secondary: перевіряємо bedrooms
        return `(
          (property.propertyType = 'off-plan' AND property.bedroomsFrom <= :bed${index} AND property.bedroomsTo >= :bed${index})
          OR
          (property.propertyType = 'secondary' AND property.bedrooms = :bed${index})
        )`;
      }).filter((item): item is string => item !== null);
      
      if (bedroomsConditions.length > 0) {
        queryBuilder.andWhere(`(${bedroomsConditions.join(' OR ')})`);
        bedroomsArray.forEach((bed: string, index: number) => {
          const bedNum = parseInt(bed.trim(), 10);
          if (!isNaN(bedNum)) {
            queryBuilder.setParameter(`bed${index}`, bedNum);
          }
        });
      }
    }

    // Фільтр по розміру (sizeFrom/sizeTo)
    if (sizeFrom) {
      const sizeFromNum = parseFloat(sizeFrom.toString());
      if (!isNaN(sizeFromNum)) {
        queryBuilder.andWhere(
          `(property.sizeFrom >= :sizeFrom OR property.size >= :sizeFrom)`,
          { sizeFrom: sizeFromNum }
        );
      }
    }
    if (sizeTo) {
      const sizeToNum = parseFloat(sizeTo.toString());
      if (!isNaN(sizeToNum)) {
        queryBuilder.andWhere(
          `(property.sizeFrom <= :sizeTo OR property.size <= :sizeTo)`,
          { sizeTo: sizeToNum }
        );
      }
    }

    // Фільтр по ціні (priceFrom/priceTo)
    if (priceFrom) {
      const priceFromNum = parseFloat(priceFrom.toString());
      if (!isNaN(priceFromNum)) {
        queryBuilder.andWhere(
          `(property.priceFrom >= :priceFrom OR property.price >= :priceFrom)`,
          { priceFrom: priceFromNum }
        );
      }
    }
    if (priceTo) {
      const priceToNum = parseFloat(priceTo.toString());
      if (!isNaN(priceToNum)) {
        queryBuilder.andWhere(
          `(property.priceFrom <= :priceTo OR property.price <= :priceTo)`,
          { priceTo: priceToNum }
        );
      }
    }

    // Текстовий пошук (search) - пошук по name та description
    if (search) {
      const searchTerm = `%${search.toString().toLowerCase()}%`;
      queryBuilder.andWhere(
        `(LOWER(property.name) LIKE :search OR LOWER(property.description) LIKE :search)`,
        { search: searchTerm }
      );
    }

    // Сортування
    const sortField = sortBy?.toString() || 'createdAt';
    const sortDirection = sortOrder?.toString().toUpperCase() === 'ASC' ? 'ASC' : 'DESC';
    
    // Дозволені поля для сортування
    const allowedSortFields = ['createdAt', 'name', 'price', 'priceFrom', 'size', 'sizeFrom'];
    if (allowedSortFields.includes(sortField)) {
      queryBuilder.orderBy(`property.${sortField}`, sortDirection);
    } else {
      // За замовчуванням сортування по даті створення
      queryBuilder.orderBy('property.createdAt', 'DESC');
    }

    // Пагінація - фронтенд завжди передає page та limit через infinite scroll
    // Якщо параметри не передані, використовуємо мінімальні значення для безпеки
    const pageNum = page ? parseInt(page.toString(), 10) : 1;
    const limitNum = limit ? parseInt(limit.toString(), 10) : 20; // Мінімальний limit якщо не передано
    
    // Максимальний limit для безпеки (на випадок якщо хтось передасть дуже велике значення)
    const MAX_LIMIT = 100;
    const finalLimit = Math.min(limitNum, MAX_LIMIT);
    const skip = (pageNum - 1) * finalLimit;

    // Отримуємо загальну кількість записів перед пагінацією
    const totalCount = await queryBuilder.getCount();

    // Застосовуємо пагінацію
    queryBuilder.skip(skip).take(finalLimit);

    const properties = await queryBuilder.getMany();

    console.log('[Properties API] Query results:', {
      totalProperties: properties.length,
      secondaryProperties: properties.filter(p => p.propertyType === 'secondary').length,
      offPlanProperties: properties.filter(p => p.propertyType === 'off-plan').length,
      propertyTypeFilter: propertyType,
    });

    const propertiesWithConversions = properties.map(p => {
      // Для off-plan properties: area має бути рядком "areaName, cityName"
      // Для secondary properties: area залишається об'єктом
      let areaField: any = p.area;
      if (p.area && p.propertyType === 'off-plan') {
        // Для off-plan: формат "areaName, cityName" (наприклад "JVC, Dubai")
        const areaName = p.area.nameEn || '';
        const cityName = p.city?.nameEn || '';
        areaField = cityName ? `${areaName}, ${cityName}` : areaName;
      }

      // Фільтруємо фото: видаляємо порожні значення та невалідні URL
      let filteredPhotos: string[] = [];
      if (p.photos && Array.isArray(p.photos)) {
        filteredPhotos = p.photos
          .filter((photo: any) => {
            // Видаляємо порожні значення, null, undefined, '{}', '[]'
            if (!photo || photo === '{}' || photo === '[]' || photo === '') return false;
            // Перевіряємо, чи це рядок
            if (typeof photo !== 'string') return false;
            // Перевіряємо, чи це валідний URL (починається з http/https)
            return photo.trim().startsWith('http://') || photo.trim().startsWith('https://');
          })
          .map((photo: string) => photo.trim()); // Прибираємо пробіли
      }

      return {
        ...p,
        photos: filteredPhotos, // Замінюємо photos на відфільтровані
        area: areaField,
        priceFromAED: p.priceFrom ? Conversions.usdToAed(p.priceFrom) : null,
        priceAED: p.price ? Conversions.usdToAed(p.price) : null,
        sizeFromSqft: p.sizeFrom ? Conversions.sqmToSqft(p.sizeFrom) : null,
        sizeToSqft: p.sizeTo ? Conversions.sqmToSqft(p.sizeTo) : null,
        sizeSqft: p.size ? Conversions.sqmToSqft(p.size) : null,
      };
    });

    console.log('[Properties API] ✅ Response sent:', {
      loadedProperties: propertiesWithConversions.length,
      totalCount, // Загальна кількість з урахуванням фільтрів
      page: pageNum,
      requestedLimit: limitNum,
      actualLimit: finalLimit,
    });

    // Повертаємо формат з пагінацією
    // total - загальна кількість всіх properties з урахуванням фільтрів (НЕ кількість завантажених)
    const totalPages = Math.ceil(totalCount / finalLimit);
    
    res.json(successResponse({
      data: propertiesWithConversions,
      pagination: {
        total: totalCount, // Загальна кількість з урахуванням фільтрів
        page: pageNum,
        limit: finalLimit,
        totalPages: totalPages,
      },
    }));
  } catch (error: any) {
    console.error('Error fetching properties:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to fetch properties',
      error: process.env.NODE_ENV === 'development' ? error.stack : undefined,
    });
  }
});

// Statistics endpoint - must be before /:id route
router.get('/stats', async (req: AuthRequest, res) => {
  try {
    const propertyRepo = AppDataSource.getRepository(Property);

    // Get counts by type using aggregation
    const [offPlanCount, secondaryCount] = await Promise.all([
      propertyRepo.count({ where: { propertyType: PropertyType.OFF_PLAN } }),
      propertyRepo.count({ where: { propertyType: PropertyType.SECONDARY } }),
    ]);

    // Get price statistics using query builder
    const priceStats = await propertyRepo
      .createQueryBuilder('property')
      .select([
        'MIN(CASE WHEN property.propertyType = \'off-plan\' THEN property.priceFrom ELSE property.price END) as minPrice',
        'MAX(CASE WHEN property.propertyType = \'off-plan\' THEN property.priceFrom ELSE property.price END) as maxPrice',
      ])
      .where('(property.propertyType = \'off-plan\' AND property.priceFrom IS NOT NULL) OR (property.propertyType = \'secondary\' AND property.price IS NOT NULL)')
      .getRawOne();

    // Get top cities with property counts
    const topCities = await propertyRepo
      .createQueryBuilder('property')
      .leftJoin('property.city', 'city')
      .select('city.nameEn', 'cityName')
      .addSelect('COUNT(property.id)', 'count')
      .groupBy('city.id, city.nameEn')
      .orderBy('COUNT(property.id)', 'DESC')
      .limit(5)
      .getRawMany();

    // Get bedrooms distribution for off-plan
    const bedroomsStats = await propertyRepo
      .createQueryBuilder('property')
      .select([
        'property.bedroomsFrom',
        'property.bedroomsTo',
        'COUNT(property.id) as count',
      ])
      .where('property.propertyType = :type', { type: PropertyType.OFF_PLAN })
      .andWhere('(property.bedroomsFrom IS NOT NULL OR property.bedroomsTo IS NOT NULL)')
      .groupBy('property.bedroomsFrom, property.bedroomsTo')
      .getRawMany();

    // Get unit types distribution
    const unitTypesStats = await propertyRepo
      .createQueryBuilder('property')
      .leftJoin('property.units', 'unit')
      .select('unit.type', 'type')
      .addSelect('COUNT(unit.id)', 'count')
      .where('unit.type IS NOT NULL')
      .groupBy('unit.type')
      .orderBy('COUNT(unit.id)', 'DESC')
      .limit(5)
      .getRawMany();

    // Format bedrooms stats
    const bedroomsMap = new Map<string, number>();
    bedroomsStats.forEach((stat: any) => {
      const from = stat.property_bedroomsFrom;
      const to = stat.property_bedroomsTo;
      let label = '';
      if (from && to) {
        label = `${from}-${to}`;
      } else if (from) {
        label = `${from}+`;
      }
      if (label) {
        bedroomsMap.set(label, parseInt(stat.count, 10));
      }
    });

    const bedroomsSorted = Array.from(bedroomsMap.entries())
      .sort((a, b) => {
        const aNum = parseInt(a[0]) || 0;
        const bNum = parseInt(b[0]) || 0;
        return aNum - bNum;
      });

    res.json(successResponse({
      totalProperties: offPlanCount + secondaryCount,
      offPlanProperties: offPlanCount,
      secondaryProperties: secondaryCount,
      minPrice: priceStats?.minPrice ? parseFloat(priceStats.minPrice) : 0,
      maxPrice: priceStats?.maxPrice ? parseFloat(priceStats.maxPrice) : 0,
      topCities: topCities.map((city: any) => ({
        name: city.cityName,
        count: parseInt(city.count, 10),
      })),
      bedroomsDistribution: bedroomsSorted.map(([name, count]) => ({
        name: name + ' Beds',
        count,
      })),
      unitTypesDistribution: unitTypesStats.map((stat: any) => ({
        name: (stat.type || 'Unknown').charAt(0).toUpperCase() + (stat.type || 'Unknown').slice(1),
        count: parseInt(stat.count, 10),
      })),
    }));
  } catch (error: any) {
    console.error('Error fetching properties stats:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to fetch properties stats',
    });
  }
});

router.get('/:id', async (req, res) => {
  const property = await AppDataSource.getRepository(Property).findOne({
    where: { id: req.params.id },
    relations: ['country', 'city', 'area', 'developer', 'facilities', 'units'],
  });
  res.json(successResponse(property));
});

router.post('/', async (req, res) => {
  try {
    // Transform string values to numbers for numeric fields
    const propertyData = { ...req.body };
    
    // Transform latitude and longitude (they come as strings)
    // Valid ranges: latitude -90 to 90, longitude -180 to 180
    // Database: latitude decimal(10,8), longitude decimal(11,8)
    if (propertyData.latitude !== undefined && propertyData.latitude !== null) {
      const lat = parseFloat(propertyData.latitude);
      if (isNaN(lat) || lat < -90 || lat > 90) {
        return res.status(400).json({
          success: false,
          message: 'Latitude must be between -90 and 90',
        });
      }
      propertyData.latitude = lat;
    }
    if (propertyData.longitude !== undefined && propertyData.longitude !== null) {
      const lng = parseFloat(propertyData.longitude);
      if (isNaN(lng) || lng < -180 || lng > 180) {
        return res.status(400).json({
          success: false,
          message: 'Longitude must be between -180 and 180',
        });
      }
      propertyData.longitude = lng;
    }
    
    // Transform Off-Plan numeric fields
    if (propertyData.priceFrom !== undefined && propertyData.priceFrom !== null && propertyData.priceFrom !== '') {
      const price = parseFloat(propertyData.priceFrom);
      if (isNaN(price) || price < 0) {
        return res.status(400).json({
          success: false,
          message: 'Price from must be a valid positive number',
        });
      }
      propertyData.priceFrom = price;
    } else {
      propertyData.priceFrom = null;
    }
    
    if (propertyData.bedroomsFrom !== undefined && propertyData.bedroomsFrom !== null && propertyData.bedroomsFrom !== '') {
      const bedrooms = parseInt(propertyData.bedroomsFrom, 10);
      if (isNaN(bedrooms) || bedrooms < 0) {
        return res.status(400).json({
          success: false,
          message: 'Bedrooms from must be a valid positive integer',
        });
      }
      propertyData.bedroomsFrom = bedrooms;
    } else {
      propertyData.bedroomsFrom = null;
    }
    
    if (propertyData.bedroomsTo !== undefined && propertyData.bedroomsTo !== null && propertyData.bedroomsTo !== '') {
      const bedrooms = parseInt(propertyData.bedroomsTo, 10);
      if (isNaN(bedrooms) || bedrooms < 0) {
        return res.status(400).json({
          success: false,
          message: 'Bedrooms to must be a valid positive integer',
        });
      }
      propertyData.bedroomsTo = bedrooms;
    } else {
      propertyData.bedroomsTo = null;
    }
    
    if (propertyData.bathroomsFrom !== undefined && propertyData.bathroomsFrom !== null && propertyData.bathroomsFrom !== '') {
      const bathrooms = parseInt(propertyData.bathroomsFrom, 10);
      if (isNaN(bathrooms) || bathrooms < 0) {
        return res.status(400).json({
          success: false,
          message: 'Bathrooms from must be a valid positive integer',
        });
      }
      propertyData.bathroomsFrom = bathrooms;
    } else {
      propertyData.bathroomsFrom = null;
    }
    
    if (propertyData.bathroomsTo !== undefined && propertyData.bathroomsTo !== null && propertyData.bathroomsTo !== '') {
      const bathrooms = parseInt(propertyData.bathroomsTo, 10);
      if (isNaN(bathrooms) || bathrooms < 0) {
        return res.status(400).json({
          success: false,
          message: 'Bathrooms to must be a valid positive integer',
        });
      }
      propertyData.bathroomsTo = bathrooms;
    } else {
      propertyData.bathroomsTo = null;
    }
    
    if (propertyData.sizeFrom !== undefined && propertyData.sizeFrom !== null && propertyData.sizeFrom !== '') {
      const size = parseFloat(propertyData.sizeFrom);
      if (isNaN(size) || size < 0) {
        return res.status(400).json({
          success: false,
          message: 'Size from must be a valid positive number',
        });
      }
      propertyData.sizeFrom = size;
    } else {
      propertyData.sizeFrom = null;
    }
    
    if (propertyData.sizeTo !== undefined && propertyData.sizeTo !== null && propertyData.sizeTo !== '') {
      const size = parseFloat(propertyData.sizeTo);
      if (isNaN(size) || size < 0) {
        return res.status(400).json({
          success: false,
          message: 'Size to must be a valid positive number',
        });
      }
      propertyData.sizeTo = size;
    } else {
      propertyData.sizeTo = null;
    }
    
    // Transform Secondary numeric fields
    if (propertyData.price !== undefined && propertyData.price !== null && propertyData.price !== '') {
      const price = parseFloat(propertyData.price);
      if (isNaN(price) || price < 0) {
        return res.status(400).json({
          success: false,
          message: 'Price must be a valid positive number',
        });
      }
      propertyData.price = price;
    } else {
      propertyData.price = null;
    }
    
    if (propertyData.bedrooms !== undefined && propertyData.bedrooms !== null && propertyData.bedrooms !== '') {
      const bedrooms = parseInt(propertyData.bedrooms, 10);
      if (isNaN(bedrooms) || bedrooms < 0) {
        return res.status(400).json({
          success: false,
          message: 'Bedrooms must be a valid positive integer',
        });
      }
      propertyData.bedrooms = bedrooms;
    } else {
      propertyData.bedrooms = null;
    }
    
    if (propertyData.bathrooms !== undefined && propertyData.bathrooms !== null && propertyData.bathrooms !== '') {
      const bathrooms = parseInt(propertyData.bathrooms, 10);
      if (isNaN(bathrooms) || bathrooms < 0) {
        return res.status(400).json({
          success: false,
          message: 'Bathrooms must be a valid positive integer',
        });
      }
      propertyData.bathrooms = bathrooms;
    } else {
      propertyData.bathrooms = null;
    }
    
    if (propertyData.size !== undefined && propertyData.size !== null && propertyData.size !== '') {
      const size = parseFloat(propertyData.size);
      if (isNaN(size) || size < 0) {
        return res.status(400).json({
          success: false,
          message: 'Size must be a valid positive number',
        });
      }
      propertyData.size = size;
    } else {
      propertyData.size = null;
    }
    
    // Transform units if present
    if (propertyData.units && Array.isArray(propertyData.units)) {
      propertyData.units = propertyData.units.map((unit: any) => ({
        ...unit,
        totalSize: unit.totalSize ? parseFloat(unit.totalSize) : null,
        balconySize: unit.balconySize ? parseFloat(unit.balconySize) : null,
        price: unit.price ? parseFloat(unit.price) : null,
      }));
    }
    
    const property = await AppDataSource.getRepository(Property).save(propertyData);
    
    // Fetch with relations to return complete data
    const completeProperty = await AppDataSource.getRepository(Property).findOne({
      where: { id: property.id },
      relations: ['country', 'city', 'area', 'developer', 'facilities', 'units'],
    });
    
    res.json(successResponse(completeProperty));
  } catch (error: any) {
    console.error('Error creating property:', error);
    res.status(500).json({ 
      success: false, 
      message: error.message || 'Failed to create property',
      error: error.message,
    });
  }
});

router.patch('/:id', async (req, res) => {
  try {
    const propertyRepository = AppDataSource.getRepository(Property);
    const property = await propertyRepository.findOne({
      where: { id: req.params.id },
      relations: ['facilities', 'units'],
    });

    if (!property) {
      return res.status(404).json({ success: false, message: 'Property not found' });
    }

    // Filter out fields that don't exist in Property entity (like mainPhotoUrl)
    const allowedFields = [
      'name', 'photos', 'countryId', 'cityId', 'areaId', 'latitude', 'longitude',
      'description', 'developerId', 'priceFrom', 'bedroomsFrom', 'bedroomsTo',
      'bathroomsFrom', 'bathroomsTo', 'sizeFrom', 'sizeTo', 'paymentPlan',
      'price', 'bedrooms', 'bathrooms', 'size', 'propertyType'
    ];

    const updateData: any = {};
    for (const field of allowedFields) {
      if (req.body[field] !== undefined) {
        updateData[field] = req.body[field];
      }
    }

    // Handle facilities separately if provided
    if (req.body.facilities !== undefined && Array.isArray(req.body.facilities)) {
      const facilityRepository = AppDataSource.getRepository(Facility);
      const facilities = await facilityRepository.findBy({ id: req.body.facilities as any });
      property.facilities = facilities;
    }

    // Update property fields
    Object.assign(property, updateData);
    const updatedProperty = await propertyRepository.save(property);

    // Fetch with all relations
    const completeProperty = await propertyRepository.findOne({
      where: { id: updatedProperty.id },
      relations: ['country', 'city', 'area', 'developer', 'facilities', 'units'],
    });

    res.json(successResponse(completeProperty));
  } catch (error: any) {
    console.error('Error updating property:', error);
    res.status(500).json({ 
      success: false, 
      message: error.message || 'Failed to update property' 
    });
  }
});

router.delete('/:id', async (req, res) => {
  await AppDataSource.getRepository(Property).delete(req.params.id);
  res.json(successResponse(null, 'Property deleted'));
});

export default router;

