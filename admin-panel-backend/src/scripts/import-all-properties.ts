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

// Interface for all_properties.json structure
interface AllPropertiesJson {
  total_properties: number;
  successful: number;
  failed: number;
  properties: Array<{
    basic_info: {
      area: string;
      coordinates: string;
      developer: string;
      min_price_aed: number;
      name: string;
      status: string;
    };
    details: {
      name: string;
      overview: string;
      area: string;
      city: string | null;
      country: string;
      coordinates: string;
      developer: string;
      developer_data?: {
        name: string;
        logo_image?: Array<{ url: string }>;
        description?: string;
      };
      cover_image_url?: string;
      cover?: { url: string };
      architecture?: Array<{ url: string }>;
      interior?: Array<{ url: string }>;
      lobby?: Array<{ url: string }>;
      buildings?: Array<Array<{ Building_image?: Array<{ url: string }> }>>;
      master_plan?: Array<{ url: string }>;
      facilities?: Array<{
        name: string;
        image?: { url: string };
      }>;
      min_price_aed?: number;
      max_price_aed?: number;
      min_area?: number;
      max_area?: number;
      payment_plans?: Array<{
        Plan_name: string;
        Payments: Array<Array<{
          Order: number;
          Payment_time: string;
          Percent_of_payment: string;
        }>>;
      }>;
      unit_blocks?: Array<{
        id: number;
        name: string;
        unit_type: string;
        normalized_type?: string;
        units_area_from_m2?: string;
        units_area_to_m2?: string;
        units_price_from_aed?: number;
        units_price_from?: number;
        typical_unit_image_url?: string;
      }>;
      unit_availability?: Array<{
        building_name: string;
        units: Array<{
          area_from: number;
          bedroom_type: string;
          price_from: number;
          price_from_aed?: number;
        }>;
      }>;
    };
  }>;
}

// Helper function to extract photos from all sources
function extractPhotos(details: AllPropertiesJson['properties'][0]['details']): string[] {
  const allPhotos: string[] = [];

  // Cover image URL (JSON string)
  if (details.cover_image_url) {
    try {
      const coverImg = JSON.parse(details.cover_image_url);
      if (coverImg.url) allPhotos.push(coverImg.url);
    } catch {
      if (typeof details.cover_image_url === 'string' && details.cover_image_url.startsWith('http')) {
        allPhotos.push(details.cover_image_url);
      }
    }
  }

  // Cover object
  if (details.cover?.url) allPhotos.push(details.cover.url);

  // Architecture
  if (details.architecture) {
    allPhotos.push(...details.architecture.map(img => img.url).filter(Boolean));
  }

  // Interior
  if (details.interior) {
    allPhotos.push(...details.interior.map(img => img.url).filter(Boolean));
  }

  // Lobby
  if (details.lobby) {
    allPhotos.push(...details.lobby.map(img => img.url).filter(Boolean));
  }

  // Buildings
  if (details.buildings) {
    details.buildings.forEach(buildingGroup => {
      buildingGroup.forEach(building => {
        if (building.Building_image) {
          allPhotos.push(...building.Building_image.map(img => img.url).filter(Boolean));
        }
      });
    });
  }

  // Master plan
  if (details.master_plan) {
    allPhotos.push(...details.master_plan.map(plan => plan.url).filter(Boolean));
  }

  // Facilities images (optional)
  if (details.facilities) {
    details.facilities.forEach(facility => {
      if (facility.image?.url) {
        allPhotos.push(facility.image.url);
      }
    });
  }

  // Remove duplicates
  return [...new Set(allPhotos.filter(Boolean))];
}

// Helper function to parse coordinates with fallback
function parseCoordinates(
  coordinates?: string,
  details?: AllPropertiesJson['properties'][0]['details'],
  basicInfo?: AllPropertiesJson['properties'][0]['basic_info']
): { lat: number; lng: number } | null {
  // Try 1: Main coordinates parameter
  if (coordinates) {
    try {
      const [lat, lng] = coordinates.split(',').map(coord => parseFloat(coord.trim()));
      if (!isNaN(lat) && !isNaN(lng) && lat !== 0 && lng !== 0) {
        return { lat, lng };
      }
    } catch {
      // Continue to next try
    }
  }

  // Try 2: details.coordinates
  if (details?.coordinates) {
    try {
      const [lat, lng] = String(details.coordinates).split(',').map(coord => parseFloat(coord.trim()));
      if (!isNaN(lat) && !isNaN(lng) && lat !== 0 && lng !== 0) {
        return { lat, lng };
      }
    } catch {
      // Continue to next try
    }
  }

  // Try 3: basicInfo.coordinates
  if (basicInfo?.coordinates) {
    try {
      const [lat, lng] = String(basicInfo.coordinates).split(',').map(coord => parseFloat(coord.trim()));
      if (!isNaN(lat) && !isNaN(lng) && lat !== 0 && lng !== 0) {
        return { lat, lng };
      }
    } catch {
      // Continue to next try
    }
  }

  // Try 4: Check if coordinates are in a different format (object with lat/lng)
  if (details && typeof details === 'object') {
    const detailsAny = details as any;
    if (detailsAny.latitude && detailsAny.longitude) {
      const lat = parseFloat(String(detailsAny.latitude));
      const lng = parseFloat(String(detailsAny.longitude));
      if (!isNaN(lat) && !isNaN(lng) && lat !== 0 && lng !== 0) {
        return { lat, lng };
      }
    }
    if (detailsAny.lat && detailsAny.lng) {
      const lat = parseFloat(String(detailsAny.lat));
      const lng = parseFloat(String(detailsAny.lng));
      if (!isNaN(lat) && !isNaN(lng) && lat !== 0 && lng !== 0) {
        return { lat, lng };
      }
    }
  }

  if (basicInfo && typeof basicInfo === 'object') {
    const basicInfoAny = basicInfo as any;
    if (basicInfoAny.latitude && basicInfoAny.longitude) {
      const lat = parseFloat(String(basicInfoAny.latitude));
      const lng = parseFloat(String(basicInfoAny.longitude));
      if (!isNaN(lat) && !isNaN(lng) && lat !== 0 && lng !== 0) {
        return { lat, lng };
      }
    }
    if (basicInfoAny.lat && basicInfoAny.lng) {
      const lat = parseFloat(String(basicInfoAny.lat));
      const lng = parseFloat(String(basicInfoAny.lng));
      if (!isNaN(lat) && !isNaN(lng) && lat !== 0 && lng !== 0) {
        return { lat, lng };
      }
    }
  }

  return null;
}

// Helper function to extract price with fallback logic
function extractPrice(
  details?: AllPropertiesJson['properties'][0]['details'],
  basicInfo?: AllPropertiesJson['properties'][0]['basic_info']
): number | null {
  // Try 1: details.min_price_aed or basicInfo.min_price_aed
  const minPriceAED = details?.min_price_aed || basicInfo?.min_price_aed;
  if (minPriceAED && minPriceAED > 0) {
    return minPriceAED / 3.673; // AED to USD
  }

  // Try 2: Extract from unit_blocks - find minimum price
  if (details?.unit_blocks && details.unit_blocks.length > 0) {
    const prices: number[] = [];
    details.unit_blocks.forEach(block => {
      if (block) {
        const priceAED = block.units_price_from_aed || block.units_price_from;
        if (priceAED && priceAED > 0) {
          prices.push(priceAED / 3.673); // AED to USD
        }
      }
    });
    if (prices.length > 0) {
      return Math.min(...prices);
    }
  }

  // Try 3: Extract from unit_availability
  if (details?.unit_availability && details.unit_availability.length > 0) {
    const prices: number[] = [];
    details.unit_availability.forEach(building => {
      if (building.units) {
        building.units.forEach(unit => {
          const priceAED = unit.price_from_aed || unit.price_from;
          if (priceAED && priceAED > 0) {
            prices.push(priceAED / 3.673); // AED to USD
          }
        });
      }
    });
    if (prices.length > 0) {
      return Math.min(...prices);
    }
  }

  return null;
}

// Helper function to extract bedrooms with fallback logic
function extractBedrooms(
  unitBlocks?: AllPropertiesJson['properties'][0]['details']['unit_blocks'],
  details?: AllPropertiesJson['properties'][0]['details'],
  basicInfo?: AllPropertiesJson['properties'][0]['basic_info']
): { from: number | null; to: number | null } {
  const bedrooms: number[] = [];

  // Try 1: Extract from unit_blocks name
  if (unitBlocks && unitBlocks.length > 0) {
    unitBlocks.forEach(block => {
      if (block && block.name) {
        const match = block.name.match(/(\d+)\s*bedroom/i);
        if (match) {
          bedrooms.push(parseInt(match[1]));
        }
      }
      // bedroom_type is in unit_availability, not unit_blocks
    });
  }

  // Try 2: Extract from unit_availability
  if (details?.unit_availability && details.unit_availability.length > 0) {
    details.unit_availability.forEach(building => {
      if (building.units) {
        building.units.forEach(unit => {
          if (unit.bedroom_type) {
            const match = String(unit.bedroom_type).match(/(\d+)/);
            if (match) {
              bedrooms.push(parseInt(match[1]));
            }
          }
        });
      }
    });
  }

  // Try 3: Search in description or other text fields
  const description = details?.overview || '';
  const descMatch = description.match(/(\d+)\s*(?:bedroom|bed)/i);
  if (descMatch) {
    bedrooms.push(parseInt(descMatch[1]));
  }

  if (bedrooms.length === 0) {
    return { from: null, to: null };
  }

  return {
    from: Math.min(...bedrooms),
    to: Math.max(...bedrooms),
  };
}

// Helper function to extract size with fallback logic
function extractSize(
  unitBlocks?: AllPropertiesJson['properties'][0]['details']['unit_blocks'],
  details?: AllPropertiesJson['properties'][0]['details'],
  basicInfo?: AllPropertiesJson['properties'][0]['basic_info']
): { from: number | null; to: number | null } {
  const sizes: number[] = [];

  // Try 1: Extract from unit_blocks (already in m²)
  if (unitBlocks && unitBlocks.length > 0) {
    unitBlocks.forEach(block => {
      if (block) {
        if (block.units_area_from_m2) {
          const size = parseFloat(block.units_area_from_m2);
          if (!isNaN(size) && size > 0) {
            sizes.push(size);
          }
        }
        if (block.units_area_to_m2) {
          const size = parseFloat(block.units_area_to_m2);
          if (!isNaN(size) && size > 0) {
            sizes.push(size);
          }
        }
      }
    });
  }

  // Try 2: Extract from details.min_area / max_area (in sqft, convert to m²)
  if (details?.min_area) {
    const size = parseFloat(String(details.min_area));
    if (!isNaN(size) && size > 0) {
      sizes.push(size / 10.764); // sqft to m²
    }
  }
  if (details?.max_area) {
    const size = parseFloat(String(details.max_area));
    if (!isNaN(size) && size > 0) {
      sizes.push(size / 10.764); // sqft to m²
    }
  }

  // Try 3: Extract from unit_availability (in sqft, convert to m²)
  if (details?.unit_availability && details.unit_availability.length > 0) {
    details.unit_availability.forEach(building => {
      if (building.units) {
        building.units.forEach(unit => {
          if (unit.area_from) {
            const size = parseFloat(String(unit.area_from));
            if (!isNaN(size) && size > 0) {
              sizes.push(size / 10.764); // sqft to m²
            }
          }
          // area_to is not in unit_availability structure
        });
      }
    });
  }

  // Try 4: Extract from details if available
  if (details?.min_area) {
    const size = parseFloat(String(details.min_area));
    if (!isNaN(size) && size > 0) {
      sizes.push(size / 10.764); // sqft to m²
    }
  }
  if (details?.max_area) {
    const size = parseFloat(String(details.max_area));
    if (!isNaN(size) && size > 0) {
      sizes.push(size / 10.764); // sqft to m²
    }
  }

  if (sizes.length === 0) {
    return { from: null, to: null };
  }

  return {
    from: Math.min(...sizes),
    to: Math.max(...sizes),
  };
}

// Helper function to format payment plan
function formatPaymentPlan(paymentPlans?: AllPropertiesJson['properties'][0]['details']['payment_plans']): string | null {
  if (!paymentPlans || paymentPlans.length === 0) {
    return null;
  }

  return paymentPlans
    .map(plan => {
      const payments = plan.Payments.map((paymentGroup, idx) => {
        const payment = paymentGroup[0];
        return `${payment.Payment_time}: ${payment.Percent_of_payment}%`;
      }).join(', ');
      return `${plan.Plan_name}: ${payments}`;
    })
    .join(' | ');
}

// Helper function to map unit type
function mapUnitType(unitType: string): UnitType {
  const normalized = unitType.toLowerCase();
  if (normalized.includes('apartment')) return UnitType.APARTMENT;
  if (normalized.includes('villa')) return UnitType.VILLA;
  if (normalized.includes('townhouse')) return UnitType.TOWNHOUSE;
  if (normalized.includes('penthouse')) return UnitType.PENTHOUSE;
  if (normalized.includes('office')) return UnitType.OFFICE;
  return UnitType.APARTMENT; // Default
}

// Helper function to parse image URL from JSON string
function parseImageUrl(imageUrl?: string): string | null {
  if (!imageUrl) return null;
  try {
    const parsed = JSON.parse(imageUrl);
    if (Array.isArray(parsed) && parsed[0]?.url) {
      return parsed[0].url;
    }
    if (parsed.url) {
      return parsed.url;
    }
  } catch {
    if (imageUrl.startsWith('http')) {
      return imageUrl;
    }
  }
  return null;
}

// Helper function to generate icon name from facility name
function generateIconName(facilityName: string): string {
  return facilityName
    .toLowerCase()
    .replace(/[^a-z0-9\s]/g, '')
    .replace(/\s+/g, '-')
    .trim() || 'facility';
}

async function importAllProperties() {
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

    // Read all_properties.json file
    const possiblePaths = [
      path.resolve(__dirname, '../../../all_properties.json'),
      path.resolve(process.cwd(), 'all_properties.json'),
      '/app/all_properties.json',
      path.join(process.cwd(), 'all_properties.json'),
    ];

    let jsonPath: string | null = null;
    for (const possiblePath of possiblePaths) {
      if (fs.existsSync(possiblePath)) {
        jsonPath = possiblePath;
        break;
      }
    }

    if (!jsonPath) {
      throw new Error(`File not found. Tried: ${possiblePaths.join(', ')}`);
    }

    console.log('📖 Reading JSON file...');
    const fileStartTime = Date.now();
    const jsonContent = fs.readFileSync(jsonPath, 'utf-8').trim();
    const fileReadTime = ((Date.now() - fileStartTime) / 1000).toFixed(2);
    console.log(`✅ File read in ${fileReadTime}s`);
    
    console.log('🔄 Parsing JSON...');
    const parseStartTime = Date.now();
    const data: AllPropertiesJson = JSON.parse(jsonContent);
    const parseTime = ((Date.now() - parseStartTime) / 1000).toFixed(2);
    console.log(`✅ JSON parsed in ${parseTime}s\n`);

    const totalProperties = data.successful;
    console.log('📊 Import Statistics:');
    console.log(`   • Total properties in file: ${data.total_properties}`);
    console.log(`   • Successful properties: ${totalProperties}`);
    console.log(`   • Failed properties: ${data.failed}`);
    console.log(`   • Properties to import: ${data.properties.length}\n`);
    console.log('🚀 Starting import...\n');

    // Collections for export
    const developersSet = new Set<string>();
    const amenitiesSet = new Set<string>();
    const areasSet = new Set<string>();

    // Cache for entities
    const countryCache = new Map<string, Country>();
    const cityCache = new Map<string, City>();
    const areaCache = new Map<string, Area>();
    const developerCache = new Map<string, Developer>();
    const facilityCache = new Map<string, Facility>();

    let successCount = 0;
    let errorCount = 0;
    const errors: string[] = [];
    const startTime = Date.now();

    console.log('🚀 Starting import process...\n');

    // Process each property
    for (let i = 0; i < data.properties.length; i++) {
      const property = data.properties[i];
      
      // Skip if property structure is invalid
      if (!property || !property.details || !property.basic_info) {
        errors.push(`Property ${i + 1}: Invalid property structure (missing details or basic_info)`);
        errorCount++;
        continue;
      }
      
      const details = property.details;
      const basicInfo = property.basic_info;
      const propertyName = details?.name || basicInfo?.name || `Property ${i + 1}`;

      try {
        // Validate required fields
        const name = details?.name || basicInfo?.name;
        const areaName = details?.area || basicInfo?.area;
        const countryName = details?.country;
        const cityName = details?.city || 'Dubai'; // Default to Dubai

        if (!name || !areaName || !countryName) {
          errors.push(`Property ${i + 1}: Missing required fields (name, area, or country)`);
          errorCount++;
          continue;
        }

        // Parse coordinates with fallback (coordinates can be in multiple places)
        const coords = parseCoordinates(
          details?.coordinates || basicInfo?.coordinates,
          details,
          basicInfo
        );
        if (!coords) {
          errors.push(`Property ${i + 1} (${name}): Invalid coordinates`);
          errorCount++;
          continue;
        }

        // Extract photos
        const photos = details ? extractPhotos(details) : [];
        if (photos.length === 0 && (i + 1) % 100 === 0) {
          console.log(`\n⚠️  Warning: Property ${i + 1} (${propertyName}) has no photos`);
        }

        // Find or create Country
        let country = countryCache.get(countryName);
        if (!country) {
          const foundCountry = await countryRepository.findOne({ where: { nameEn: countryName } });
          if (foundCountry) {
            country = foundCountry;
          } else {
            const newCountry = countryRepository.create({
              nameEn: countryName,
              nameRu: countryName,
              nameAr: countryName,
              code: 'AE', // Default to UAE
            });
            country = await countryRepository.save(newCountry);
          }
          if (country) {
            countryCache.set(countryName, country);
          }
        }
        
        if (!country) {
          errors.push(`Property ${i + 1} (${name}): Failed to create/find country`);
          errorCount++;
          continue;
        }

        // Find or create City
        let city = cityCache.get(cityName);
        if (!city) {
          const foundCity = await cityRepository.findOne({
            where: { nameEn: cityName, countryId: country.id },
          });
          if (foundCity) {
            city = foundCity;
          } else {
            const newCity = cityRepository.create({
              nameEn: cityName,
              nameRu: cityName,
              nameAr: cityName,
              countryId: country.id,
            });
            city = await cityRepository.save(newCity);
          }
          if (city) {
            cityCache.set(cityName, city);
          }
        }
        
        if (!city) {
          errors.push(`Property ${i + 1} (${name}): Failed to create/find city`);
          errorCount++;
          continue;
        }

        // Find or create Area
        areasSet.add(areaName); // Add to export set
        const areaKey = `${cityName}:${areaName}`;
        let area = areaCache.get(areaKey);
        if (!area) {
          const foundArea = await areaRepository.findOne({
            where: { nameEn: areaName, cityId: city.id },
          });
          if (foundArea) {
            area = foundArea;
          } else {
            const newArea = areaRepository.create({
              nameEn: areaName,
              nameRu: areaName,
              nameAr: areaName,
              cityId: city.id,
            });
            area = await areaRepository.save(newArea);
          }
          if (area) {
            areaCache.set(areaKey, area);
          }
        }
        
        if (!area) {
          errors.push(`Property ${i + 1} (${name}): Failed to create/find area`);
          errorCount++;
          continue;
        }

        // Find or create Developer
        const developerName = details?.developer || basicInfo?.developer;
        let developer: Developer | undefined = undefined;
        if (developerName) {
          developersSet.add(developerName); // Add to export set
          developer = developerCache.get(developerName);
          if (!developer) {
            const foundDeveloper = await developerRepository.findOne({ where: { name: developerName } });
            if (foundDeveloper) {
              developer = foundDeveloper;
            } else if (details?.developer_data) {
              const logoUrl = details.developer_data.logo_image?.[0]?.url || undefined;
              const newDeveloper = developerRepository.create({
                name: developerName,
                logo: logoUrl,
                description: details.developer_data.description || undefined,
              });
              developer = await developerRepository.save(newDeveloper) as Developer;
            }
            if (developer) {
              developerCache.set(developerName, developer);
            }
          }
        }

        // Extract price with fallback logic
        const priceFrom = extractPrice(details, basicInfo);

        // Extract bedrooms with fallback logic
        const bedrooms = extractBedrooms(details?.unit_blocks, details, basicInfo);

        // Extract size with fallback logic
        const size = extractSize(details?.unit_blocks, details, basicInfo);

        // Format payment plan
        const paymentPlan = formatPaymentPlan(details?.payment_plans);

        // Create Property
        const propertyData = propertyRepository.create({
          propertyType: PropertyType.OFF_PLAN,
          name: name || `Property ${i + 1}`,
          description: details?.overview || '',
          photos: photos.length > 0 ? photos : [],
          countryId: country.id,
          cityId: city.id,
          areaId: area.id,
          latitude: coords.lat,
          longitude: coords.lng,
          developerId: developer?.id || undefined,
          priceFrom: priceFrom || undefined,
          bedroomsFrom: bedrooms.from || undefined,
          bedroomsTo: bedrooms.to || undefined,
          bathroomsFrom: undefined,
          bathroomsTo: undefined,
          sizeFrom: size.from || undefined,
          sizeTo: size.to || undefined,
          paymentPlan: paymentPlan || undefined,
        });

        const savedProperty = await propertyRepository.save(propertyData) as Property;

        // Create Units
        if (details?.unit_blocks && details.unit_blocks.length > 0) {
          for (const unitBlock of details.unit_blocks) {
            if (!unitBlock || !unitBlock.id) {
              continue; // Skip invalid unit blocks
            }
            
            const unitSize = unitBlock.units_area_from_m2
              ? parseFloat(unitBlock.units_area_from_m2)
              : unitBlock.units_area_to_m2
              ? parseFloat(unitBlock.units_area_to_m2)
              : 0;

            if (isNaN(unitSize) || unitSize <= 0) {
              continue; // Skip units with invalid size
            }

            const unitPriceAED = unitBlock.units_price_from_aed || unitBlock.units_price_from || 0;
            const unitPrice = unitPriceAED > 0 ? unitPriceAED / 3.673 : 0; // AED to USD

            const planImage = parseImageUrl(unitBlock.typical_unit_image_url);

            const unit = unitRepository.create({
              property: savedProperty,
              unitId: String(unitBlock.id),
              type: mapUnitType(unitBlock.unit_type || unitBlock.normalized_type || 'Apartments'),
              planImage: planImage || undefined,
              totalSize: unitSize,
              balconySize: undefined,
              price: unitPrice,
            });

            await unitRepository.save(unit);
          }
        } else if (details?.unit_availability && details.unit_availability.length > 0) {
          // Fallback to unit_availability
          for (const building of details.unit_availability) {
            for (const unit of building.units) {
              const unitSize = unit.area_from ? unit.area_from / 10.764 : 0; // sqft to m²
              const unitPriceAED = unit.price_from_aed || unit.price_from || 0;
              const unitPrice = unitPriceAED / 3.673; // AED to USD

              const unitData = unitRepository.create({
                property: savedProperty,
                unitId: `${building.building_name}-${unit.bedroom_type}-${unit.price_from}`,
                type: UnitType.APARTMENT,
                planImage: undefined,
                totalSize: unitSize,
                balconySize: undefined,
                price: unitPrice,
              });

              await unitRepository.save(unitData);
            }
          }
        }

        // Find or create Facilities
        const facilityIds: string[] = [];
        if (details?.facilities && details.facilities.length > 0) {
          for (const facilityData of details.facilities) {
            amenitiesSet.add(facilityData.name); // Add to export set

            let facility = facilityCache.get(facilityData.name);
            if (!facility) {
              const foundFacility = await facilityRepository.findOne({
                where: { nameEn: facilityData.name },
              });
              if (foundFacility) {
                facility = foundFacility;
              } else {
                const iconName = generateIconName(facilityData.name);
                const newFacility = facilityRepository.create({
                  nameEn: facilityData.name,
                  nameRu: facilityData.name,
                  nameAr: facilityData.name,
                  iconName,
                });
                facility = await facilityRepository.save(newFacility);
              }
              if (facility) {
                facilityCache.set(facilityData.name, facility);
              }
            }
            if (facility) {
              facilityIds.push(facility.id);
            }
          }
        }

        // Link facilities to property
        if (facilityIds.length > 0) {
          await AppDataSource.createQueryBuilder()
            .relation(Property, 'facilities')
            .of(savedProperty.id)
            .add(facilityIds);
        }

        successCount++;

        // Progress indicators
        const progress = ((i + 1) / data.properties.length) * 100;
        const filled = Math.floor(progress / 2);
        const empty = 50 - filled;
        const elapsed = (Date.now() - startTime) / 1000; // seconds
        const rate = elapsed > 0 ? (i + 1) / elapsed : 0; // properties per second
        const remaining = data.properties.length - (i + 1);
        const eta = rate > 0 ? remaining / rate : 0; // estimated seconds remaining

        // Clear line and write progress
        process.stdout.write('\r\x1b[K'); // Clear line
        process.stdout.write(
          `📊 Progress: [${'='.repeat(filled)}${' '.repeat(empty)}] ${(i + 1)}/${data.properties.length} (${progress.toFixed(1)}%) | ✅ ${successCount} | ❌ ${errorCount} | ⚡ ${rate.toFixed(1)}/s | ⏱️  ETA: ${Math.floor(eta / 60)}m ${Math.floor(eta % 60)}s | 🔄 ${propertyName.substring(0, 40)}...`
        );
        
        // Log every 50 properties
        if ((i + 1) % 50 === 0) {
          console.log(`\n📈 Checkpoint: ${i + 1}/${data.properties.length} processed | Success: ${successCount} | Errors: ${errorCount}`);
        }
      } catch (error: any) {
        errorCount++;
        const errorMsg = `Property ${i + 1} (${propertyName}): ${error.message}`;
        errors.push(errorMsg);
        
        // Clear progress line and show error, then continue with progress bar
        process.stdout.write('\r\x1b[K'); // Clear line
        if (errorCount <= 10) { // Only show first 10 errors in console
          console.error(`❌ Error: ${errorMsg.substring(0, 100)}`);
        }
        
        // Continue with progress
        const progress = ((i + 1) / data.properties.length) * 100;
        const filled = Math.floor(progress / 2);
        const empty = 50 - filled;
        const elapsed = (Date.now() - startTime) / 1000;
        const rate = elapsed > 0 ? (i + 1) / elapsed : 0;
        const remaining = data.properties.length - (i + 1);
        const eta = rate > 0 ? remaining / rate : 0;
        process.stdout.write(
          `📊 Progress: [${'='.repeat(filled)}${' '.repeat(empty)}] ${(i + 1)}/${data.properties.length} (${progress.toFixed(1)}%) | ✅ ${successCount} | ❌ ${errorCount} | ⚡ ${rate.toFixed(1)}/s | ⏱️  ETA: ${Math.floor(eta / 60)}m ${Math.floor(eta % 60)}s`
        );
      }
    }

    // Final summary
    const totalTime = (Date.now() - startTime) / 1000;
    console.log('\n\n' + '='.repeat(80));
    console.log('✅ IMPORT COMPLETED!');
    console.log('='.repeat(80));
    console.log(`📊 Total Properties: ${data.properties.length}`);
    console.log(`✅ Successfully imported: ${successCount}`);
    console.log(`❌ Errors: ${errorCount}`);
    console.log(`⏱️  Total time: ${Math.floor(totalTime / 60)}m ${Math.floor(totalTime % 60)}s`);
    console.log(`⚡ Average rate: ${(successCount / totalTime).toFixed(2)} properties/second`);
    console.log('='.repeat(80));

    // Export collections to files
    const exportDir = path.resolve(__dirname, '../../../');
    const developersFile = path.join(exportDir, 'exported-developers.json');
    const amenitiesFile = path.join(exportDir, 'exported-amenities.json');
    const areasFile = path.join(exportDir, 'exported-areas.json');

    console.log('\n📤 Exporting collections for synchronization...');
    console.log('='.repeat(80));

    // Export developers
    const developersArray = Array.from(developersSet).sort();
    fs.writeFileSync(
      developersFile,
      JSON.stringify(developersArray, null, 2),
      'utf-8'
    );
    console.log(`✅ Developers: ${developersArray.length} exported to exported-developers.json`);

    // Export amenities
    const amenitiesArray = Array.from(amenitiesSet).sort();
    fs.writeFileSync(
      amenitiesFile,
      JSON.stringify(amenitiesArray, null, 2),
      'utf-8'
    );
    console.log(`✅ Amenities: ${amenitiesArray.length} exported to exported-amenities.json`);

    // Export areas
    const areasArray = Array.from(areasSet).sort();
    fs.writeFileSync(
      areasFile,
      JSON.stringify(areasArray, null, 2),
      'utf-8'
    );
    console.log(`✅ Areas: ${areasArray.length} exported to exported-areas.json`);
    
    console.log('='.repeat(80));
    console.log('💡 Tip: Review these files and synchronize with your admin panel');
    console.log('='.repeat(80));

    if (errors.length > 0) {
      console.log('\n⚠️  ERROR SUMMARY:');
      console.log('='.repeat(80));
      const errorLimit = Math.min(20, errors.length);
      errors.slice(0, errorLimit).forEach((error, idx) => {
        console.log(`  ${idx + 1}. ${error.substring(0, 120)}`);
      });
      if (errors.length > errorLimit) {
        console.log(`  ... and ${errors.length - errorLimit} more errors (see full log above)`);
      }
      console.log('='.repeat(80));
      
      // Save errors to file
      const errorsFile = path.join(exportDir, 'import-errors.json');
      fs.writeFileSync(
        errorsFile,
        JSON.stringify(errors, null, 2),
        'utf-8'
      );
      console.log(`\n📄 Full error log saved to: import-errors.json`);
    }

    await AppDataSource.destroy();
    console.log('\n✅ Done');
    process.exit(0);
  } catch (error: any) {
    console.error('❌ Error importing properties:', error);
    if (AppDataSource.isInitialized) {
      await AppDataSource.destroy();
    }
    process.exit(1);
  }
}

importAllProperties();

