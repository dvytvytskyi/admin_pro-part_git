import 'reflect-metadata';
import { AppDataSource } from '../config/database';
import { Area } from '../entities/Area';

// Helper function to validate and clean URL (same as in routes)
function validateAndCleanUrl(url: string): string | null {
  if (!url || typeof url !== 'string') return null;
  
  let cleaned = url.trim();
  
  // Remove null/undefined strings
  if (cleaned === 'null' || cleaned === 'undefined' || cleaned === '') return null;
  
  // Special case: if URL contains "oudinary.com" or truncated patterns, try to extract first valid URL
  // Pattern: https://res.cloudinary.com/.../areas/sobha-h...oudinary.com/dgv0...
  // This suggests two URLs concatenated or truncated
  if (cleaned.includes('oudinary.com') && cleaned.includes('res.cloudinary.com')) {
    // Find all occurrences of "https://res.cloudinary.com"
    const cloudinaryUrls = cleaned.match(/https:\/\/res\.cloudinary\.com\/[^\s"']+/g);
    if (cloudinaryUrls && cloudinaryUrls.length > 0) {
      // Use the first valid Cloudinary URL
      cleaned = cloudinaryUrls[0];
    } else {
      // Try to extract URL before truncation
      const beforeOudinary = cleaned.substring(0, cleaned.indexOf('oudinary.com'));
      // Find last valid Cloudinary URL pattern before truncation
      const lastCloudinaryMatch = beforeOudinary.match(/https:\/\/res\.cloudinary\.com\/[^\s"']+/);
      if (lastCloudinaryMatch) {
        cleaned = lastCloudinaryMatch[0];
      } else {
        return null;
      }
    }
  }
  
  // Find first valid HTTPS URL (most common case)
  const httpsUrlMatch = cleaned.match(/https:\/\/res\.cloudinary\.com\/[^\s"']+/);
  if (httpsUrlMatch) {
    cleaned = httpsUrlMatch[0];
  } else {
    // Try generic HTTPS URL
    const genericHttpsMatch = cleaned.match(/https:\/\/[^\s"']+/);
    if (genericHttpsMatch) {
      cleaned = genericHttpsMatch[0];
    } else {
      return null;
    }
  }
  
  // Remove truncation markers and everything after
  // Pattern: ...oudinary.com or ... in the middle
  if (cleaned.includes('...')) {
    // Find position of first truncation
    const truncationIndex = cleaned.indexOf('...');
    // Extract part before truncation
    let beforeTruncation = cleaned.substring(0, truncationIndex);
    
    // Try to find valid file extension before truncation
    const extensionPattern = /\.(jpg|jpeg|png|gif|webp)(\?.*)?$/i;
    const extensionMatch = beforeTruncation.match(extensionPattern);
    if (extensionMatch) {
      // Found extension, use up to extension
      cleaned = beforeTruncation.substring(0, beforeTruncation.lastIndexOf(extensionMatch[1]) + extensionMatch[1].length);
    } else {
      // No extension found, extract up to last slash before truncation
      const lastSlash = beforeTruncation.lastIndexOf('/');
      if (lastSlash > 0) {
        const afterSlash = beforeTruncation.substring(lastSlash + 1);
        if (afterSlash.length > 0 && !afterSlash.includes('...')) {
          cleaned = beforeTruncation;
        } else {
          cleaned = beforeTruncation.substring(0, lastSlash);
        }
      } else {
        cleaned = beforeTruncation;
      }
    }
  }
  
  // Remove any remaining invalid characters at the end
  cleaned = cleaned.replace(/(\.(jpg|jpeg|png|gif|webp))[^a-z0-9\?\/]*$/i, '$1');
  
  // Remove duplicate "cloudinary.com" or truncation patterns
  if (cleaned.match(/res\.cloudinary\.com.*res\.cloudinary\.com/)) {
    // Multiple cloudinary.com - extract first one
    const firstMatch = cleaned.match(/https:\/\/res\.cloudinary\.com\/[^\s"']+/);
    if (firstMatch) {
      cleaned = firstMatch[0];
    }
  }
  
  // Validate URL format
  try {
    const urlObj = new URL(cleaned);
    
    // Ensure it's a valid HTTP/HTTPS URL
    if (!['http:', 'https:'].includes(urlObj.protocol)) return null;
    
    // Ensure it has a valid hostname
    if (!urlObj.hostname || urlObj.hostname.length === 0) return null;
    
    // Ensure hostname is valid (not truncated)
    if (urlObj.hostname.includes('...') || urlObj.hostname.endsWith('.') || urlObj.hostname.includes('oudinary')) {
      return null;
    }
    
    // Ensure pathname doesn't contain truncation markers
    if (urlObj.pathname.includes('...') || urlObj.pathname.includes('oudinary')) {
      // Try to extract valid part before truncation
      const truncationPos = urlObj.pathname.indexOf('...');
      if (truncationPos > 0) {
        urlObj.pathname = urlObj.pathname.substring(0, truncationPos);
        cleaned = urlObj.toString();
      } else {
        return null;
      }
    }
    
    return cleaned;
  } catch (e) {
    // URL parsing failed
    return null;
  }
}

// Main function to fix corrupted URLs in database
async function fixCorruptedAreaImagesUrls() {
  try {
    console.log('🔄 Connecting to database...');
    await AppDataSource.initialize();
    console.log('✅ Database connected\n');

    const areaRepository = AppDataSource.getRepository(Area);

    // Get all areas with images
    const areas = await areaRepository.find({
      where: {},
    });

    console.log(`📊 Found ${areas.length} areas to check\n`);

    let totalAreasProcessed = 0;
    let totalAreasUpdated = 0;
    let totalUrlsFixed = 0;
    let totalUrlsRemoved = 0;

    for (const area of areas) {
      if (!area.images || area.images.length === 0) {
        continue;
      }

      totalAreasProcessed++;
      console.log(`\n📍 Processing area: ${area.nameEn} (${area.images.length} images)`);

      const fixedImages: string[] = [];
      let hasChanges = false;

      // Process each image URL
      for (let i = 0; i < area.images.length; i++) {
        const originalUrl = area.images[i];
        
        // Check if URL is corrupted (contains truncation markers or duplicate patterns)
        const isCorrupted = originalUrl.includes('...') || 
                           originalUrl.includes('oudinary.com') || 
                           originalUrl.match(/res\.cloudinary\.com.*res\.cloudinary\.com/);
        
        if (isCorrupted) {
          console.log(`  🔧 Fixing corrupted URL ${i + 1}: ${originalUrl.substring(0, 80)}...`);
          const cleanedUrl = validateAndCleanUrl(originalUrl);
          
          if (cleanedUrl && cleanedUrl !== originalUrl) {
            console.log(`  ✅ Fixed: ${cleanedUrl.substring(0, 80)}...`);
            fixedImages.push(cleanedUrl);
            hasChanges = true;
            totalUrlsFixed++;
          } else if (cleanedUrl === null) {
            console.log(`  ⚠️  Could not fix URL ${i + 1}, removing it`);
            totalUrlsRemoved++;
            hasChanges = true;
            // Don't add to fixedImages - URL is removed
          } else {
            // URL is already valid
            fixedImages.push(originalUrl);
          }
        } else {
          // URL looks valid, validate it anyway
          const cleanedUrl = validateAndCleanUrl(originalUrl);
          if (cleanedUrl) {
            fixedImages.push(cleanedUrl);
            if (cleanedUrl !== originalUrl) {
              hasChanges = true;
              totalUrlsFixed++;
            }
          } else {
            console.log(`  ⚠️  Invalid URL ${i + 1}, removing it: ${originalUrl.substring(0, 60)}...`);
            totalUrlsRemoved++;
            hasChanges = true;
          }
        }
      }

      // Update area with fixed URLs
      if (hasChanges) {
        // Use raw query to update array properly
        await AppDataSource.query(
          `UPDATE areas SET images = $1 WHERE id = $2`,
          [fixedImages, area.id]
        );
        console.log(`  ✅ Area updated: ${fixedImages.length} valid URLs (was ${area.images.length})`);
        totalAreasUpdated++;
      } else {
        console.log(`  ℹ️  No changes needed`);
      }
    }

    console.log('\n' + '='.repeat(60));
    console.log('✅ FIX COMPLETED!');
    console.log('='.repeat(60));
    console.log(`📊 Areas processed: ${totalAreasProcessed}`);
    console.log(`✅ Areas updated: ${totalAreasUpdated}`);
    console.log(`🔧 URLs fixed: ${totalUrlsFixed}`);
    console.log(`🗑️  URLs removed: ${totalUrlsRemoved}`);
    console.log('='.repeat(60) + '\n');

    await AppDataSource.destroy();
    process.exit(0);
  } catch (error: any) {
    console.error('❌ Error fixing corrupted URLs:', error);
    if (AppDataSource.isInitialized) {
      await AppDataSource.destroy();
    }
    process.exit(1);
  }
}

fixCorruptedAreaImagesUrls();

