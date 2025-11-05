# 📚 Course Schema (База знань) - API Documentation

## Структура даних

### Course Entity
```typescript
{
  id: string;                    // UUID (primary key)
  title: string;                 // Назва курсу (required)
  description: string;            // Опис курсу (required)
  order: number;                  // Порядок відображення (default: 0)
  contents: CourseContent[];      // Масив контенту (OneToMany)
  links: CourseLink[];            // Масив посилань (OneToMany)
  createdAt: Date;                // Дата створення
  updatedAt: Date;                // Дата оновлення
}
```

### CourseContent Entity
```typescript
{
  id: string;                     // UUID (primary key)
  courseId: string;               // Foreign key to courses.id
  type: 'text' | 'image' | 'video';  // Тип контенту (enum)
  title: string;                  // Заголовок секції (required)
  description: string | null;     // Текст опису (optional)
  imageUrl: string | null;        // URL зображення (optional, для type='image')
  videoUrl: string | null;        // URL відео (optional, для type='video')
  order: number;                  // Порядок відображення (required)
}
```

### CourseLink Entity
```typescript
{
  id: string;                     // UUID (primary key)
  courseId: string;               // Foreign key to courses.id
  title: string;                  // Назва посилання (required)
  url: string;                    // URL посилання (required)
  order: number;                  // Порядок відображення (required)
}
```

### CourseProgress Entity (для синхронізації прогресу)
```typescript
{
  id: string;                     // UUID (primary key)
  userId: string;                 // Foreign key to users.id
  courseId: string;               // Foreign key to courses.id
  completedContentIds: string[];  // Масив ID завершених секцій контенту
  completedLinkIds: string[];     // Масив ID переглянутих посилань
  isCompleted: boolean;           // Чи завершено курс повністю
  progressPercentage: number;    // Відсоток прогресу (0-100)
  completedAt: Date | null;        // Дата завершення курсу
  lastAccessedAt: Date | null;   // Останній доступ до курсу
  createdAt: Date;                // Дата створення запису
  updatedAt: Date;                // Дата оновлення
}
```

---

## API Endpoints

### 1. Overview: GET `/api/courses`
**Отримати список всіх курсів**

**Authentication:** JWT Token або API Key

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "title": "Course Title",
      "description": "Course description",
      "order": 0,
      "contents": [
        {
          "id": "uuid",
          "type": "text",
          "title": "Section Title",
          "description": "Text content",
          "imageUrl": null,
          "videoUrl": null,
          "order": 0
        },
        {
          "id": "uuid",
          "type": "image",
          "title": "Image Section",
          "description": "Image description",
          "imageUrl": "https://...",
          "videoUrl": null,
          "order": 1
        },
        {
          "id": "uuid",
          "type": "video",
          "title": "Video Section",
          "description": "Video description",
          "imageUrl": null,
          "videoUrl": "https://...",
          "order": 2
        }
      ],
      "links": [
        {
          "id": "uuid",
          "title": "External Link",
          "url": "https://...",
          "order": 0
        }
      ],
      "createdAt": "2025-11-05T12:00:00Z",
      "updatedAt": "2025-11-05T12:00:00Z"
    }
  ]
}
```

---

### 2. By ID: GET `/api/courses/:id`
**Отримати деталі одного курсу**

**Authentication:** JWT Token або API Key

**Response:** Аналогічно до Overview, але один об'єкт

---

### 3. Public API: GET `/api/public/courses`
**Отримати список всіх курсів (для мобільного додатку/сайту)**

**Authentication:** API Key + API Secret (headers: `x-api-key`, `x-api-secret`)

**Response:** Аналогічно до `/api/courses`

---

### 4. Public API: GET `/api/public/courses/:id`
**Отримати деталі одного курсу (для мобільного додатку/сайту)**

**Authentication:** API Key + API Secret

**Response:** Аналогічно до `/api/courses/:id`

---

## Синхронізація прогресу

### 5. GET `/api/course-progress/:userId`
**Отримати весь прогрес користувача**

**Authentication:** JWT Token або API Key

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "userId": "uuid",
      "courseId": "uuid",
      "completedContentIds": ["content-id-1", "content-id-2"],
      "completedLinkIds": ["link-id-1"],
      "isCompleted": false,
      "progressPercentage": 60,
      "completedAt": null,
      "lastAccessedAt": "2025-11-05T14:30:00Z",
      "createdAt": "2025-11-05T12:00:00Z",
      "updatedAt": "2025-11-05T14:30:00Z",
      "course": {
        "id": "uuid",
        "title": "Course Title",
        "description": "Course description",
        "order": 0
      }
    }
  ]
}
```

---

### 6. GET `/api/course-progress/:userId/:courseId`
**Отримати прогрес по конкретному курсу**

**Authentication:** JWT Token або API Key

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "userId": "uuid",
    "courseId": "uuid",
    "completedContentIds": ["content-id-1"],
    "completedLinkIds": [],
    "isCompleted": false,
    "progressPercentage": 30,
    "completedAt": null,
    "lastAccessedAt": "2025-11-05T14:30:00Z",
    "createdAt": "2025-11-05T12:00:00Z",
    "updatedAt": "2025-11-05T14:30:00Z",
    "course": {
      "id": "uuid",
      "title": "Course Title",
      "description": "Course description"
    }
  }
}
```

**Note:** Якщо прогресу немає, автоматично створюється з `progressPercentage: 0`

---

### 7. POST `/api/course-progress`
**Оновити прогрес (відмітити секцію/посилання як завершене)**

**Authentication:** JWT Token або API Key

**Request Body:**
```json
{
  "userId": "uuid",
  "courseId": "uuid",
  "contentId": "uuid",  // Optional: ID завершеної секції контенту
  "linkId": "uuid"      // Optional: ID переглянутого посилання
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "userId": "uuid",
    "courseId": "uuid",
    "completedContentIds": ["content-id-1", "content-id-2"],
    "completedLinkIds": ["link-id-1"],
    "isCompleted": false,
    "progressPercentage": 60,
    "lastAccessedAt": "2025-11-05T15:00:00Z",
    "course": { ... }
  }
}
```

**Логіка:**
- Якщо передано `contentId` - додається до `completedContentIds` (якщо ще немає)
- Якщо передано `linkId` - додається до `completedLinkIds` (якщо ще немає)
- Автоматично розраховується `progressPercentage` = (completed items / total items) * 100
- Якщо `progressPercentage === 100` - встановлюється `isCompleted = true` та `completedAt`

---

### 8. PUT `/api/course-progress/:userId/:courseId`
**Масове оновлення прогресу**

**Authentication:** JWT Token або API Key

**Request Body:**
```json
{
  "completedContentIds": ["content-id-1", "content-id-2"],
  "completedLinkIds": ["link-id-1"]
}
```

**Response:** Аналогічно до POST

**Використання:** Для синхронізації всього прогресу з мобільного додатку/сайту

---

## Синхронізація між сайтом, адмінкою та додатком

### ✅ Реалізовано:

1. **Синхронізація курсів:**
   - `/api/public/courses` - для мобільного додатку/сайту
   - `/api/courses` - для адмін панелі
   - Обидва використовують однакову базу даних

2. **Синхронізація прогресу:**
   - Таблиця `course_progress` зберігає прогрес кожного користувача по кожному курсу
   - Прогрес доступний через `/api/course-progress/:userId/:courseId`
   - Прогрес синхронізується між всіма платформами через API

3. **Автоматичний розрахунок:**
   - `progressPercentage` розраховується автоматично
   - `isCompleted` встановлюється автоматично при 100%
   - `lastAccessedAt` оновлюється при кожному доступі

### 🔄 Як працює синхронізація:

1. **Мобільний додаток/Сайт:**
   - Отримує курси через `/api/public/courses` (з API Key)
   - Відстежує прогрес локально
   - Відправляє прогрес через `POST /api/course-progress` або `PUT /api/course-progress/:userId/:courseId`

2. **Адмін панель:**
   - Переглядає курси через `/api/courses` (з JWT Token)
   - Може переглядати прогрес агентів через `/api/course-progress/:userId`

3. **База даних:**
   - Всі дані зберігаються в одній БД
   - Унікальний constraint `(userId, courseId)` забезпечує один запис прогресу на користувача/курс

---

## Приклад використання

### Мобільний додаток:
```javascript
// 1. Отримати курси
const courses = await fetch('/api/public/courses', {
  headers: {
    'x-api-key': 'your-api-key',
    'x-api-secret': 'your-api-secret'
  }
});

// 2. Відмітити секцію як завершену
await fetch('/api/course-progress', {
  method: 'POST',
  headers: {
    'x-api-key': 'your-api-key',
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    userId: 'user-uuid',
    courseId: 'course-uuid',
    contentId: 'content-uuid'
  })
});

// 3. Отримати прогрес користувача
const progress = await fetch(`/api/course-progress/${userId}/${courseId}`, {
  headers: {
    'x-api-key': 'your-api-key'
  }
});
```

### Адмін панель:
```javascript
// Переглянути прогрес агента
const agentProgress = await fetch(`/api/course-progress/${agentId}`, {
  headers: {
    'Authorization': `Bearer ${jwtToken}`
  }
});
```

---

## Міграція

Для створення таблиці `course_progress` виконайте міграцію:

```bash
cd admin-panel-backend
npx ts-node src/scripts/run-migration-005.ts
```

Або через SQL:
```sql
-- Файл: admin-panel-backend/src/migrations/005-create-course-progress.sql
```

