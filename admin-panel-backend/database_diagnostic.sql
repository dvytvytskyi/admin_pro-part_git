-- ============================================
-- SQL ЗАПИТИ ДЛЯ ДІАГНОСТИКИ ПРОБЛЕМИ З /api/public/data
-- ============================================
-- Проблема: /api/public/data повертає лише об'єкти з одним area ID
-- ============================================

-- ============================================
-- ЗАПИТ 1: Перевірка кількості об'єктів по areaId
-- ============================================
-- Очікується: багато різних areaId з об'єктами
-- Якщо бачите лише один areaId → проблема в даних БД
SELECT 
  areaId, 
  COUNT(*) as property_count
FROM properties
GROUP BY areaId
ORDER BY property_count DESC;

-- ============================================
-- ЗАПИТ 2: Перевірка валідності зв'язків Properties ↔ Areas
-- ============================================
-- Очікується: порожній результат (всі об'єкти мають валідні areaId)
-- Якщо є результати → є об'єкти з невалідними або NULL areaId
SELECT 
  p.id as property_id,
  p.name as property_name,
  p.areaId,
  a.id as area_id,
  a.nameEn as area_name
FROM properties p
LEFT JOIN areas a ON p.areaId = a.id
WHERE p.areaId IS NULL OR a.id IS NULL
LIMIT 20;

-- ============================================
-- ЗАПИТ 3: Перевірка конкретних area IDs
-- ============================================
-- Перевірте, чи існують об'єкти для вибраних локацій
SELECT 
  areaId,
  COUNT(*) as count
FROM properties
WHERE areaId IN (
  '4811bb28-d527-4c12-a9dd-5ef08a16ed30', -- Bluewaters
  '7924f2dd-94bf-4ec3-b3fe-cbc5606a073a', -- Business Bay
  '24211934-94ef-4d71-aa94-900825858a4c'  -- Те що повертається
)
GROUP BY areaId;

-- ============================================
-- ЗАПИТ 4: Загальна статистика
-- ============================================
-- Перевірка загальної кількості об'єктів та унікальних areaId
SELECT 
  COUNT(*) as total_properties,
  COUNT(DISTINCT areaId) as unique_areas,
  COUNT(DISTINCT cityId) as unique_cities,
  COUNT(DISTINCT countryId) as unique_countries
FROM properties;

-- ============================================
-- ЗАПИТ 5: Перевірка всіх areaId в БД
-- ============================================
-- Всі areaId з кількістю об'єктів
-- Очікується: багато різних областей з об'єктами
SELECT 
  a.id as area_id,
  a.nameEn as area_name,
  a.nameRu as area_name_ru,
  COUNT(p.id) as property_count
FROM areas a
LEFT JOIN properties p ON p.areaId = a.id
GROUP BY a.id, a.nameEn, a.nameRu
ORDER BY property_count DESC;

-- ============================================
-- ЗАПИТ 6: Детальна інформація про об'єкти з конкретним areaId
-- ============================================
-- Перевірка, які об'єкти мають areaId '24211934-94ef-4d71-aa94-900825858a4c'
SELECT 
  p.id,
  p.name,
  p.areaId,
  a.nameEn as area_name,
  p.propertyType,
  p.createdAt
FROM properties p
LEFT JOIN areas a ON p.areaId = a.id
WHERE p.areaId = '24211934-94ef-4d71-aa94-900825858a4c'
ORDER BY p.createdAt DESC;

-- ============================================
-- ЗАПИТ 7: Перевірка, чи всі об'єкти мають однаковий areaId
-- ============================================
-- Якщо результат = 1 → всі об'єкти мають один areaId (ПРОБЛЕМА!)
SELECT 
  COUNT(DISTINCT areaId) as unique_area_count,
  COUNT(*) as total_properties
FROM properties;

-- ============================================
-- ЗАПИТ 8: Список всіх areaId з назвами та кількістю об'єктів
-- ============================================
SELECT 
  a.id,
  a.nameEn,
  a.nameRu,
  a.nameAr,
  COUNT(p.id) as property_count,
  STRING_AGG(p.name, ', ' ORDER BY p.createdAt DESC) as property_names
FROM areas a
LEFT JOIN properties p ON p.areaId = a.id
GROUP BY a.id, a.nameEn, a.nameRu, a.nameAr
HAVING COUNT(p.id) > 0
ORDER BY property_count DESC;

-- ============================================
-- ЗАПИТ 9: Перевірка останніх створених об'єктів
-- ============================================
-- Перевірка, які areaId мають останні створені об'єкти
SELECT 
  p.id,
  p.name,
  p.areaId,
  a.nameEn as area_name,
  p.createdAt
FROM properties p
LEFT JOIN areas a ON p.areaId = a.id
ORDER BY p.createdAt DESC
LIMIT 20;

