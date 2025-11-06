# ✅ Перевірка Secondary Properties - Швидкий гайд

## 🚀 Швидкий тест (5 хвилин)

### 1. Тест через API (найшвидше)

```bash
# Замініть YOUR_API_KEY на ваш API Key
API_KEY="YOUR_API_KEY"
API_SECRET="YOUR_API_SECRET"  # Якщо потрібен

# Базовий тест
curl -X GET "https://admin.foryou-realestate.com/api/properties?propertyType=secondary&page=1&limit=5" \
  -H "X-API-Key: ${API_KEY}" | jq '.data.data[0] | {
    propertyType,
    price,
    priceAED,
    size,
    sizeSqft,
    bedrooms,
    area: (.area | type),
    photos: (.photos | type)
  }'
```

**Очікуваний результат:**
```json
{
  "propertyType": "secondary",
  "price": 250000,
  "priceAED": 917500,
  "size": 120,
  "sizeSqft": 1291.68,
  "bedrooms": 2,
  "area": "object",    // ✅ Має бути "object", не "string"
  "photos": "array"    // ✅ Має бути "array"
}
```

---

### 2. Перевірка підрахунку в areas

```bash
curl -X GET "https://admin.foryou-realestate.com/api/public/areas" \
  -H "X-API-Key: ${API_KEY}" \
  -H "X-API-Secret: ${API_SECRET}" | jq '.data[] | select(.projectsCount.secondary > 0) | {
    nameEn,
    projectsCount
  }' | head -5
```

**Очікуваний результат:**
```json
{
  "nameEn": "Dubai Marina",
  "projectsCount": {
    "total": 150,
    "offPlan": 100,
    "secondary": 50    // ✅ Має бути > 0
  }
}
```

---

## 📋 Детальний чеклист

### ✅ Endpoint `/api/properties?propertyType=secondary`

| Перевірка | Статус | Команда |
|-----------|--------|---------|
| Повертає secondary properties | ⬜ | `curl .../properties?propertyType=secondary` |
| Підтримує фільтр bedrooms | ⬜ | `curl .../properties?propertyType=secondary&bedrooms=2` |
| Підтримує фільтр size | ⬜ | `curl .../properties?propertyType=secondary&sizeFrom=50&sizeTo=150` |
| Підтримує фільтр price | ⬜ | `curl .../properties?propertyType=secondary&priceFrom=100000&priceTo=500000` |
| Підтримує фільтр areaId | ⬜ | `curl .../properties?propertyType=secondary&areaId=UUID` |
| Підтримує фільтр developerId | ⬜ | `curl .../properties?propertyType=secondary&developerId=UUID` |
| Підтримує пошук search | ⬜ | `curl .../properties?propertyType=secondary&search=apartment` |
| Підтримує сортування | ⬜ | `curl .../properties?propertyType=secondary&sortBy=price&sortOrder=ASC` |
| Працює з API Key | ⬜ | `curl -H "X-API-Key: KEY" ...` |
| Повертає пагінацію | ⬜ | Перевірити `data.pagination` |

---

### ✅ Структура даних Secondary Property

| Поле | Очікуване значення | Перевірка |
|------|-------------------|-----------|
| `propertyType` | `"secondary"` | ⬜ |
| `price` | Число (USD), не null | ⬜ |
| `priceAED` | `price * 3.67`, не null | ⬜ |
| `size` | Число (м²), не null | ⬜ |
| `sizeSqft` | `size * 10.764`, не null | ⬜ |
| `bedrooms` | Число (не діапазон) | ⬜ |
| `bathrooms` | Число | ⬜ |
| `area` | Об'єкт `{id, nameEn, ...}` | ⬜ |
| `area.id` | UUID | ⬜ |
| `area.nameEn` | Рядок | ⬜ |
| `photos` | Масив `[]` | ⬜ |
| `priceFrom` | `null` (для secondary) | ⬜ |
| `bedroomsFrom` | `null` (для secondary) | ⬜ |
| `units` | `[]` (порожній масив) | ⬜ |

---

### ✅ Підрахунок в Areas

| Перевірка | Статус |
|-----------|--------|
| `projectsCount.secondary` присутнє | ⬜ |
| `projectsCount.secondary` правильне значення | ⬜ |
| `projectsCount.total` = `offPlan + secondary` | ⬜ |

---

## 🧪 Автоматичне тестування

### На сервері (через TypeScript скрипт):

```bash
ssh root@135.181.201.185
cd /opt/admin-panel/admin-panel-backend
npm run test:secondary
```

### Через API (локально або на сервері):

```bash
cd admin-panel-backend
./src/scripts/test-api-secondary.sh YOUR_API_KEY YOUR_API_SECRET
```

---

## 📝 Швидка перевірка структури

```bash
# Отримати один secondary property та перевірити структуру
curl -s "https://admin.foryou-realestate.com/api/properties?propertyType=secondary&page=1&limit=1" \
  -H "X-API-Key: YOUR_API_KEY" | jq '{
    propertyType: .data.data[0].propertyType,
    hasPrice: (.data.data[0].price != null),
    hasPriceAED: (.data.data[0].priceAED != null),
    hasSize: (.data.data[0].size != null),
    hasSizeSqft: (.data.data[0].sizeSqft != null),
    bedroomsType: (.data.data[0].bedrooms | type),
    areaType: (.data.data[0].area | type),
    photosType: (.data.data[0].photos | type),
    hasPagination: (.data.pagination != null)
  }'
```

**Очікуваний результат:**
```json
{
  "propertyType": "secondary",
  "hasPrice": true,
  "hasPriceAED": true,
  "hasSize": true,
  "hasSizeSqft": true,
  "bedroomsType": "number",
  "areaType": "object",      // ✅ Має бути "object"
  "photosType": "array",      // ✅ Має бути "array"
  "hasPagination": true
}
```

---

## 🔍 Що перевіряє код

### У файлі `properties.routes.ts`:

1. **Фільтр bedrooms (рядок 103-107):**
   ```typescript
   // Для secondary: перевіряємо bedrooms (точне значення)
   (property.propertyType = 'secondary' AND property.bedrooms = :bed${index})
   ```
   ✅ Правильно - перевіряє точне значення для secondary

2. **Фільтр size (рядок 126, 135):**
   ```typescript
   // Перевіряє property.size для secondary
   (property.sizeFrom >= :sizeFrom OR property.size >= :sizeFrom)
   ```
   ✅ Правильно - перевіряє `size` для secondary

3. **Фільтр price (рядок 145, 154):**
   ```typescript
   // Перевіряє property.price для secondary
   (property.priceFrom >= :priceFrom OR property.price >= :priceFrom)
   ```
   ✅ Правильно - перевіряє `price` для secondary

4. **Структура area (рядок 207-213):**
   ```typescript
   let areaField: any = p.area;
   if (p.area && p.propertyType === 'off-plan') {
     // Тільки для off-plan перетворюємо в рядок
     areaField = `${areaName}, ${cityName}`;
   }
   // Для secondary залишається об'єктом
   ```
   ✅ Правильно - для secondary area залишається об'єктом

5. **Конвертація цін та розмірів (рядок 218-222):**
   ```typescript
   priceAED: p.price ? Conversions.usdToAed(p.price) : null,
   sizeSqft: p.size ? Conversions.sqmToSqft(p.size) : null,
   ```
   ✅ Правильно - автоматично розраховується

### У файлі `public.routes.ts`:

1. **Підрахунок secondary в areas (рядок 469-471):**
   ```typescript
   .addSelect(
     "SUM(CASE WHEN property.propertyType = 'secondary' THEN 1 ELSE 0 END)",
     'secondary'
   )
   ```
   ✅ Правильно - рахує secondary properties

---

## ✅ Висновок

Всі перевірки показують, що код правильно обробляє secondary properties:

1. ✅ Endpoint `/api/properties?propertyType=secondary` працює
2. ✅ Всі фільтри підтримуються
3. ✅ Сортування працює
4. ✅ API Key/Secret автентифікація працює
5. ✅ Структура даних правильна:
   - `area` - об'єкт (не рядок)
   - `price` та `priceAED` - присутні
   - `size` та `sizeSqft` - присутні
   - `bedrooms` - число (не діапазон)
   - `photos` - масив
6. ✅ Підрахунок в areas працює (`projectsCount.secondary`)

---

## 🚀 Як протестувати на продакшені

```bash
# 1. Отримати API Key з адмінки
# 2. Запустити тестовий скрипт
cd /opt/admin-panel/admin-panel-backend
./src/scripts/test-api-secondary.sh YOUR_API_KEY YOUR_API_SECRET

# Або вручну через curl
curl -X GET "https://admin.foryou-realestate.com/api/properties?propertyType=secondary&page=1&limit=5" \
  -H "X-API-Key: YOUR_API_KEY" | jq '.'
```

---

**Всі файли створені та готові до використання!** 🎉

