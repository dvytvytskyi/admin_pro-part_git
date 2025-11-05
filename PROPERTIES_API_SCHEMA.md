# 🏠 Properties API Schema - Повна документація

## 📋 Зміст

1. [Фільтри](#фільтри)
2. [Сортування](#сортування)
3. [Пошук](#пошук)
4. [Інформація карток (список проектів)](#інформація-карток-список-проектів)
5. [Фото](#фото)
6. [Деталі конкретного проекту](#деталі-конкретного-проекту)
7. [Прийом заявки зі сторінки проекту](#прийом-заявки-зі-сторінки-проекту)

---

## Фільтри

### Endpoint: `GET /api/properties`

**Authentication:** JWT Token або API Key

### Query Parameters для фільтрації:

| Параметр | Тип | Опис | Приклад |
|----------|-----|------|---------|
| `propertyType` | string | Тип нерухомості: `off-plan` або `secondary` | `?propertyType=off-plan` |
| `developerId` | string (UUID) | ID девелопера | `?developerId=123e4567-e89b-12d3-a456-426614174000` |
| `cityId` | string (UUID) | ID міста | `?cityId=123e4567-e89b-12d3-a456-426614174000` |
| `areaId` | string (UUID) | ID району | `?areaId=123e4567-e89b-12d3-a456-426614174000` |
| `bedrooms` | string/int | Кількість спалень (multiselect - можна передати кілька через кому) | `?bedrooms=1,2,3` або `?bedrooms=2` |
| `sizeFrom` | number | Мінімальний розмір (м²) | `?sizeFrom=50` |
| `sizeTo` | number | Максимальний розмір (м²) | `?sizeTo=200` |
| `priceFrom` | number | Мінімальна ціна (USD) | `?priceFrom=100000` |
| `priceTo` | number | Максимальна ціна (USD) | `?priceTo=500000` |
| `search` | string | Текстовий пошук по назві та опису | `?search=dubai` |

### Приклад запиту з фільтрами:

```http
GET /api/properties?propertyType=off-plan&cityId=123e4567-e89b-12d3-a456-426614174000&bedrooms=2,3&priceFrom=200000&priceTo=500000&search=dubai
```

### Логіка фільтрів:

- **`bedrooms`** (multiselect):
  - Для `off-plan`: перевіряє чи `bedroomsFrom <= bedrooms <= bedroomsTo`
  - Для `secondary`: перевіряє чи `bedrooms = bedrooms`
  - Можна передати кілька значень через кому: `?bedrooms=1,2,3`

- **`sizeFrom/sizeTo`**:
  - Перевіряє `sizeFrom` або `size` (для secondary)

- **`priceFrom/priceTo`**:
  - Перевіряє `priceFrom` (для off-plan) або `price` (для secondary)

- **`search`**:
  - Пошук по `name` та `description` (case-insensitive, LIKE)

---

## Сортування

### Query Parameters для сортування:

| Параметр | Тип | Опис | Можливі значення |
|----------|-----|------|------------------|
| `sortBy` | string | Поле для сортування | `createdAt`, `name`, `price`, `priceFrom`, `size`, `sizeFrom` |
| `sortOrder` | string | Напрямок сортування | `ASC` або `DESC` (default: `DESC`) |

### Приклад сортування:

```http
# Сортування по ціні (від найдешевших до найдорожчих)
GET /api/properties?sortBy=priceFrom&sortOrder=ASC

# Сортування по назві (A-Z)
GET /api/properties?sortBy=name&sortOrder=ASC

# Сортування по даті створення (нові спочатку) - default
GET /api/properties?sortBy=createdAt&sortOrder=DESC
```

### Default сортування:
- Якщо `sortBy` не вказано або недійсне → `sortBy=createdAt`, `sortOrder=DESC`

---

## Пошук

### Query Parameter:

| Параметр | Тип | Опис |
|----------|-----|------|
| `search` | string | Пошук по назві та опису проекту |

### Приклад:

```http
GET /api/properties?search=dubai%20marina
```

### Логіка:
- Пошук по полях: `name` та `description`
- Case-insensitive (незалежно від регістру)
- Використовує SQL LIKE оператор з `%search%`

---

## Інформація карток (список проектів)

### Endpoint: `GET /api/properties`

**Response структура для картки проекту:**

```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "propertyType": "off-plan" | "secondary",
      "name": "Project Name",
      "description": "Project description",
      "photos": [
        "https://cloudinary.com/image1.jpg",
        "https://cloudinary.com/image2.jpg"
      ],
      "country": {
        "id": "uuid",
        "nameEn": "United Arab Emirates",
        "nameRu": "ОАЭ",
        "nameAr": "الإمارات العربية المتحدة",
        "code": "AE"
      },
      "city": {
        "id": "uuid",
        "nameEn": "Dubai",
        "nameRu": "Дубай",
        "nameAr": "دبي"
      },
      "area": {
        "id": "uuid",
        "nameEn": "Dubai Marina",
        "nameRu": "Дубай Марина",
        "nameAr": "دبي مارينا"
      },
      "developer": {
        "id": "uuid",
        "name": "Emaar Properties",
        "logo": "https://...",
        "description": "Developer description"
      },
      "latitude": 25.0772,
      "longitude": 55.1394,
      
      // Off-Plan fields
      "priceFrom": 200000,
      "priceFromAED": 734000,
      "bedroomsFrom": 1,
      "bedroomsTo": 3,
      "bathroomsFrom": 1,
      "bathroomsTo": 2,
      "sizeFrom": 50,
      "sizeFromSqft": 538.2,
      "sizeTo": 150,
      "sizeToSqft": 1614.6,
      "paymentPlan": "10% down payment, 90% on completion",
      "units": [
        {
          "id": "uuid",
          "unitId": "A-101",
          "type": "apartment",
          "price": 200000,
          "priceAED": 734000,
          "totalSize": 50,
          "totalSizeSqft": 538.2,
          "balconySize": 5,
          "balconySizeSqft": 53.8,
          "planImage": "https://..."
        }
      ],
      
      // Secondary fields
      "price": 500000,
      "priceAED": 1835000,
      "bedrooms": 2,
      "bathrooms": 2,
      "size": 100,
      "sizeSqft": 1076.4,
      
      // Common fields
      "facilities": [
        {
          "id": "uuid",
          "nameEn": "Swimming Pool",
          "nameRu": "Бассейн",
          "nameAr": "مسبح",
          "iconName": "pool"
        }
      ],
      "createdAt": "2025-11-05T12:00:00Z",
      "updatedAt": "2025-11-05T12:00:00Z"
    }
  ]
}
```

### Важливі поля для картки:

1. **Основна інформація:**
   - `id` - для переходу на детальну сторінку
   - `name` - назва проекту
   - `photos[0]` - перше фото (для картки)
   - `propertyType` - тип нерухомості

2. **Локація:**
   - `country.nameEn/Ru/Ar` - країна
   - `city.nameEn/Ru/Ar` - місто
   - `area.nameEn/Ru/Ar` - район

3. **Ціна:**
   - Для `off-plan`: `priceFrom` та `priceFromAED`
   - Для `secondary`: `price` та `priceAED`

4. **Розмір:**
   - Для `off-plan`: `sizeFrom` - `sizeTo` (м²) та `sizeFromSqft` - `sizeToSqft` (sqft)
   - Для `secondary`: `size` (м²) та `sizeSqft` (sqft)

5. **Спальні:**
   - Для `off-plan`: `bedroomsFrom` - `bedroomsTo`
   - Для `secondary`: `bedrooms`

6. **Девелопер:**
   - `developer.name` - назва девелопера
   - `developer.logo` - логотип девелопера

---

## Фото

### Структура фото:

```json
{
  "photos": [
    "https://res.cloudinary.com/cloud/image1.jpg",
    "https://res.cloudinary.com/cloud/image2.jpg",
    "https://res.cloudinary.com/cloud/image3.jpg"
  ]
}
```

### Завантаження фото:

**Endpoint:** `POST /api/upload/images`

**Authentication:** JWT Token або API Key

**Request:**
- `Content-Type: multipart/form-data`
- Field name: `files` (multiple files allowed)

**Response:**
```json
{
  "success": true,
  "data": {
    "urls": [
      "https://res.cloudinary.com/cloud/image1.jpg",
      "https://res.cloudinary.com/cloud/image2.jpg"
    ]
  }
}
```

### Приклад завантаження (JavaScript):

```javascript
const formData = new FormData();
files.forEach(file => {
  formData.append('files', file);
});

const response = await fetch('/api/upload/images', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${token}`,
    // НЕ вказувати Content-Type - браузер додасть автоматично з boundary
  },
  body: formData
});

const data = await response.json();
const photoUrls = data.data.urls;
```

### Використання фото в картці:

- `photos[0]` - перше фото (головне фото для картки)
- `photos` - масив всіх фото (для галереї на детальній сторінці)

---

## Деталі конкретного проекту

### Endpoint: `GET /api/properties/:id`

**Authentication:** JWT Token або API Key

**Response:** Повна інформація про проект (аналогічно до списку, але один об'єкт)

```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "propertyType": "off-plan",
    "name": "Dubai Marina Towers",
    "description": "Full description of the project...",
    "photos": [
      "https://cloudinary.com/image1.jpg",
      "https://cloudinary.com/image2.jpg",
      "https://cloudinary.com/image3.jpg"
    ],
    "country": {
      "id": "uuid",
      "nameEn": "United Arab Emirates",
      "nameRu": "ОАЭ",
      "nameAr": "الإمارات العربية المتحدة",
      "code": "AE"
    },
    "city": {
      "id": "uuid",
      "nameEn": "Dubai",
      "nameRu": "Дубай",
      "nameAr": "دبي"
    },
    "area": {
      "id": "uuid",
      "nameEn": "Dubai Marina",
      "nameRu": "Дубай Марина",
      "nameAr": "دبي مارينا",
      "description": {
        "title": "About Dubai Marina",
        "description": "Area description..."
      },
      "infrastructure": {
        "title": "Infrastructure",
        "description": "Infrastructure description..."
      },
      "images": [
        "https://cloudinary.com/area-image1.jpg"
      ]
    },
    "developer": {
      "id": "uuid",
      "name": "Emaar Properties",
      "logo": "https://cloudinary.com/emaar-logo.png",
      "description": "Leading developer in Dubai...",
      "images": [
        "https://cloudinary.com/developer-image1.jpg"
      ]
    },
    "latitude": 25.0772,
    "longitude": 55.1394,
    
    // Off-Plan fields
    "priceFrom": 200000,
    "priceFromAED": 734000,
    "bedroomsFrom": 1,
    "bedroomsTo": 3,
    "bathroomsFrom": 1,
    "bathroomsTo": 2,
    "sizeFrom": 50,
    "sizeFromSqft": 538.2,
    "sizeTo": 150,
    "sizeToSqft": 1614.6,
    "paymentPlan": "10% down payment, 90% on completion",
    "units": [
      {
        "id": "uuid",
        "unitId": "A-101",
        "type": "apartment",
        "price": 200000,
        "priceAED": 734000,
        "totalSize": 50,
        "totalSizeSqft": 538.2,
        "balconySize": 5,
        "balconySizeSqft": 53.8,
        "planImage": "https://cloudinary.com/plan-a101.jpg"
      },
      {
        "id": "uuid",
        "unitId": "A-102",
        "type": "apartment",
        "price": 220000,
        "priceAED": 807400,
        "totalSize": 55,
        "totalSizeSqft": 592.0,
        "balconySize": 6,
        "balconySizeSqft": 64.6,
        "planImage": "https://cloudinary.com/plan-a102.jpg"
      }
    ],
    
    // Secondary fields (якщо propertyType = 'secondary')
    "price": null,
    "priceAED": null,
    "bedrooms": null,
    "bathrooms": null,
    "size": null,
    "sizeSqft": null,
    
    "facilities": [
      {
        "id": "uuid",
        "nameEn": "Swimming Pool",
        "nameRu": "Бассейн",
        "nameAr": "مسبح",
        "iconName": "pool"
      },
      {
        "id": "uuid",
        "nameEn": "Gym",
        "nameRu": "Спортзал",
        "nameAr": "صالة رياضية",
        "iconName": "gym"
      }
    ],
    "createdAt": "2025-11-05T12:00:00Z",
    "updatedAt": "2025-11-05T12:00:00Z"
  }
}
```

### Відмінності від картки:

1. **Повний опис** - `description` (може бути довгим)
2. **Всі фото** - `photos[]` (для галереї)
3. **Всі юніти** - `units[]` (якщо off-plan)
4. **Координати** - `latitude`, `longitude` (для карти)
5. **Детальна інформація про район** - `area.description`, `area.infrastructure`, `area.images`
6. **Детальна інформація про девелопера** - `developer.description`, `developer.images`

---

## Прийом заявки зі сторінки проекту

### Endpoint 1: `POST /api/investments/public` (для не зареєстрованих користувачів)

**Authentication:** Не потрібна (публічний endpoint)

### Endpoint 2: `POST /api/investments` (для зареєстрованих користувачів)

**Authentication:** JWT Token

**Request Body:**

```json
{
  "propertyId": "uuid",
  "amount": 200000,
  "date": "2025-11-10T00:00:00Z",
  "notes": "Interested in unit A-101",
  "userEmail": "user@example.com",
  "userPhone": "+971501234567",
  "userFirstName": "John",
  "userLastName": "Doe"
}
```

**Поля:**

| Поле | Тип | Обов'язкове | Опис |
|------|-----|-------------|------|
| `propertyId` | string (UUID) | ✅ | ID проекту |
| `amount` | number | ✅ | Сума інвестиції (USD) |
| `date` | string (ISO date) | ✅ | Дата інвестиції |
| `notes` | string | ❌ | Додаткові нотатки |
| `userEmail` | string | ❌* | Email користувача (якщо не зареєстрований) |
| `userPhone` | string | ❌* | Телефон користувача (якщо не зареєстрований) |
| `userFirstName` | string | ❌* | Ім'я користувача (якщо не зареєстрований) |
| `userLastName` | string | ❌* | Прізвище користувача (якщо не зареєстрований) |

*Обов'язкові, якщо користувач не зареєстрований (немає JWT token)

**Response:**

```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "userId": "uuid",
    "propertyId": "uuid",
    "amount": 200000,
    "status": "pending",
    "date": "2025-11-10T00:00:00Z",
    "notes": "Interested in unit A-101",
    "createdAt": "2025-11-05T14:30:00Z",
    "updatedAt": "2025-11-05T14:30:00Z",
    "property": {
      "id": "uuid",
      "name": "Dubai Marina Towers",
      "propertyType": "off-plan",
      "country": {
        "id": "uuid",
        "nameEn": "United Arab Emirates"
      },
      "city": {
        "id": "uuid",
        "nameEn": "Dubai"
      },
      "area": {
        "id": "uuid",
        "nameEn": "Dubai Marina"
      },
      "developer": {
        "id": "uuid",
        "name": "Emaar Properties"
      }
    }
  }
}
```

### Статуси заявки:

| Статус | Опис |
|--------|------|
| `pending` | Очікує підтвердження (default) |
| `confirmed` | Підтверджена |
| `completed` | Завершена |
| `cancelled` | Скасована |

### Логіка:

1. **Якщо користувач зареєстрований** (є JWT token):
   - `userId` береться з токену
   - `userEmail`, `userPhone`, `userFirstName`, `userLastName` не потрібні

2. **Якщо користувач не зареєстрований** (тільки API Key):
   - Потрібні `userEmail`, `userPhone`, `userFirstName`, `userLastName`
   - Можна створити тимчасового користувача або зберегти заявку без `userId`

3. **Валідація:**
   - `propertyId` повинен існувати
   - `amount` повинен бути > 0
   - `date` повинен бути валідною датою

### Приклад запиту (JavaScript):

```javascript
// Для не зареєстрованого користувача (публічний endpoint)
const response = await fetch('/api/investments/public', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    propertyId: '123e4567-e89b-12d3-a456-426614174000',
    amount: 200000,
    date: new Date().toISOString(),
    notes: 'Interested in unit A-101',
    userEmail: 'user@example.com',
    userPhone: '+971501234567',
    userFirstName: 'John',
    userLastName: 'Doe'
  })
});

// Для зареєстрованого користувача
const response = await fetch('/api/investments', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${jwtToken}`
  },
  body: JSON.stringify({
    propertyId: '123e4567-e89b-12d3-a456-426614174000',
    amount: 200000,
    date: new Date().toISOString(),
    notes: 'Interested in unit A-101'
  })
});
```

---

## Повний приклад використання

### Сценарій: Пошук проекту → Перегляд деталей → Подача заявки

```javascript
// 1. Пошук проектів з фільтрами
const propertiesResponse = await fetch(
  '/api/properties?propertyType=off-plan&cityId=123&bedrooms=2,3&priceFrom=200000&sortBy=priceFrom&sortOrder=ASC',
  {
    headers: {
      'x-api-key': 'your-api-key'
    }
  }
);
const properties = await propertiesResponse.json();

// 2. Перегляд деталей проекту
const propertyResponse = await fetch(
  `/api/properties/${properties.data[0].id}`,
  {
    headers: {
      'x-api-key': 'your-api-key'
    }
  }
);
const property = await propertyResponse.json();

// 3. Подача заявки (для не зареєстрованого користувача)
const investmentResponse = await fetch('/api/investments/public', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    propertyId: property.data.id,
    amount: property.data.priceFrom,
    date: new Date().toISOString(),
    notes: `Interested in ${property.data.bedroomsFrom}-bedroom unit`,
    userEmail: 'user@example.com',
    userPhone: '+971501234567',
    userFirstName: 'John',
    userLastName: 'Doe'
  })
});
const investment = await investmentResponse.json();
```

---

## Конвертація валют та одиниць

Всі проекти автоматично містять конвертовані значення:

- **USD → AED:** `price` → `priceAED`, `priceFrom` → `priceFromAED`
- **м² → sqft:** `size` → `sizeSqft`, `sizeFrom` → `sizeFromSqft`, `sizeTo` → `sizeToSqft`

**Коефіцієнти:**
- USD to AED: 3.67
- м² to sqft: 10.764

---

## Public API Endpoints

Для мобільного додатку/сайту доступні публічні endpoints з API Key:

- `GET /api/public/data` - Всі дані (properties, countries, cities, areas, developers, facilities, courses)
- `GET /api/public/courses` - Всі курси
- `GET /api/public/courses/:id` - Деталі курсу

**Authentication:** 
- Headers: `x-api-key` та `x-api-secret`

---

## Error Responses

### 400 Bad Request
```json
{
  "success": false,
  "message": "Property ID, amount, and date are required"
}
```

### 401 Unauthorized
```json
{
  "success": false,
  "message": "Unauthorized: No authorization header"
}
```

### 404 Not Found
```json
{
  "success": false,
  "message": "Property not found"
}
```

### 500 Internal Server Error
```json
{
  "success": false,
  "message": "Failed to fetch properties",
  "error": "Detailed error message (only in development)"
}
```

