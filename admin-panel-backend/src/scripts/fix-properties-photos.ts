import 'reflect-metadata';
import { AppDataSource } from '../config/database';
import { Property } from '../entities/Property';

// Helper function to clean and normalize photos array (same as in routes)
function cleanPhotos(photos: any): string[] {
  if (!photos) return [];
  
  // If already an array
  if (Array.isArray(photos)) {
    const cleaned = photos
      .map((photo, index) => {
        // Skip numbers (they shouldn't be in photos array)
        if (typeof photo === 'number') {
          return null;
        }
        
        // If it's already a string URL, return it
        if (typeof photo === 'string') {
          const trimmed = photo.trim();
          // Skip empty strings or strings that are just "{}"
          if (trimmed.length === 0 || trimmed === '{}') {
            return null;
          }
          return trimmed;
        }
        
        // If it's an object with url property, extract the URL
        if (typeof photo === 'object' && photo !== null) {
          // Check if it's an empty object {}
          if (Object.keys(photo).length === 0) {
            return null;
          }
          // Try to extract URL from object
          if (photo.url && typeof photo.url === 'string') {
            return photo.url.trim();
          }
          // Try to stringify and parse if it's a JSON-like object
          try {
            const str = JSON.stringify(photo);
            if (str === '{}') return null;
            // If it looks like it might have been a URL stringified
            if (str.includes('http')) {
              const match = str.match(/https?:\/\/[^\s"']+/);
              if (match) return match[0];
            }
          } catch (e) {
            // Ignore JSON errors
          }
        }
        
        // Try to convert to string as last resort
        if (photo !== null && photo !== undefined) {
          const str = String(photo).trim();
          // Skip if it's just "{}" or "[object Object]"
          if (str === '{}' || str === '[object Object]') {
            return null;
          }
          // Only return if it looks like a URL
          if (str.startsWith('http://') || str.startsWith('https://')) {
            return str;
          }
        }
        return null;
      })
      .filter((url): url is string => {
        if (!url || url.length === 0) return false;
        // Filter out invalid URLs
        if (url === '{}' || url === '[object Object]') return false;
        // Must be a valid URL starting with http
        return url.startsWith('http://') || url.startsWith('https://');
      });
    
    return cleaned;
  }
  
  // If it's a string, try to parse it
  if (typeof photos === 'string') {
    // Try JSON array first
    if (photos.startsWith('[') && photos.endsWith(']')) {
      try {
        const parsed = JSON.parse(photos);
        if (Array.isArray(parsed)) {
          return cleanPhotos(parsed);
        }
      } catch (e) {
        // Not valid JSON, continue
      }
    }
    // Try comma-separated (TypeORM simple-array format)
    if (photos.includes(',')) {
      return photos
        .split(',')
        .map(p => p.trim())
        .filter(p => p.length > 0 && (p.startsWith('http://') || p.startsWith('https://')));
    }
    // Single URL
    if (photos.trim().length > 0 && (photos.startsWith('http://') || photos.startsWith('https://'))) {
      return [photos.trim()];
    }
  }
  
  return [];
}

async function fixPropertiesPhotos() {
  try {
    console.log('🚀 Starting fix for properties photos...\n');

    // Initialize database connection
    if (!AppDataSource.isInitialized) {
      await AppDataSource.initialize();
      console.log('✅ Database connected\n');
    }

    const propertyRepository = AppDataSource.getRepository(Property);
    const properties = await propertyRepository.find({});

    console.log(`📊 Found ${properties.length} properties to check\n`);

    let totalUpdated = 0;
    let totalFixed = 0;
    let totalRemoved = 0;
    let propertiesWithIssues = 0;

    for (const property of properties) {
      if (!property.photos || property.photos.length === 0) {
        continue;
      }

      // Check if there are any issues (numbers, objects, invalid strings)
      const hasIssues = property.photos.some((photo: any) => {
        if (typeof photo === 'number') return true;
        if (typeof photo === 'object' && photo !== null) return true;
        if (typeof photo === 'string') {
          const trimmed = photo.trim();
          if (trimmed === '{}' || trimmed === '' || (!trimmed.startsWith('http://') && !trimmed.startsWith('https://'))) {
            return true;
          }
        }
        return false;
      });

      if (!hasIssues) {
        continue; // Skip if no issues
      }

      propertiesWithIssues++;
      const originalLength = property.photos.length;
      const cleanedPhotos = cleanPhotos(property.photos);
      const removedCount = originalLength - cleanedPhotos.length;

      if (cleanedPhotos.length !== originalLength || removedCount > 0) {
        // Update property with cleaned photos
        property.photos = cleanedPhotos;
        await propertyRepository.save(property);

        totalUpdated++;
        totalFixed += cleanedPhotos.length;
        totalRemoved += removedCount;

        console.log(`✅ Fixed: ${property.name} (${property.id})`);
        console.log(`   Before: ${originalLength} photos`);
        console.log(`   After: ${cleanedPhotos.length} photos`);
        console.log(`   Removed: ${removedCount} invalid entries\n`);
      }
    }

    console.log('\n' + '='.repeat(60));
    console.log('✅ FIX COMPLETED!');
    console.log('='.repeat(60));
    console.log(`📊 Statistics:`);
    console.log(`   Total properties checked: ${properties.length}`);
    console.log(`   Properties with issues: ${propertiesWithIssues}`);
    console.log(`   Properties updated: ${totalUpdated}`);
    console.log(`   Valid photos kept: ${totalFixed}`);
    console.log(`   Invalid entries removed: ${totalRemoved}`);
    console.log('='.repeat(60));

    await AppDataSource.destroy();
    process.exit(0);
  } catch (error: any) {
    console.error('❌ Error fixing properties photos:', error);
    process.exit(1);
  }
}

// Run fix
fixPropertiesPhotos();

