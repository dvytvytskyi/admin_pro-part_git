# API Ендпоінти для Properties (Проектів)

## 1. GET /api/properties

**Призначення:** Основний ендпоінт для отримання properties з фільтрацією та пагінацією  
**Аутентифікація:** JWT або API Key/Secret  
**Використання:** Адмін панель (фронтенд)

### Query Parameters:

- `propertyType` (string, optional): `"off-plan"` | `"secondary"`
- `developerId` (string, optional): UUID developer
- `cityId` (string, optional): UUID city
- `areaId` (string, optional): UUID area
- `bedrooms` (string, optional): Кількість спалень (можна кілька через кому: "1,2,3")
- `sizeFrom` (number, optional): Мінімальний розмір (м²)
- `sizeTo` (number, optional): Максимальний розмір (м²)
- `priceFrom` (number, optional): Мінімальна ціна (USD)
- `priceTo` (number, optional): Максимальна ціна (USD)
- `search` (string, optional): Пошук по name та description
- `sortBy` (string, optional): Поле для сортування (`createdAt`, `name`, `price`, `priceFrom`, `size`, `sizeFrom`)
- `sortOrder` (string, optional): `"ASC"` | `"DESC"` (за замовчуванням: `"DESC"`)
- `page` (number, optional): Номер сторінки (за замовчуванням: `1`)
- `limit` (number, optional): Кількість на сторінці (за замовчуванням: `20`, максимум: `100`)

### Формат відповіді:

```json
{
  "success": true,
  "message": "Success",
  "data": {
    "data": [
      {
        "id": "uuid",
        "propertyType": "off-plan" | "secondary",
        "name": "string",
        "description": "string",
        "photos": ["string"],
        "country": {
          "id": "uuid",
          "nameEn": "string",
          "nameRu": "string",
          "nameAr": "string",
          "code": "string"
        },
        "city": {
          "id": "uuid",
          "nameEn": "string",
          "nameRu": "string",
          "nameAr": "string"
        },
        "area": "string" | object,
        // Для off-plan: area = "areaName, cityName" (наприклад "JVC, Dubai")
        // Для secondary: area = { id, nameEn, nameRu, nameAr }
        "developer": {
          "id": "uuid",
          "name": "string",
          "logo": "string" | null,
          "description": "string" | null,
          "images": ["string"] | null
        } | null,
        "latitude": "number",
        "longitude": "number",
        "facilities": [
          {
            "id": "uuid",
            "nameEn": "string",
            "nameRu": "string",
            "nameAr": "string",
            "iconName": "string"
          }
        ],
        "units": [
          {
            "id": "uuid",
            "unitId": "string",
            "type": "apartment" | "villa" | "penthouse" | "townhouse" | "office",
            "price": "number",
            "priceAED": "number" | null,
            "totalSize": "number",
            "totalSizeSqft": "number" | null,
            "balconySize": "number" | null,
            "balconySizeSqft": "number" | null,
            "planImage": "string" | null
          }
        ],
        
        // Off-Plan fields
        "priceFrom": "number" | null,
        "priceFromAED": "number" | null,
        "bedroomsFrom": "number" | null,
        "bedroomsTo": "number" | null,
        "bathroomsFrom": "number" | null,
        "bathroomsTo": "number" | null,
        "sizeFrom": "number" | null,
        "sizeFromSqft": "number" | null,
        "sizeTo": "number" | null,
        "sizeToSqft": "number" | null,
        "paymentPlan": "string" | null,
        
        // Secondary fields
        "price": "number" | null,
        "priceAED": "number" | null,
        "bedrooms": "number" | null,
        "bathrooms": "number" | null,
        "size": "number" | null,
        "sizeSqft": "number" | null,
        
        "createdAt": "ISO date",
        "updatedAt": "ISO date"
      }
    ],
    "pagination": {
      "total": "number",        // Загальна кількість properties (з урахуванням фільтрів)
      "page": "number",          // Поточна сторінка
      "limit": "number",         // Кількість на сторінці
      "totalPages": "number"     // Загальна кількість сторінок
    }
  }
}
```

### Приклад запиту:

```
GET /api/properties?propertyType=off-plan&page=1&limit=100&sortBy=createdAt&sortOrder=DESC
```

### Важливі деталі:

1. **Area поле:**
   - Для **off-plan**: `area` = `"areaName, cityName"` (наприклад `"JVC, Dubai"`)
   - Для **secondary**: `area` = об'єкт `{ id, nameEn, nameRu, nameAr }`

2. **Конвертація валют/одиниць:**
   - `priceFromAED` = `priceFrom * 3.673` (USD → AED)
   - `sizeFromSqft` = `sizeFrom * 10.764` (м² → sqft)
   - `sizeToSqft` = `sizeTo * 10.764` (м² → sqft)

3. **Пагінація:**
   - `total` - загальна кількість properties з урахуванням фільтрів
   - `totalPages` - розраховується як `Math.ceil(total / limit)`

---

## 2. GET /api/public/data

**Призначення:** Публічний ендпоінт для отримання ВСІХ properties без пагінації  
**Аутентифікація:** API Key/Secret  
**Використання:** Публічний сайт (frontend)

### Headers:

- `x-api-key`: API Key
- `x-api-secret`: API Secret

### Формат відповіді:

```json
{
  "success": true,
  "message": "Success",
  "data": {
    "properties": [
      {
        "id": "uuid",
        "propertyType": "off-plan" | "secondary",
        "name": "string",
        "description": "string",
        "photos": ["string"],
        "country": {
          "id": "uuid",
          "nameEn": "string",
          "nameRu": "string",
          "nameAr": "string",
          "code": "string"
        } | null,
        "city": {
          "id": "uuid",
          "nameEn": "string",
          "nameRu": "string",
          "nameAr": "string"
        } | null,
        "area": "string" | object,
        // Для off-plan: area = "areaName, cityName"
        // Для secondary: area = { id, nameEn, nameRu, nameAr }
        "developer": {
          "id": "uuid",
          "name": "string"
        } | null,
        "latitude": "number",
        "longitude": "number",
        "facilities": [
          {
            "id": "uuid",
            "nameEn": "string",
            "nameRu": "string",
            "nameAr": "string",
            "iconName": "string"
          }
        ],
        "units": [
          {
            "id": "uuid",
            "unitId": "string",
            "type": "apartment" | "villa" | "penthouse" | "townhouse" | "office",
            "price": "number",
            "priceAED": "number" | null,
            "totalSize": "number",
            "totalSizeSqft": "number" | null,
            "balconySize": "number" | null,
            "balconySizeSqft": "number" | null,
            "planImage": "string" | null
          }
        ],
        
        // Off-Plan fields
        "priceFrom": "number" | null,
        "priceFromAED": "number" | null,
        "bedroomsFrom": "number" | null,
        "bedroomsTo": "number" | null,
        "bathroomsFrom": "number" | null,
        "bathroomsTo": "number" | null,
        "sizeFrom": "number" | null,
        "sizeFromSqft": "number" | null,
        "sizeTo": "number" | null,
        "sizeToSqft": "number" | null,
        "paymentPlan": "string" | null,
        
        // Secondary fields
        "price": "number" | null,
        "priceAED": "number" | null,
        "bedrooms": "number" | null,
        "bathrooms": "number" | null,
        "size": "number" | null,
        "sizeSqft": "number" | null,
        
        "createdAt": "ISO date",
        "updatedAt": "ISO date"
      }
    ],
    "countries": [...],
    "cities": [...],
    "areas": [...],
    "developers": [...],
    "facilities": [...],
    "courses": [...]
  }
}
```

### Важливі деталі:

1. **Повертає ВСІ properties** без пагінації (може бути багато даних)
2. **Area поле:** Таке саме, як в `/api/properties` (рядок для off-plan, об'єкт для secondary)
3. **Конвертація:** Такі самі конвертації (AED, sqft)
4. **Додатково:** Повертає також countries, cities, areas, developers, facilities, courses

---

## 3. GET /api/properties/:id

**Призначення:** Отримання деталей одного property  
**Аутентифікація:** JWT або API Key/Secret

### Формат відповіді:

```json
{
  "success": true,
  "message": "Success",
  "data": {
    // Повна інформація про property (така сама структура, як в масиві)
  }
}
```

---

## 4. GET /api/properties/stats

**Призначення:** Статистика по properties  
**Аутентифікація:** JWT або API Key/Secret

### Формат відповіді:

```json
{
  "success": true,
  "message": "Success",
  "data": {
    "totalProperties": "number",
    "offPlanProperties": "number",
    "secondaryProperties": "number",
    "minPrice": "number",
    "maxPrice": "number",
    "topCities": [
      {
        "name": "string",
        "count": "number"
      }
    ],
    "bedroomsDistribution": [
      {
        "name": "string",
        "count": "number"
      }
    ],
    "unitTypesDistribution": [
      {
        "name": "string",
        "count": "number"
      }
    ]
  }
}
```

---

## Порівняння ендпоінтів:

| Ендпоінт | Пагінація | Фільтри | Використання |
|----------|-----------|---------|--------------|
| `/api/properties` | ✅ Так | ✅ Так | Адмін панель |
| `/api/public/data` | ❌ Ні | ❌ Ні | Публічний сайт |
| `/api/properties/:id` | ❌ Ні | ❌ Ні | Деталі property |
| `/api/properties/stats` | ❌ Ні | ❌ Ні | Статистика |

---

## Конвертація валют/одиниць:

### Валюта:
- **USD → AED:** `priceAED = price * 3.673`
- **AED → USD:** `priceUSD = priceAED / 3.673`

### Одиниці площі:
- **м² → sqft:** `sizeSqft = size * 10.764`
- **sqft → м²:** `sizeM2 = sizeSqft / 10.764`

---

## Формат Area поля:

### Off-Plan Properties:
```json
{
  "area": "JVC, Dubai"  // Рядок: "areaName, cityName"
}
```

### Secondary Properties:
```json
{
  "area": {
    "id": "uuid",
    "nameEn": "JVC",
    "nameRu": "ДЖВК",
    "nameAr": "جيه في سي"
  }
}
```

---

## Приклади використання:

### 1. Отримати всі off-plan properties (з пагінацією):
```
GET /api/properties?propertyType=off-plan&page=1&limit=100
```

### 2. Отримати off-plan properties з фільтрами:
```
GET /api/properties?propertyType=off-plan&bedrooms=2&priceFrom=100000&priceTo=500000&page=1&limit=50
```

### 3. Отримати всі properties (публічний API):
```
GET /api/public/data
Headers:
  x-api-key: YOUR_API_KEY
  x-api-secret: YOUR_API_SECRET
```

### 4. Отримати деталі property:
```
GET /api/properties/{property-id}
```

---

## Нотатки:

1. **Пагінація:** Завжди використовуйте `page` та `limit` для `/api/properties`, щоб уникнути навантаження
2. **Фільтри:** Комбінуйте фільтри для точного пошуку
3. **Сортування:** Використовуйте `sortBy` та `sortOrder` для сортування результатів
4. **Конвертація:** Всі конвертації (AED, sqft) виконуються автоматично на бекенді
5. **Area поле:** Формат залежить від типу property (off-plan = рядок, secondary = об'єкт)

