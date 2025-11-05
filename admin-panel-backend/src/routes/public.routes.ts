import express from 'express';
import { AppDataSource } from '../config/database';
import { Property } from '../entities/Property';
import { ApiKey } from '../entities/ApiKey';
import { Country } from '../entities/Country';
import { City } from '../entities/City';
import { Area } from '../entities/Area';
import { Developer } from '../entities/Developer';
import { Facility } from '../entities/Facility';
import { Course } from '../entities/Course';
import { successResponse, errorResponse } from '../utils/response';
import { Conversions } from '../utils/conversions';

const router = express.Router();

// Middleware to authenticate API key
const authenticateApiKey = async (req: express.Request, res: express.Response, next: express.NextFunction) => {
  const apiKey = req.headers['x-api-key'] as string;
  const apiSecret = req.headers['x-api-secret'] as string;

  if (!apiKey || !apiSecret) {
    return res.status(401).json(errorResponse('API key and secret are required'));
  }

  try {
    const key = await AppDataSource.getRepository(ApiKey).findOne({
      where: { apiKey, apiSecret, isActive: true },
    });

    if (!key) {
      return res.status(403).json(errorResponse('Invalid API key or secret'));
    }

    // Update last used timestamp
    key.lastUsedAt = new Date();
    await AppDataSource.getRepository(ApiKey).save(key);

    (req as any).apiKey = key;
    next();
  } catch (error: any) {
    console.error('Error authenticating API key:', error);
    return res.status(500).json(errorResponse('Authentication error'));
  }
};

// GET /api/public/data - Get all public data
router.get('/data', authenticateApiKey, async (req, res) => {
  try {
    const [properties, countries, cities, areas, developers, facilities, courses] = await Promise.all([
      AppDataSource.getRepository(Property).find({
        relations: ['country', 'city', 'area', 'developer', 'facilities', 'units'],
        order: { createdAt: 'DESC' },
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
    const transformedProperties = properties.map(p => ({
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
      area: p.area ? {
        id: p.area.id,
        nameEn: p.area.nameEn,
        nameRu: p.area.nameRu,
        nameAr: p.area.nameAr,
      } : null,
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
    }));

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
router.get('/courses', authenticateApiKey, async (req, res) => {
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
router.get('/courses/:id', authenticateApiKey, async (req, res) => {
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

export default router;

