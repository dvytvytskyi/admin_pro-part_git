# Мапінг all_properties.json → Database Schema

## Загальна інформація
- **Вхідний файл**: `all_properties.json`
- **Кількість properties**: 1473 (successful: 1459, failed: 14)
- **Тип properties**: Всі properties мають `status: "Presale"` → всі будуть `propertyType: "off-plan"`

## Визначення типу property
```typescript
propertyType = "off-plan" // Всі properties з файлу (status: "Presale")
```

## Мапінг полів Property Entity

### Базові поля

| JSON Path | DB Field | Тип | Обробка |
|-----------|----------|-----|---------|
| `details.name` або `basic_info.name` | `name` | `string` | Прямий мапінг (обов'язково) |
| `details.overview` | `description` | `text` | Прямий мапінг (може бути HTML/text, обов'язково). Якщо `overview` порожній або `null` - використати порожній рядок `""` |
| `details.coordinates` або `basic_info.coordinates` | `latitude`, `longitude` | `decimal` | Парсинг рядка "lat, lng" → `[lat, lng]` (обов'язково) |

### Photos (масив URL)
**Джерела фото (всі об'єднуються в один масив):**
- `details.cover_image_url` (JSON string → parse → `url`)
- `details.cover.url`
- `details.architecture[]` (масив об'єктів з `url`)
- `details.interior[]` (масив об'єктів з `url`)
- `details.lobby[]` (масив об'єктів з `url`)
- `details.buildings[][].Building_image[]` (масив об'єктів з `url`)
- `details.master_plan[]` (масив об'єктів з `url`)
- `details.facilities[].image.url` (фото facilities)

**Мапінг (всі фото в один масив):**
```typescript
const allPhotos: string[] = []

// Cover image
if (details.cover_image_url) {
  try {
    const coverImg = JSON.parse(details.cover_image_url)
    if (coverImg.url) allPhotos.push(coverImg.url)
  } catch {
    // Якщо не JSON, можливо це вже URL
    if (typeof details.cover_image_url === 'string' && details.cover_image_url.startsWith('http')) {
      allPhotos.push(details.cover_image_url)
    }
  }
}

// Cover object
if (details.cover?.url) allPhotos.push(details.cover.url)

// Architecture
if (details.architecture) {
  allPhotos.push(...details.architecture.map(img => img.url).filter(Boolean))
}

// Interior
if (details.interior) {
  allPhotos.push(...details.interior.map(img => img.url).filter(Boolean))
}

// Lobby
if (details.lobby) {
  allPhotos.push(...details.lobby.map(img => img.url).filter(Boolean))
}

// Buildings
if (details.buildings) {
  details.buildings.forEach(buildingGroup => {
    buildingGroup.forEach(building => {
      if (building.Building_image) {
        allPhotos.push(...building.Building_image.map(img => img.url).filter(Boolean))
      }
    })
  })
}

// Master plan
if (details.master_plan) {
  allPhotos.push(...details.master_plan.map(plan => plan.url).filter(Boolean))
}

// Facilities images (опціонально)
if (details.facilities) {
  details.facilities.forEach(facility => {
    if (facility.image?.url) {
      allPhotos.push(facility.image.url)
    }
  })
}

// Видалити дублікати та порожні значення
photos: string[] = [...new Set(allPhotos.filter(Boolean))]
```

### Локація (Country, City, Area)

| JSON Path | DB Field | Тип | Обробка |
|-----------|----------|-----|---------|
| `details.country` | `countryId` | `uuid` | Знайти/створити Country по назві |
| `details.city` | `cityId` | `uuid` | Знайти/створити City по назві (може бути `null` → створити "Dubai" як default) |
| `details.area` або `basic_info.area` | `areaId` | `uuid` | Знайти/створити Area по назві в межах City |

**Приклад:**
- `country: "United Arab Emirates"` → знайти Country з `nameEn = "United Arab Emirates"`
- `city: null` або `city: "Dubai"` → знайти/створити City "Dubai"
- `area: "Dubai Islands"` → знайти/створити Area "Dubai Islands" в місті "Dubai"

### Developer

| JSON Path | DB Field | Тип | Обробка |
|-----------|----------|-----|---------|
| `details.developer` або `basic_info.developer` | `developerId` | `uuid` (nullable) | Знайти/створити Developer по назві |
| `details.developer_data` | - | - | Використати для створення/оновлення Developer (name, logo, description) |

**Developer мапінг:**
```typescript
developer = {
  name: details.developer || basic_info.developer,
  logo: details.developer_data?.logo_image?.[0]?.url || null,
  description: details.developer_data?.description || null,
  images: [] // Можна додати додаткові фото з developer_data
}
```

### Off-Plan специфічні поля

| JSON Path | DB Field | Тип | Обробка |
|-----------|----------|-----|---------|
| `basic_info.min_price_aed` або `details.min_price_aed` | `priceFrom` | `decimal(15,2)` | Конвертувати AED → USD: `priceFrom = min_price_aed / 3.673` (1 USD = 3.673 AED) |
| `unit_blocks[]` (мінімум) | `bedroomsFrom` | `int` | Вирахувати мінімум з `unit_blocks` по `bedroom_type` |
| `unit_blocks[]` (максимум) | `bedroomsTo` | `int` | Вирахувати максимум з `unit_blocks` по `bedroom_type` |
| `details.min_area` / `details.max_area` або з `unit_blocks` | `sizeFrom`, `sizeTo` | `decimal(10,2)` | Конвертувати sqft → м²: `size = area_sqft / 10.764` (1 м² = 10.764 sqft). Якщо є `units_area_from_m2` / `units_area_to_m2` в unit_blocks - використати їх напряму |
| `details.payment_plans[]` | `paymentPlan` | `text` | Форматувати payment plans в текстовий формат |

**Bedrooms мапінг:**
```typescript
// З unit_blocks витягнути bedroom_type: "1 bedroom" → 1, "2 bedroom" → 2, тощо
bedroomsFrom = Math.min(...unit_blocks.map(block => extractBedrooms(block.name)))
bedroomsTo = Math.max(...unit_blocks.map(block => extractBedrooms(block.name)))
```

**Size мапінг:**
```typescript
// Якщо є min_area/max_area в sqft
sizeFrom = details.min_area ? (details.min_area / 10.764) : null // sqft → м²
sizeTo = details.max_area ? (details.max_area / 10.764) : null

// Або з unit_blocks
sizeFrom = Math.min(...unit_blocks.map(block => block.units_area_from_m2 ? parseFloat(block.units_area_from_m2) : null))
sizeTo = Math.max(...unit_blocks.map(block => block.units_area_to_m2 ? parseFloat(block.units_area_to_m2) : null))
```

**Bathrooms:**
- ⚠️ **В JSON немає поля bathrooms** - завжди залишати `null`
- **Рішення**: Залишити `bathroomsFrom` та `bathroomsTo` як `null` для всіх properties (не критично)

**Payment Plan мапінг:**
```typescript
paymentPlan = details.payment_plans
  .map(plan => {
    const payments = plan.Payments
      .map((paymentGroup, idx) => {
        const payment = paymentGroup[0]
        return `${payment.Payment_time}: ${payment.Percent_of_payment}%`
      })
      .join(', ')
    return `${plan.Plan_name}: ${payments}`
  })
  .join(' | ')
```

### Facilities

| JSON Path | DB Field | Тип | Обробка |
|-----------|----------|-----|---------|
| `details.facilities[].name` | `facilities` | `ManyToMany` | Знайти/створити Facility по `nameEn` |

**Facility мапінг:**
```typescript
// Для кожного facility з details.facilities[]
async function findOrCreateFacility(facilityName: string): Promise<Facility> {
  // 1. Шукати існуючий facility по nameEn
  let facility = await facilityRepository.findOne({
    where: { nameEn: facilityName }
  })
  
  // 2. Якщо не знайдено - створити новий
  if (!facility) {
    // Генерувати iconName з назви (наприклад: "Swimming Pool" → "swimming-pool")
    const iconName = facilityName
      .toLowerCase()
      .replace(/[^a-z0-9\s]/g, '') // Видалити спецсимволи
      .replace(/\s+/g, '-') // Замінити пробіли на дефіси
      .trim()
    
    facility = facilityRepository.create({
      nameEn: facilityName, // Англійська назва з JSON
      nameRu: facilityName, // Поки що та сама назва (можна перекласти пізніше)
      nameAr: facilityName, // Поки що та сама назва (можна перекласти пізніше)
      iconName: iconName || 'facility' // Генерується з назви
    })
    
    facility = await facilityRepository.save(facility)
  }
  
  return facility
}

// Застосувати до всіх facilities
const facilityIds: string[] = []
for (const facilityData of details.facilities || []) {
  const facility = await findOrCreateFacility(facilityData.name)
  facilityIds.push(facility.id)
}
```

**Приклад:**
- JSON: `{ "name": "Swimming Pool" }`
- БД: `{ nameEn: "Swimming Pool", nameRu: "Swimming Pool", nameAr: "Swimming Pool", iconName: "swimming-pool" }`

### PropertyUnit (Units)

| JSON Path | DB Field | Тип | Обробка |
|-----------|----------|-----|---------|
| `details.unit_blocks[]` | `units[]` | `OneToMany` | Створити PropertyUnit для кожного unit_block |
| `details.unit_availability[]` | `units[]` (доповнення) | `OneToMany` | Використати для детальнішої інформації про units (якщо unit_blocks недостатньо) |

**Unit мапінг (пріоритет unit_blocks):**
```typescript
// Спочатку створюємо units з unit_blocks
units = details.unit_blocks?.map(block => {
  return {
    unitId: String(block.id), // ID з unit_blocks
    type: mapUnitType(block.unit_type || block.normalized_type), // "Apartments" → "apartment"
    planImage: parseImageUrl(block.typical_unit_image_url), // JSON string → url
    totalSize: block.units_area_from_m2 ? parseFloat(block.units_area_from_m2) : (block.units_area_to_m2 ? parseFloat(block.units_area_to_m2) : 0),
    balconySize: null, // Якщо не вказано
    price: block.units_price_from_aed ? (block.units_price_from_aed / 3.673) : (block.units_price_from ? (block.units_price_from / 3.673) : 0) // AED → USD
  }
}) || []

// Якщо unit_blocks порожній або відсутній, але є unit_availability, створити units з unit_availability
if (units.length === 0 && details.unit_availability?.length > 0) {
  units = details.unit_availability.flatMap(building => 
    building.units.map(unit => ({
      unitId: `${building.building_name}-${unit.bedroom_type}-${unit.price_from}`, // Генеруємо унікальний ID
      type: "apartment", // За замовчуванням
      planImage: null,
      totalSize: unit.area_from ? (unit.area_from / 10.764) : 0, // sqft → м²
      balconySize: null,
      price: unit.price_from_aed ? (unit.price_from_aed / 3.673) : (unit.price_from ? (unit.price_from / 3.673) : 0) // AED → USD
    }))
  )
}
```

**Unit Type мапінг:**
```typescript
function mapUnitType(unitType: string): UnitType {
  const mapping = {
    "Apartments": "apartment",
    "Villas": "villa",
    "Townhouses": "townhouse",
    "Penthouses": "penthouse",
    "Offices": "office"
  }
  return mapping[unitType.toLowerCase()] || "apartment"
}
```

## Обробка помилок та валідація

### Обов'язкові поля
- ✅ `name` - обов'язково
- ✅ `description` - обов'язково (може бути з `overview`)
- ✅ `countryId` - обов'язково (створити "United Arab Emirates" якщо немає)
- ✅ `cityId` - обов'язково (створити "Dubai" якщо `city: null`)
- ✅ `areaId` - обов'язково (створити Area якщо немає)
- ✅ `latitude`, `longitude` - обов'язково (парсити з `coordinates`)
- ✅ `priceFrom` - обов'язково для off-plan (використати `min_price_aed / 3.673`)

### Опціональні поля
- `developerId` - може бути `null`
- `bedroomsFrom/To` - може бути `null` (якщо не вдалося визначити)
- `bathroomsFrom/To` - може бути `null`
- `sizeFrom/To` - може бути `null`
- `paymentPlan` - може бути `null`
- `photos` - може бути порожнім масивом `[]`
- `units` - може бути порожнім масивом `[]`
- `facilities` - може бути порожнім масивом `[]`

### Валідація координат
```typescript
// coordinates: "25.3003885134916, 55.315399696017174"
const [lat, lng] = coordinates.split(',').map(coord => parseFloat(coord.trim()))
if (isNaN(lat) || isNaN(lng)) {
  // Пропустити property або використати дефолтні координати для Dubai
  lat = 25.2048
  lng = 55.2708
}
```

### Обробка фото
- Всі фото об'єднуються в один масив `photos` (не розділяються на категорії)
- Якщо `cover_image_url` - це JSON string, потрібно парсити: `JSON.parse(cover_image_url).url`
- Видалити дублікати URL перед збереженням
- Якщо фото не знайдено, створити порожній масив `[]`

## Приклад мапінгу одного property

### Вхідні дані (JSON):
```json
{
  "basic_info": {
    "area": "Dubai Islands",
    "coordinates": "25.3003885134916, 55.315399696017174",
    "developer": "Wellington Developments",
    "min_price_aed": 2212824.0,
    "name": "Wellington Ocean Walk",
    "status": "Presale"
  },
  "details": {
    "area": "Dubai Islands",
    "city": null,
    "country": "United Arab Emirates",
    "cover_image_url": "{\"url\": \"https://api.reelly.io/vault/.../0.jpg\"}",
    "developer": "Wellington Developments",
    "developer_data": {
      "name": "Wellington Developments",
      "logo_image": [{"url": "https://..."}],
      "description": "Wellington Developments is a forward-thinking..."
    },
    "facilities": [
      {"name": "Swimming Pool"},
      {"name": "Gym"}
    ],
    "min_price_aed": 2212824.0,
    "name": "Wellington Ocean Walk",
    "overview": "Wellington Ocean Walk is a stunning waterfront project...",
    "payment_plans": [
      {
        "Plan_name": "45 Months Post Handover Paymen Plan",
        "Payments": [
          [{"Order": 1, "Payment_time": "On booking", "Percent_of_payment": "10"}],
          [{"Order": 2, "Payment_time": "During construction", "Percent_of_payment": "40"}]
        ]
      }
    ],
    "unit_blocks": [
      {
        "id": 7562,
        "name": "1 bedroom Apartments - Wellington Ocean Walk",
        "unit_type": "Apartments",
        "units_area_from_m2": "83.738317757009",
        "units_price_from_aed": 2212824,
        "typical_unit_image_url": "[{\"url\": \"https://...\"}]"
      },
      {
        "id": 7563,
        "name": "2 bedroom Apartments - Wellington Ocean Walk",
        "unit_type": "Apartments",
        "units_area_from_m2": "136.44859813084",
        "units_price_from_aed": 3378977
      }
    ]
  }
}
```

### Вихідні дані (Property Entity):
```typescript
{
  propertyType: "off-plan",
  name: "Wellington Ocean Walk",
  description: "Wellington Ocean Walk is a stunning waterfront project...",
  photos: ["https://api.reelly.io/vault/.../0.jpg"],
  countryId: "uuid-of-uae",
  cityId: "uuid-of-dubai",
  areaId: "uuid-of-dubai-islands",
  latitude: 25.3003885134916,
  longitude: 55.315399696017174,
  developerId: "uuid-of-wellington-developments",
  priceFrom: 602482.38, // 2212824 / 3.673 (AED → USD)
  bedroomsFrom: 1, // з unit_blocks
  bedroomsTo: 2, // з unit_blocks
  bathroomsFrom: null,
  bathroomsTo: null,
  sizeFrom: 83.74, // з unit_blocks (м²)
  sizeTo: 136.45, // з unit_blocks (м²)
  paymentPlan: "45 Months Post Handover Paymen Plan: On booking: 10%, During construction: 40%",
  facilities: [
    { id: "uuid-of-swimming-pool" },
    { id: "uuid-of-gym" }
  ],
  units: [
    {
      unitId: "7562",
      type: "apartment",
      planImage: "https://...",
      totalSize: 83.74,
      balconySize: null,
      price: 602482.38 // 2212824 / 3.673
    },
    {
      unitId: "7563",
      type: "apartment",
      planImage: null,
      totalSize: 136.45,
      balconySize: null,
      price: 920066.16 // 3378977 / 3.673
    }
  ]
}
```

## Алгоритм імпорту

### Крок 1: Очистити БД
```sql
-- Видалити всі properties (cascade видалить units та зв'язки з facilities)
DELETE FROM properties;
```
**⚠️ УВАГА**: Це видалить ВСІ properties (off-plan та secondary) з бази даних!

### Крок 2: Прочитати JSON
- Завантажити `all_properties.json`
- Перевірити структуру: `total_properties: 1473`, `successful: 1459`, `failed: 14`
- Обробляти тільки `successful` properties

### Крок 3: Для кожного property
1. **Знайти/створити Country**:
   - Шукати по `nameEn` = `details.country`
   - Якщо не знайдено → створити новий Country

2. **Знайти/створити City**:
   - Якщо `details.city` = `null` → використати "Dubai" як default
   - Шукати по `nameEn` = city name в межах Country
   - Якщо не знайдено → створити новий City

3. **Знайти/створити Area**:
   - Шукати по `nameEn` = `details.area` або `basic_info.area` в межах City
   - Якщо не знайдено → створити новий Area

4. **Знайти/створити Developer** (якщо є):
   - Шукати по `name` = `details.developer`
   - Якщо не знайдено → створити новий Developer з даними з `developer_data`

5. **Знайти/створити Facilities**:
   - Для кожного `details.facilities[]` знайти/створити Facility по `name`
   - Зберегти масив Facility IDs для зв'язку

6. **Створити Property**:
   - Мапити всі поля згідно з таблицею вище
   - Обробити координати, фото, ціни, розміри

7. **Створити PropertyUnit**:
   - Для кожного `unit_block` створити PropertyUnit
   - Зв'язати з Property через `propertyId`

8. **Зв'язати Facilities з Property**:
   - Використати ManyToMany зв'язок через JoinTable

### Крок 4: Зберегти в БД
- Використати транзакції для забезпечення цілісності даних
- Batch insert для оптимізації (по 100 properties за раз)
- Обробляти помилки та логувати їх

### Крок 5: Прогрес
- Показувати прогрес-бар під час імпорту
- Виводити статистику: скільки properties оброблено, скільки помилок

## Валідація після імпорту

- Перевірити кількість properties: має бути 1459 (successful)
- Перевірити наявність обов'язкових полів
- Перевірити зв'язки (country, city, area, developer)
- Перевірити units (мають бути створені для кожного property з unit_blocks)
- Перевірити facilities (мають бути зв'язані)

## Поля, які не використовуються (не критичні)

Наступні поля є в JSON, але не мають відповідних полів в Property entity, тому ігноруються:
- `completion_datetime` - дата завершення проекту
- `brochure_url` - URL брошури
- `video_url` - URL відео
- `website` - веб-сайт проекту
- `service_charge` - плата за обслуговування
- `readiness` - готовність проекту (%)
- `furnishing` - меблювання
- `has_escrow` - наявність ескроу
- `post_handover` - після здачі
- `is_partner_project` - партнерський проект
- `map_points` - точки на карті (POI)
- `parkings` - інформація про паркування
- `layouts_pdf` - PDF з планами
- `deposit_description` - опис депозиту
- `slug` - URL slug (генерується автоматично)
- `sale_status` - статус продажу (використовується тільки для визначення типу property)

**Примітка**: Ці поля можна додати в майбутньому, якщо знадобиться.

## Нотатки

1. **Координати**: Завжди перевіряти формат `coordinates` (може бути рядок "lat, lng")
2. **Фото**: Всі фото об'єднуються в один масив (не розділяються на категорії), видаляються дублікати
3. **Розміри**: 
   - Якщо є `units_area_from_m2` / `units_area_to_m2` в unit_blocks - використати їх напряму (вже в м²)
   - Якщо є `min_area` / `max_area` - конвертувати з sqft в м²: `size = area_sqft / 10.764` (1 м² = 10.764 sqft)
4. **Ціни**: Всі ціни в JSON в AED, конвертувати в USD: `price = price_aed / 3.673` (1 USD = 3.673 AED)
5. **Payment Plans**: Може бути кілька payment plans, об'єднати їх в один текстовий рядок
6. **Units**: Якщо є `unit_availability`, можна використати для створення більш детальних units (якщо `unit_blocks` порожній)
7. **Bathrooms**: Завжди `null` (в JSON немає поля)
8. **Конвертація**: 
   - ✅ AED → USD: `price_usd = price_aed / 3.673`
   - ✅ sqft → м²: `size_m2 = size_sqft / 10.764`
   - ✅ Якщо вже є значення в м² (`units_area_from_m2`) - використати напряму

