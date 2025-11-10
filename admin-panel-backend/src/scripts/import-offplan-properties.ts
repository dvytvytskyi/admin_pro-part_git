import 'reflect-metadata';
import { AppDataSource } from '../config/database';
import { Property, PropertyType } from '../entities/Property';
import { PropertyUnit, UnitType } from '../entities/PropertyUnit';
import { Country } from '../entities/Country';
import { City } from '../entities/City';
import { Area } from '../entities/Area';
import { Developer } from '../entities/Developer';
import { Facility } from '../entities/Facility';
import * as fs from 'fs';
import * as path from 'path';
import * as process from 'process';

interface OffPlanPropertyData {
  id: string;
  propertyType: string;
  name: string;
  description: string;
  country: {
    id: string;
    nameEn: string;
    nameRu: string;
    nameAr: string;
    code: string;
  };
  city: {
    id: string;
    nameEn: string;
    nameRu: string;
    nameAr: string;
    countryId: string;
  };
  area: string; // Area name as string
  latitude: number;
  longitude: number;
  developer: {
    id: string;
    name: string;
    logo?: string | null;
  } | null;
  photos: Array<{
    id?: number;
    src: string;
    type?: string;
    logo?: string | null;
    alt?: string;
    title?: string;
    category?: string;
  }>;
  priceFrom: number;
  priceFromAED?: number;
  bedroomsFrom?: number;
  bedroomsTo?: number;
  bathroomsFrom?: number;
  bathroomsTo?: number;
  sizeFrom?: number;
  sizeTo?: number;
  paymentPlan?: string;
  units?: Array<{
    id: string;
    bedrooms?: number | null;
    bathrooms?: number | null;
  }>;
  facilities?: Array<{
    id: string;
    nameEn: string;
    nameRu: string;
    nameAr: string;
  }>;
  createdAt?: string;
  updatedAt?: string;
}

interface ParsedData {
  total: number;
  properties: OffPlanPropertyData[];
}

async function importOffPlanProperties() {
  try {
    console.log('🔄 Connecting to database...');
    await AppDataSource.initialize();
    console.log('✅ Database connected');

    const propertyRepository = AppDataSource.getRepository(Property);
    const unitRepository = AppDataSource.getRepository(PropertyUnit);
    const countryRepository = AppDataSource.getRepository(Country);
    const cityRepository = AppDataSource.getRepository(City);
    const areaRepository = AppDataSource.getRepository(Area);
    const developerRepository = AppDataSource.getRepository(Developer);
    const facilityRepository = AppDataSource.getRepository(Facility);

    // Read updated-offplan.json file
    const jsonPath = path.resolve(__dirname, '../../../updated-offplan.json');
    if (!fs.existsSync(jsonPath)) {
      throw new Error(`File not found: ${jsonPath}`);
    }

    console.log('📖 Reading JSON file...');
    const jsonContent = fs.readFileSync(jsonPath, 'utf-8').trim();
    const parsedData: ParsedData = JSON.parse(jsonContent);

    console.log(`📊 Found ${parsedData.properties.length} off-plan properties to import`);

    // Cache for entities
    const countryCache = new Map<string, Country>();
    const cityCache = new Map<string, City>();
    const areaCache = new Map<string, Area>();
    const developerCache = new Map<string, Developer>();
    const facilityCache = new Map<string, Facility>();

    let successCount = 0;
    let errorCount = 0;
    const errors: string[] = [];

    // Process each property
    for (let i = 0; i < parsedData.properties.length; i++) {
      const propertyData = parsedData.properties[i];

      try {
        // Validate required fields
        if (!propertyData.name || !propertyData.country || !propertyData.city || !propertyData.area) {
          errors.push(`Property ${i + 1}: Missing required fields (name, country, city, or area)`);
          errorCount++;
          continue;
        }

        // Validate coordinates
        if (!propertyData.latitude || propertyData.latitude === 0 ||
            !propertyData.longitude || propertyData.longitude === 0) {
          console.warn(`⚠️  Property ${i + 1} (${propertyData.name}): Invalid coordinates, skipping...`);
          errorCount++;
          continue;
        }

        // Validate price
        if (!propertyData.priceFrom || propertyData.priceFrom === 0) {
          console.warn(`⚠️  Property ${i + 1} (${propertyData.name}): Invalid priceFrom, skipping...`);
          errorCount++;
          continue;
        }

        // Get or find country by id
        let country = countryCache.get(propertyData.country.id);
        if (!country) {
          const foundCountry = await countryRepository.findOne({ where: { id: propertyData.country.id } });
          if (foundCountry) {
            country = foundCountry;
          } else {
            // Try to find by code
            const foundByCode = await countryRepository.findOne({ where: { code: propertyData.country.code } });
            if (foundByCode) {
              country = foundByCode;
            } else {
              // Create new country
              country = await countryRepository.save({
                id: propertyData.country.id,
                nameEn: propertyData.country.nameEn,
                nameRu: propertyData.country.nameRu,
                nameAr: propertyData.country.nameAr,
                code: propertyData.country.code,
              });
              console.log(`   └─ Created country: ${propertyData.country.nameEn}`);
            }
          }
          countryCache.set(propertyData.country.id, country);
        }

        // Get or find city by id
        let city = cityCache.get(propertyData.city.id);
        if (!city) {
          const foundCity = await cityRepository.findOne({ where: { id: propertyData.city.id } });
          if (foundCity) {
            city = foundCity;
          } else {
            // Try to find by name and country
            const foundByName = await cityRepository.findOne({
              where: { countryId: country.id, nameEn: propertyData.city.nameEn }
            });
            if (foundByName) {
              city = foundByName;
            } else {
              // Create new city
              city = await cityRepository.save({
                id: propertyData.city.id,
                countryId: country.id,
                nameEn: propertyData.city.nameEn,
                nameRu: propertyData.city.nameRu,
                nameAr: propertyData.city.nameAr,
              });
              console.log(`   └─ Created city: ${propertyData.city.nameEn}`);
            }
          }
          cityCache.set(propertyData.city.id, city);
        }

        // Find area by name (case-insensitive) within city
        const areaKey = `${city.id}_${propertyData.area.toLowerCase().trim()}`;
        let area = areaCache.get(areaKey);
        if (!area) {
          // Try to find by nameEn (case-insensitive)
          const foundArea = await areaRepository
            .createQueryBuilder('area')
            .where('area."cityId" = :cityId', { cityId: city.id })
            .andWhere('LOWER(area."nameEn") = LOWER(:name)', { name: propertyData.area.trim() })
            .getOne();

          if (foundArea) {
            area = foundArea;
          } else {
            // Try to find by nameRu (case-insensitive)
            const foundAreaRu = await areaRepository
              .createQueryBuilder('area')
              .where('area."cityId" = :cityId', { cityId: city.id })
              .andWhere('LOWER(area."nameRu") = LOWER(:name)', { name: propertyData.area.trim() })
              .getOne();

            if (foundAreaRu) {
              area = foundAreaRu;
            } else {
              // Create new area
              area = await areaRepository.save({
                cityId: city.id,
                nameEn: propertyData.area.trim(),
                nameRu: propertyData.area.trim(),
                nameAr: propertyData.area.trim(),
              });
              console.log(`   └─ Created area: ${propertyData.area}`);
            }
          }
          areaCache.set(areaKey, area);
        }

        // Get or find developer by id (if exists)
        let developerId: string | undefined = undefined;
        if (propertyData.developer && propertyData.developer.id) {
          let developer = developerCache.get(propertyData.developer.id);
          if (!developer) {
            const foundDeveloper = await developerRepository.findOne({ where: { id: propertyData.developer.id } });
            if (foundDeveloper) {
              developer = foundDeveloper;
            } else {
              // Try to find by name (case-insensitive)
              const foundByName = await developerRepository
                .createQueryBuilder('developer')
                .where('LOWER(developer.name) = LOWER(:name)', { name: propertyData.developer.name })
                .getOne();

              if (foundByName) {
                developer = foundByName;
              } else {
                // Create new developer
                developer = await developerRepository.save({
                  id: propertyData.developer.id,
                  name: propertyData.developer.name,
                  logo: propertyData.developer.logo || null,
                });
                console.log(`   └─ Created developer: ${propertyData.developer.name}`);
              }
            }
            developerCache.set(propertyData.developer.id, developer);
          }
          developerId = developer.id;
        }

        // Convert photos from array of objects to array of URLs
        const photoUrls: string[] = [];
        if (propertyData.photos && Array.isArray(propertyData.photos)) {
          for (const photo of propertyData.photos) {
            if (photo.src) {
              photoUrls.push(photo.src);
            }
          }
        }

        // Create property
        const property = propertyRepository.create({
          id: propertyData.id,
          propertyType: PropertyType.OFF_PLAN,
          name: propertyData.name,
          description: propertyData.description || '',
          photos: photoUrls,
          countryId: country.id,
          cityId: city.id,
          areaId: area.id,
          latitude: propertyData.latitude,
          longitude: propertyData.longitude,
          developerId: developerId || null,
          priceFrom: propertyData.priceFrom,
          bedroomsFrom: propertyData.bedroomsFrom || null,
          bedroomsTo: propertyData.bedroomsTo || null,
          bathroomsFrom: propertyData.bathroomsFrom || null,
          bathroomsTo: propertyData.bathroomsTo || null,
          sizeFrom: propertyData.sizeFrom || null,
          sizeTo: propertyData.sizeTo || null,
          paymentPlan: propertyData.paymentPlan || null,
        });

        const savedProperty = await propertyRepository.save(property);

        // Process units if they exist
        if (propertyData.units && Array.isArray(propertyData.units) && propertyData.units.length > 0) {
          for (const unitData of propertyData.units) {
            // Only create unit if it has meaningful data
            if (unitData.bedrooms !== null || unitData.bathrooms !== null) {
              const unit = unitRepository.create({
                propertyId: savedProperty.id,
                unitId: unitData.id || `unit-${Date.now()}-${Math.random()}`,
                type: UnitType.APARTMENT, // Default type
                totalSize: 0, // Default size
                price: propertyData.priceFrom, // Use property priceFrom as default
              });
              await unitRepository.save(unit);
            }
          }
        }

        // Process facilities if they exist
        if (propertyData.facilities && Array.isArray(propertyData.facilities) && propertyData.facilities.length > 0) {
          const facilityIds: string[] = [];
          for (const facilityData of propertyData.facilities) {
            let facility = facilityCache.get(facilityData.id);
            if (!facility) {
              const foundFacility = await facilityRepository.findOne({ where: { id: facilityData.id } });
              if (foundFacility) {
                facility = foundFacility;
              } else {
                // Try to find by nameEn
                const foundByName = await facilityRepository.findOne({
                  where: { nameEn: facilityData.nameEn }
                });
                if (foundByName) {
                  facility = foundByName;
                } else {
                  // Skip facility if not found (don't create new ones)
                  continue;
                }
              }
              facilityCache.set(facilityData.id, facility);
            }
            if (facility) {
              facilityIds.push(facility.id);
            }
          }

          // Link facilities to property
          if (facilityIds.length > 0) {
            await AppDataSource
              .createQueryBuilder()
              .relation(Property, 'facilities')
              .of(savedProperty.id)
              .add(facilityIds);
          }
        }

        successCount++;
        if ((i + 1) % 100 === 0) {
          console.log(`   ✅ Processed ${i + 1}/${parsedData.properties.length} properties...`);
        }
      } catch (error: any) {
        errorCount++;
        const errorMsg = `Property ${i + 1} (${propertyData.name}): ${error.message}`;
        errors.push(errorMsg);
        console.error(`❌ ${errorMsg}`);
      }
    }

    console.log('\n📈 Import Summary:');
    console.log(`   ✅ Success: ${successCount}`);
    console.log(`   ❌ Errors: ${errorCount}`);

    if (errors.length > 0) {
      console.log('\n📋 First 20 errors:');
      errors.slice(0, 20).forEach(err => console.log(`   - ${err}`));
      if (errors.length > 20) {
        console.log(`   ... and ${errors.length - 20} more errors`);
      }
    }

    // Verify import
    const finalCount = await propertyRepository.count({
      where: { propertyType: PropertyType.OFF_PLAN }
    });
    console.log(`\n📊 Total off-plan properties in database: ${finalCount}`);

    await AppDataSource.destroy();
    console.log('\n✅ Import completed');
    process.exit(0);
  } catch (error: any) {
    console.error('❌ Import failed:', error);
    if (AppDataSource.isInitialized) {
      await AppDataSource.destroy();
    }
    process.exit(1);
  }
}

// Run the import
importOffPlanProperties();

