import { AppDataSource } from '../config/database';
import { Facility } from '../entities/Facility';

/**
 * Скрипт для оптимізації amenities (facilities)
 * Об'єднує схожі amenities та зменшує їх кількість до 100-150
 */

interface FacilityStats {
  id: string;
  nameEn: string;
  nameRu: string;
  nameAr: string;
  iconName: string;
  usageCount: number;
}

// Функція для нормалізації назви (прибирає зайві пробіли, приводить до lowercase)
function normalizeName(name: string): string {
  return name
    .toLowerCase()
    .trim()
    .replace(/\s+/g, ' ')
    .replace(/[^\w\s]/g, '')
    .replace(/\d+/g, '') // Прибираємо числа для порівняння
    .replace(/\b(24|247|24hr|24hrs|24h|24x7|24 x 7)\b/g, '24/7') // Нормалізуємо варіанти 24/7
    .replace(/\b(pool|pools)\b/g, 'pool') // Нормалізуємо pool/pools
    .replace(/\b(gym|gyms|gymnasium)\b/g, 'gym') // Нормалізуємо gym варіанти
    .replace(/\b(swimming\s+)?pool\b/g, 'swimming pool')
    .replace(/\b(security|camera|surveillance)\b/g, 'security')
    .replace(/\b(concierge|concierge service)\b/g, 'concierge')
    .replace(/\b(golf course|golf)\b/g, 'golf course')
    .replace(/\b(kids?|children|play area|playground)\b/g, 'kids play area')
    .replace(/\b(infinity\s+)?pool\b/g, 'infinity pool')
    .replace(/\b(restaurant|restaurants|cafe|cafes|dining)\b/g, 'restaurant');
}

// Функція для знаходження схожих назв
function areSimilar(name1: string, name2: string): boolean {
  const norm1 = normalizeName(name1);
  const norm2 = normalizeName(name2);
  
  // Точний збіг після нормалізації
  if (norm1 === norm2) return true;
  
  // Один містить інший (для варіантів типу "Swimming Pool" vs "Pool")
  if (norm1.includes(norm2) || norm2.includes(norm1)) {
    // Перевіряємо, що різниця не занадто велика
    const longer = norm1.length > norm2.length ? norm1 : norm2;
    const shorter = norm1.length > norm2.length ? norm2 : norm1;
    if (shorter.length >= 3 && longer.length >= shorter.length * 0.6) {
      return true; // Мінімум 60% співпадіння для коротких назв
    }
  }
  
  // Перевіряємо спільні ключові слова
  const words1 = norm1.split(/\s+/).filter(w => w.length > 2);
  const words2 = norm2.split(/\s+/).filter(w => w.length > 2);
  const commonWords = words1.filter(w => words2.includes(w));
  
  if (commonWords.length >= 2) {
    // Якщо є 2+ спільні слова, вважаємо схожими
    return true;
  }
  
  if (commonWords.length === 1 && words1.length <= 3 && words2.length <= 3) {
    // Для коротких назв з одним спільним словом
    return true;
  }
  
  return false;
}

async function optimizeFacilities() {
  try {
    await AppDataSource.initialize();
    console.log('✅ Database connected');

    const facilityRepo = AppDataSource.getRepository(Facility);
    
    // Отримуємо всі facilities з кількістю використання
    console.log('\n📊 Analyzing facilities...');
    
    // Отримуємо всі facilities
    const allFacilitiesRaw = await facilityRepo.find({
      order: { nameEn: 'ASC' },
    });

    // Отримуємо кількість використання для кожного facility
    const usageCounts = await AppDataSource.query(`
      SELECT "facilitiesId", COUNT(*) as count
      FROM properties_facilities_facilities
      GROUP BY "facilitiesId"
    `);

    const usageMap = new Map<string, number>();
    usageCounts.forEach((row: any) => {
      usageMap.set(String(row.facilitiesId), parseInt(String(row.count), 10));
    });

    const allFacilities = allFacilitiesRaw.map(f => ({
      f_id: f.id,
      f_nameEn: f.nameEn,
      f_nameRu: f.nameRu,
      f_nameAr: f.nameAr,
      f_iconName: f.iconName,
      usageCount: usageMap.get(f.id) || 0,
    })).sort((a, b) => b.usageCount - a.usageCount);

    console.log(`   Total facilities: ${allFacilities.length}`);
    console.log(`   Target: 100-150 facilities\n`);

    // Групуємо схожі facilities
    console.log('🔍 Finding similar facilities...');
    const groups: FacilityStats[][] = [];
    const processed = new Set<string>();

    for (const facility of allFacilities) {
      if (processed.has(facility.f_id)) continue;

      const group: FacilityStats[] = [{
        id: facility.f_id,
        nameEn: facility.f_nameEn,
        nameRu: facility.f_nameRu,
        nameAr: facility.f_nameAr,
        iconName: facility.f_iconName,
        usageCount: facility.usageCount || 0,
      }];

      processed.add(facility.f_id);

      // Шукаємо схожі
      for (const other of allFacilities) {
        if (processed.has(other.f_id)) continue;
        
        if (areSimilar(facility.f_nameEn, other.f_nameEn)) {
          group.push({
            id: other.f_id,
            nameEn: other.f_nameEn,
            nameRu: other.f_nameRu,
            nameAr: other.f_nameAr,
            iconName: other.f_iconName,
            usageCount: parseInt(other.usageCount) || 0,
          });
          processed.add(other.f_id);
        }
      }

      if (group.length > 1) {
        groups.push(group);
      }
    }

    console.log(`   Found ${groups.length} groups of similar facilities\n`);

    // Об'єднуємо групи (залишаємо найбільш використовуваний)
    console.log('🔗 Merging similar facilities...');
    let mergedCount = 0;

    for (const group of groups) {
      // Сортуємо за кількістю використання
      group.sort((a, b) => b.usageCount - a.usageCount);
      
      const keep = group[0]; // Залишаємо найбільш використовуваний
      const toMerge = group.slice(1);

      console.log(`   Merging ${toMerge.length} facilities into "${keep.nameEn}" (${keep.usageCount} uses)`);

      for (const merge of toMerge) {
        // Спочатку видаляємо зв'язки, які створять дублікати
        await AppDataSource.query(`
          DELETE FROM properties_facilities_facilities
          WHERE "facilitiesId" = $2
            AND "propertiesId" IN (
              SELECT "propertiesId"
              FROM properties_facilities_facilities
              WHERE "facilitiesId" = $1
            )
        `, [keep.id, merge.id]);
        
        // Потім оновлюємо решту зв'язків
        await AppDataSource.query(`
          UPDATE properties_facilities_facilities
          SET "facilitiesId" = $1
          WHERE "facilitiesId" = $2
        `, [keep.id, merge.id]);

        // Видаляємо об'єднаний facility
        await facilityRepo.delete(merge.id);
        mergedCount++;
      }
    }

    console.log(`\n✅ Merged ${mergedCount} facilities`);

    // Перевіряємо фінальну кількість
    const finalCount = await facilityRepo.count();
    console.log(`\n📊 Final facilities count: ${finalCount}`);

    if (finalCount > 150) {
      console.log(`\n⚠️  Still ${finalCount} facilities. Need to remove ${finalCount - 150} more.`);
      console.log('   Removing least used facilities...\n');

      // Видаляємо найменш використовувані (менше 2 використань)
      const leastUsedFacilities = await AppDataSource.query(`
        SELECT f.id, f."nameEn", COUNT(pf."propertiesId") as usage
        FROM facilities f
        LEFT JOIN properties_facilities_facilities pf ON f.id = pf."facilitiesId"
        GROUP BY f.id, f."nameEn"
        HAVING COUNT(pf."propertiesId") < 2
        ORDER BY COUNT(pf."propertiesId") ASC, f."nameEn"
        LIMIT $1
      `, [String(Math.min(finalCount - 150, finalCount))]);

      for (const facility of leastUsedFacilities) {
        // Видаляємо зв'язки
        await AppDataSource.query(`
          DELETE FROM properties_facilities_facilities
          WHERE "facilitiesId" = $1
        `, [facility.id]);
        
        // Видаляємо facility
        await facilityRepo.delete(facility.id);
        console.log(`   Removed facility: ${facility.nameEn || 'Unknown'} (${facility.usage || 0} uses)`);
      }

      const newCount = await facilityRepo.count();
      console.log(`\n✅ Final count after cleanup: ${newCount}`);
      
      // Якщо все ще більше 150, видаляємо ще менш використовувані
      if (newCount > 150) {
        const remainingToRemove = newCount - 150;
        console.log(`\n⚠️  Still ${newCount} facilities. Removing ${remainingToRemove} more least used...\n`);
        
        const moreLeastUsed = await AppDataSource.query(`
          SELECT f.id, f."nameEn", COUNT(pf."propertiesId") as usage
          FROM facilities f
          LEFT JOIN properties_facilities_facilities pf ON f.id = pf."facilitiesId"
          GROUP BY f.id, f."nameEn"
          HAVING COUNT(pf."propertiesId") < 5
          ORDER BY COUNT(pf."propertiesId") ASC, f."nameEn"
          LIMIT $1
        `, [String(remainingToRemove)]);

        for (const facility of moreLeastUsed) {
          await AppDataSource.query(`
            DELETE FROM properties_facilities_facilities
            WHERE "facilitiesId" = $1
          `, [facility.id]);
          
          await facilityRepo.delete(facility.id);
          console.log(`   Removed facility: ${facility.nameEn || 'Unknown'} (${facility.usage || 0} uses)`);
        }

        const finalNewCount = await facilityRepo.count();
        console.log(`\n✅ Final count: ${finalNewCount}`);
      }
    }

    console.log('\n✅ Optimization complete!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error);
    process.exit(1);
  }
}

optimizeFacilities();

