import express from 'express';
import { AppDataSource } from '../config/database';
import { Property } from '../entities/Property';
import { Country } from '../entities/Country';
import { City } from '../entities/City';
import { Area } from '../entities/Area';
import { Developer } from '../entities/Developer';
import { Facility } from '../entities/Facility';
import { Course } from '../entities/Course';
import { successResponse, errorResponse } from '../utils/response';
import { Conversions } from '../utils/conversions';
import { authenticateApiKeyWithSecret, AuthRequest } from '../middleware/auth';

const router = express.Router();

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
        images: a.images || null,
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
            images: areaRaw.images || null,
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
        images: (area as any).images || null,
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

export default router;

