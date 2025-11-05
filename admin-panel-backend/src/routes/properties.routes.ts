import express from 'express';
import { AppDataSource } from '../config/database';
import { Property } from '../entities/Property';
import { authenticateJWT, authenticateAPIKey } from '../middleware/auth';
import { successResponse } from '../utils/response';
import { Conversions } from '../utils/conversions';

const router = express.Router();

router.use((req, res, next) => {
  const apiKey = req.headers['x-api-key'];
  if (apiKey) return authenticateAPIKey(req, res, next);
  return authenticateJWT(req, res, next);
});

router.get('/', async (req, res) => {
  try {
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
      sortOrder
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

    const properties = await queryBuilder.getMany();

    const propertiesWithConversions = properties.map(p => ({
      ...p,
      priceFromAED: p.priceFrom ? Conversions.usdToAed(p.priceFrom) : null,
      priceAED: p.price ? Conversions.usdToAed(p.price) : null,
      sizeFromSqft: p.sizeFrom ? Conversions.sqmToSqft(p.sizeFrom) : null,
      sizeToSqft: p.sizeTo ? Conversions.sqmToSqft(p.sizeTo) : null,
      sizeSqft: p.size ? Conversions.sqmToSqft(p.size) : null,
    }));

    res.json(successResponse(propertiesWithConversions));
  } catch (error: any) {
    console.error('Error fetching properties:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to fetch properties',
      error: process.env.NODE_ENV === 'development' ? error.stack : undefined,
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
  await AppDataSource.getRepository(Property).update(req.params.id, req.body);
  const property = await AppDataSource.getRepository(Property).findOne({
    where: { id: req.params.id },
    relations: ['facilities', 'units'],
  });
  res.json(successResponse(property));
});

router.delete('/:id', async (req, res) => {
  await AppDataSource.getRepository(Property).delete(req.params.id);
  res.json(successResponse(null, 'Property deleted'));
});

export default router;

