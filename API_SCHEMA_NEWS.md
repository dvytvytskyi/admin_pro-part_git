# API Схема: Новини (News)

## Огляд

API для отримання опублікованих новин з підтримкою пагінації, мультимовності та структурованого контенту.

---

## 🔑 Аутентифікація

Всі запити потребують API ключа через заголовок:
```
X-API-Key: ваш-api-ключ
X-API-Secret: ваш-api-secret
```

---

## 📰 Новини (News)

### 1. Отримати список новин (з пагінацією)

#### Endpoint
```
GET /api/public/news
```

#### Query параметри
- `page` (опціонально, за замовчуванням: 1) - Номер сторінки
- `limit` (опціонально, за замовчуванням: 20, максимум: 100) - Кількість новин на сторінці

#### Приклад запиту
```javascript
// Перша сторінка (20 новин)
fetch('https://api.propart.ae/api/public/news', {
  headers: {
    'X-API-Key': 'ваш-api-ключ',
    'X-API-Secret': 'ваш-api-secret'
  }
})

// Друга сторінка з 10 новинами
fetch('https://api.propart.ae/api/public/news?page=2&limit=10', {
  headers: {
    'X-API-Key': 'ваш-api-ключ',
    'X-API-Secret': 'ваш-api-secret'
  }
})
```

#### Структура відповіді

```json
{
  "success": true,
  "data": {
    "data": [
      {
        "id": "uuid",
        "slug": "perspectives-real-estate-market",
        "title": "Perspectives of the Real Estate Market",
        "titleRu": "Перспективы рынка недвижимости",
        "description": "Short description of the news article...",
        "descriptionRu": "Краткое описание новости...",
        "image": "https://example.com/news-image.jpg",
        "publishedAt": "2024-01-15T10:30:00.000Z"
      }
    ],
    "total": 150,
    "page": 1,
    "limit": 20,
    "totalPages": 8
  }
}
```

#### TypeScript інтерфейс

```typescript
interface NewsListItem {
  id: string;
  slug: string;
  title: string;
  titleRu: string | null;
  description: string;
  descriptionRu: string | null;
  image: string | null;
  publishedAt: string; // ISO date string
}

interface NewsListResponse {
  success: boolean;
  data: {
    data: NewsListItem[];
    total: number;
    page: number;
    limit: number;
    totalPages: number;
  };
}
```

---

### 2. Отримати одну новину за slug або ID

#### Endpoint
```
GET /api/public/news/:slug
```

#### Параметри
- `slug` - Slug новини (генерується з title) або UUID id

#### Приклад запиту
```javascript
// По slug
fetch('https://api.propart.ae/api/public/news/perspectives-real-estate-market', {
  headers: {
    'X-API-Key': 'ваш-api-ключ',
    'X-API-Secret': 'ваш-api-secret'
  }
})

// По ID (UUID)
fetch('https://api.propart.ae/api/public/news/550e8400-e29b-41d4-a716-446655440000', {
  headers: {
    'X-API-Key': 'ваш-api-ключ',
    'X-API-Secret': 'ваш-api-secret'
  }
})
```

#### Структура відповіді

```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "slug": "perspectives-real-estate-market",
    "title": "Perspectives of the Real Estate Market",
    "titleRu": "Перспективы рынка недвижимости",
    "description": "Full description of the news article...",
    "descriptionRu": "Полное описание новости...",
    "image": "https://example.com/news-image.jpg",
    "publishedAt": "2024-01-15T10:30:00.000Z",
    "contents": [
      {
        "type": "text",
        "title": "Section Title",
        "description": "Text content here...",
        "imageUrl": null,
        "videoUrl": null,
        "order": 1
      },
      {
        "type": "image",
        "title": "Image Title",
        "description": "Image description",
        "imageUrl": "https://example.com/content-image.jpg",
        "videoUrl": null,
        "order": 2
      },
      {
        "type": "video",
        "title": "Video Title",
        "description": "Video description",
        "imageUrl": null,
        "videoUrl": "https://example.com/video.mp4",
        "order": 3
      }
    ]
  }
}
```

#### TypeScript інтерфейс

```typescript
type NewsContentType = 'text' | 'image' | 'video';

interface NewsContent {
  type: NewsContentType;
  title: string;
  description: string | null;
  imageUrl: string | null;
  videoUrl: string | null;
  order: number;
}

interface NewsDetail {
  id: string;
  slug: string;
  title: string;
  titleRu: string | null;
  description: string;
  descriptionRu: string | null;
  image: string | null;
  publishedAt: string; // ISO date string
  contents: NewsContent[];
}

interface NewsDetailResponse {
  success: boolean;
  data: NewsDetail;
}
```

---

## 📝 Приклади використання

### JavaScript/TypeScript

```typescript
// Функція для отримання списку новин
async function fetchNews(page = 1, limit = 20) {
  const response = await fetch(
    `https://api.propart.ae/api/public/news?page=${page}&limit=${limit}`,
    {
      headers: {
        'X-API-Key': 'ваш-api-ключ',
        'X-API-Secret': 'ваш-api-secret'
      }
    }
  );
  
  const data = await response.json();
  
  if (data.success) {
    return data.data;
  }
  
  throw new Error(data.message || 'Failed to fetch news');
}

// Функція для отримання однієї новини
async function fetchNewsBySlug(slug: string) {
  const response = await fetch(
    `https://api.propart.ae/api/public/news/${slug}`,
    {
      headers: {
        'X-API-Key': 'ваш-api-ключ',
        'X-API-Secret': 'ваш-api-secret'
      }
    }
  );
  
  const data = await response.json();
  
  if (data.success) {
    return data.data;
  }
  
  throw new Error(data.message || 'News not found');
}

// Отримання тексту по мові
function getNewsText(news: NewsListItem | NewsDetail, language: 'en' | 'ru' = 'en') {
  if (language === 'ru') {
    return {
      title: news.titleRu || news.title,
      description: news.descriptionRu || news.description,
    };
  }
  
  return {
    title: news.title,
    description: news.description,
  };
}
```

### React Hook

```tsx
import { useState, useEffect } from 'react';

interface UseNewsProps {
  page?: number;
  limit?: number;
  language?: 'en' | 'ru';
}

export function useNews({ page = 1, limit = 20, language = 'en' }: UseNewsProps = {}) {
  const [news, setNews] = useState<NewsListItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [pagination, setPagination] = useState({
    total: 0,
    page: 1,
    limit: 20,
    totalPages: 0,
  });
  
  useEffect(() => {
    async function loadNews() {
      try {
        setLoading(true);
        const response = await fetch(
          `https://api.propart.ae/api/public/news?page=${page}&limit=${limit}`,
          {
            headers: {
              'X-API-Key': 'ваш-api-ключ',
              'X-API-Secret': 'ваш-api-secret'
            }
          }
        );
        
        const data = await response.json();
        
        if (data.success) {
          setNews(data.data.data);
          setPagination({
            total: data.data.total,
            page: data.data.page,
            limit: data.data.limit,
            totalPages: data.data.totalPages,
          });
        } else {
          setError(data.message || 'Failed to fetch news');
        }
      } catch (err: any) {
        setError(err.message || 'An error occurred');
      } finally {
        setLoading(false);
      }
    }
    
    loadNews();
  }, [page, limit]);
  
  const getText = (item: NewsListItem) => {
    if (language === 'ru') {
      return {
        title: item.titleRu || item.title,
        description: item.descriptionRu || item.description,
      };
    }
    
    return {
      title: item.title,
      description: item.description,
    };
  };
  
  return {
    news,
    loading,
    error,
    pagination,
    getText,
  };
}
```

### React компонент для списку новин

```tsx
import { useState } from 'react';
import { useNews } from './hooks/useNews';

function NewsList() {
  const [page, setPage] = useState(1);
  const [language, setLanguage] = useState<'en' | 'ru'>('en');
  const { news, loading, error, pagination, getText } = useNews({ page, limit: 12 });
  
  if (loading) return <div>Loading...</div>;
  if (error) return <div>Error: {error}</div>;
  
  return (
    <div>
      <button onClick={() => setLanguage(lang => lang === 'en' ? 'ru' : 'en')}>
        {language === 'en' ? '🇬🇧 EN' : '🇷🇺 RU'}
      </button>
      
      <div className="news-grid">
        {news.map(item => {
          const text = getText(item);
          
          return (
            <article key={item.id} className="news-card">
              {item.image && (
                <img src={item.image} alt={text.title} />
              )}
              <h2>{text.title}</h2>
              <p>{text.description}</p>
              <a href={`/news/${item.slug}`}>Read more</a>
              <time>{new Date(item.publishedAt).toLocaleDateString()}</time>
            </article>
          );
        })}
      </div>
      
      <div className="pagination">
        <button 
          disabled={page === 1}
          onClick={() => setPage(p => p - 1)}
        >
          Previous
        </button>
        
        <span>
          Page {pagination.page} of {pagination.totalPages}
        </span>
        
        <button 
          disabled={page >= pagination.totalPages}
          onClick={() => setPage(p => p + 1)}
        >
          Next
        </button>
      </div>
    </div>
  );
}
```

### React компонент для деталей новини

```tsx
import { useState, useEffect } from 'react';

function NewsDetail({ slug }: { slug: string }) {
  const [news, setNews] = useState<NewsDetail | null>(null);
  const [loading, setLoading] = useState(true);
  const [language, setLanguage] = useState<'en' | 'ru'>('en');
  
  useEffect(() => {
    async function loadNews() {
      try {
        setLoading(true);
        const response = await fetch(
          `https://api.propart.ae/api/public/news/${slug}`,
          {
            headers: {
              'X-API-Key': 'ваш-api-ключ',
              'X-API-Secret': 'ваш-api-secret'
            }
          }
        );
        
        const data = await response.json();
        
        if (data.success) {
          setNews(data.data);
        }
      } catch (err) {
        console.error('Error loading news:', err);
      } finally {
        setLoading(false);
      }
    }
    
    loadNews();
  }, [slug]);
  
  if (loading) return <div>Loading...</div>;
  if (!news) return <div>News not found</div>;
  
  const getText = () => {
    if (language === 'ru') {
      return {
        title: news.titleRu || news.title,
        description: news.descriptionRu || news.description,
      };
    }
    
    return {
      title: news.title,
      description: news.description,
    };
  };
  
  const text = getText();
  
  return (
    <article className="news-detail">
      <button onClick={() => setLanguage(lang => lang === 'en' ? 'ru' : 'en')}>
        {language === 'en' ? '🇬🇧 EN' : '🇷🇺 RU'}
      </button>
      
      {news.image && (
        <img src={news.image} alt={text.title} className="news-hero-image" />
      )}
      
      <header>
        <h1>{text.title}</h1>
        <time>{new Date(news.publishedAt).toLocaleDateString()}</time>
      </header>
      
      <div className="news-description">
        <p>{text.description}</p>
      </div>
      
      <div className="news-contents">
        {news.contents.map((content, index) => (
          <div key={index} className={`content-${content.type}`}>
            {content.type === 'text' && (
              <div>
                <h2>{content.title}</h2>
                {content.description && <p>{content.description}</p>}
              </div>
            )}
            
            {content.type === 'image' && (
              <div>
                {content.imageUrl && (
                  <img src={content.imageUrl} alt={content.title} />
                )}
                <h3>{content.title}</h3>
                {content.description && <p>{content.description}</p>}
              </div>
            )}
            
            {content.type === 'video' && (
              <div>
                {content.videoUrl && (
                  <video src={content.videoUrl} controls>
                    Your browser does not support the video tag.
                  </video>
                )}
                <h3>{content.title}</h3>
                {content.description && <p>{content.description}</p>}
              </div>
            )}
          </div>
        ))}
      </div>
    </article>
  );
}
```

---

## 🔍 Важливі деталі

### Фільтрація опублікованих новин

API повертає **тільки опубліковані** новини, які:
- Мають `isPublished = true`
- Мають `publishedAt` не null
- Мають `publishedAt <= поточний час`

### Slug генерація

Slug генерується автоматично з `title`:
- Переводиться в нижній регістр
- Спеціальні символи видаляються
- Пробіли замінюються на дефіси
- Ведучі/кінцеві дефіси видаляються

Приклад: `"Perspectives of the Real Estate Market"` → `"perspectives-of-the-real-estate-market"`

### Пошук по slug або ID

Endpoint `/api/public/news/:slug` підтримує:
- **Slug** (наприклад: `perspectives-real-estate-market`)
- **UUID** (наприклад: `550e8400-e29b-41d4-a716-446655440000`)

API автоматично визначає формат і шукає відповідно.

### Мультимовність

Новини підтримують дві мови:
- `en` (англійська) - завжди присутня
- `ru` (російська) - опціональна

Якщо переклад відсутній, використовується англійська версія.

### Контент блоки (Contents)

Кожна новина може містити структурований контент:

- **text** - Текстовий блок з заголовком та описом
- **image** - Зображення з заголовком та описом
- **video** - Відео з заголовком та описом

Блоки сортуються по полю `order` (від меншого до більшого).

---

## ⚠️ Обмеження

- Максимальний `limit` на сторінці: **100**
- Тільки опубліковані новини доступні через public API
- Контент блоки повертаються тільки в детальному запиті (`/news/:slug`)

---

## 🔄 Оновлення

Дані автоматично оновлюються при публікації/редагуванні в адмін-панелі. Немає необхідності в додаткових запитах для перевірки оновлень (окрім периодичного рефетчу на фронтенді).

