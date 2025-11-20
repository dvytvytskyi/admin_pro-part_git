# API Схема: Райони та Девелопери з підтримкою мов

## Огляд

API повертає дані для районів (areas) та девелоперів (developers) з підтримкою багатомовності. Всі описи зберігаються в форматі JSONB з підтримкою `en` (англійська) та `ru` (російська) мов.

---

## 🔑 Аутентифікація

Всі запити потребують API ключа через заголовок:
```
X-API-Key: ваш-api-ключ
X-API-Secret: ваш-api-secret
```

---

## 📍 Райони (Areas)

### Endpoint
```
GET /api/public/areas
```

### Query параметри
- `cityId` (опціонально) - ID міста для фільтрації районів

### Приклад запиту
```javascript
fetch('https://api.propart.ae/api/public/areas?cityId=xxx', {
  headers: {
    'X-API-Key': 'ваш-api-ключ',
    'X-API-Secret': 'ваш-api-secret'
  }
})
```

### Структура відповіді

```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "cityId": "uuid",
      "nameEn": "Business Bay",
      "nameRu": "Бизнес Бей",
      "nameAr": "بيزنس باي",
      "city": {
        "id": "uuid",
        "nameEn": "Dubai",
        "nameRu": "Дубай",
        "nameAr": "دبي",
        "countryId": "uuid",
        "country": {
          "id": "uuid",
          "nameEn": "United Arab Emirates",
          "nameRu": "Объединённые Арабские Эмираты",
          "nameAr": "الإمارات العربية المتحدة",
          "code": "AE"
        }
      },
      "projectsCount": {
        "total": 150,
        "offPlan": 100,
        "secondary": 50
      },
      "description": {
        "en": {
          "title": "Description",
          "description": "Business Bay is a central business district in Dubai..."
        },
        "ru": {
          "title": "Описание",
          "description": "Бизнес Бей — центральный деловой район Дубая..."
        }
      },
      "infrastructure": {
        "en": {
          "title": "Infrastructure",
          "description": "The area features modern infrastructure..."
        },
        "ru": {
          "title": "Инфраструктура",
          "description": "Район отличается современной инфраструктурой..."
        }
      },
      "images": [
        "https://example.com/image1.jpg",
        "https://example.com/image2.jpg"
      ]
    }
  ]
}
```

### Отримання тексту по мові

#### JavaScript/TypeScript
```typescript
interface AreaDescription {
  en?: {
    title?: string;
    description?: string;
  };
  ru?: {
    title?: string;
    description?: string;
  };
}

// Отримати опис району по мові
function getAreaDescription(area: any, language: 'en' | 'ru' = 'en'): string {
  if (!area.description) return '';
  
  const desc = area.description[language];
  return desc?.description || area.description.en?.description || '';
}

// Приклад використання
const area = response.data[0];
const englishDesc = getAreaDescription(area, 'en');
const russianDesc = getAreaDescription(area, 'ru');

// Отримати інфраструктуру по мові
function getAreaInfrastructure(area: any, language: 'en' | 'ru' = 'en'): string {
  if (!area.infrastructure) return '';
  
  const infra = area.infrastructure[language];
  return infra?.description || area.infrastructure.en?.description || '';
}
```

#### React приклад
```tsx
import { useState, useEffect } from 'react';

interface Area {
  id: string;
  nameEn: string;
  nameRu: string;
  description?: {
    en?: { title?: string; description?: string };
    ru?: { title?: string; description?: string };
  };
  infrastructure?: {
    en?: { title?: string; description?: string };
    ru?: { title?: string; description?: string };
  };
}

function AreaCard({ area, language }: { area: Area; language: 'en' | 'ru' }) {
  const getText = (obj: any, lang: 'en' | 'ru') => {
    return obj?.[lang]?.description || obj?.en?.description || '';
  };

  const getName = (lang: 'en' | 'ru') => {
    return lang === 'ru' ? area.nameRu : area.nameEn;
  };

  return (
    <div>
      <h2>{getName(language)}</h2>
      {area.description && (
        <div>
          <h3>{area.description[language]?.title || 'Description'}</h3>
          <p>{getText(area.description, language)}</p>
        </div>
      )}
      {area.infrastructure && (
        <div>
          <h3>{area.infrastructure[language]?.title || 'Infrastructure'}</h3>
          <p>{getText(area.infrastructure, language)}</p>
        </div>
      )}
    </div>
  );
}
```

---

## 🏢 Девелопери (Developers)

### Endpoint
```
GET /api/public/developers
```

### Приклад запиту
```javascript
fetch('https://api.propart.ae/api/public/developers', {
  headers: {
    'X-API-Key': 'ваш-api-ключ',
    'X-API-Secret': 'ваш-api-secret'
  }
})
```

### Структура відповіді

```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "name": "Emaar Properties",
      "logo": "https://example.com/logo.png",
      "description": {
        "en": {
          "description": "Emaar Properties is one of the world's most valuable..."
        },
        "ru": {
          "description": "Emaar Properties — одна из самых ценных..."
        }
      },
      "images": [
        "https://example.com/image1.jpg",
        "https://example.com/image2.jpg"
      ],
      "projectsCount": {
        "total": 500,
        "offPlan": 300,
        "secondary": 200
      },
      "createdAt": "2024-01-01T00:00:00.000Z"
    }
  ]
}
```

### Отримання тексту по мові

#### JavaScript/TypeScript
```typescript
interface DeveloperDescription {
  en?: {
    description?: string;
  };
  ru?: {
    description?: string;
  };
  // Backward compatibility
  description?: string;
}

// Отримати опис девелопера по мові
function getDeveloperDescription(developer: any, language: 'en' | 'ru' = 'en'): string {
  if (!developer.description) return '';
  
  // Якщо це старий формат (рядок)
  if (typeof developer.description === 'string') {
    return developer.description;
  }
  
  // Новий формат з en/ru
  const desc = developer.description[language];
  return desc?.description || developer.description.en?.description || '';
}

// Приклад використання
const developer = response.data[0];
const englishDesc = getDeveloperDescription(developer, 'en');
const russianDesc = getDeveloperDescription(developer, 'ru');
```

#### React приклад
```tsx
import { useState } from 'react';

interface Developer {
  id: string;
  name: string;
  logo?: string;
  description?: {
    en?: { description?: string };
    ru?: { description?: string };
  };
  projectsCount: {
    total: number;
    offPlan: number;
    secondary: number;
  };
}

function DeveloperCard({ developer, language }: { developer: Developer; language: 'en' | 'ru' }) {
  const getDescription = () => {
    if (!developer.description) return '';
    
    // Backward compatibility
    if (typeof developer.description === 'string') {
      return developer.description;
    }
    
    return developer.description[language]?.description || 
           developer.description.en?.description || 
           '';
  };

  return (
    <div>
      <img src={developer.logo} alt={developer.name} />
      <h2>{developer.name}</h2>
      <p>{getDescription()}</p>
      <div>
        <span>Total: {developer.projectsCount.total}</span>
        <span>Off-plan: {developer.projectsCount.offPlan}</span>
        <span>Secondary: {developer.projectsCount.secondary}</span>
      </div>
    </div>
  );
}
```

---

## 🛠️ Утиліти для роботи з мовами

### TypeScript утиліти

```typescript
// types.ts
export type Language = 'en' | 'ru';

export interface MultilingualText {
  en?: {
    title?: string;
    description?: string;
  };
  ru?: {
    title?: string;
    description?: string;
  };
}

export interface DeveloperDescription {
  en?: {
    description?: string;
  };
  ru?: {
    description?: string;
  };
  // Backward compatibility
  description?: string;
}

// utils.ts
export const getMultilingualText = (
  obj: MultilingualText | null | undefined,
  language: Language,
  fallback: 'en' | 'ru' = 'en'
): string => {
  if (!obj) return '';
  
  const langText = obj[language];
  if (langText?.description) {
    return langText.description;
  }
  
  // Fallback to other language
  const fallbackText = obj[fallback];
  return fallbackText?.description || '';
};

export const getMultilingualTitle = (
  obj: MultilingualText | null | undefined,
  language: Language,
  fallback: 'en' | 'ru' = 'en'
): string => {
  if (!obj) return '';
  
  const langText = obj[language];
  if (langText?.title) {
    return langText.title;
  }
  
  const fallbackText = obj[fallback];
  return fallbackText?.title || '';
};

export const getDeveloperDescription = (
  developer: { description?: DeveloperDescription | string | null },
  language: Language
): string => {
  if (!developer.description) return '';
  
  // Backward compatibility - старий формат (рядок)
  if (typeof developer.description === 'string') {
    return developer.description;
  }
  
  // Новий формат з en/ru
  const desc = developer.description[language];
  if (desc?.description) {
    return desc.description;
  }
  
  // Fallback to English
  return developer.description.en?.description || '';
};

// Hook для React
import { useState, useCallback } from 'react';

export const useLanguage = (defaultLang: Language = 'en') => {
  const [language, setLanguage] = useState<Language>(defaultLang);
  
  const toggleLanguage = useCallback(() => {
    setLanguage(prev => prev === 'en' ? 'ru' : 'en');
  }, []);
  
  return { language, setLanguage, toggleLanguage };
};
```

### Приклад використання утиліт

```tsx
import { useLanguage } from './utils';
import { getMultilingualText, getDeveloperDescription } from './utils';

function AreasList() {
  const { language, toggleLanguage } = useLanguage('en');
  const [areas, setAreas] = useState([]);
  
  useEffect(() => {
    fetch('/api/public/areas', {
      headers: {
        'X-API-Key': 'ваш-ключ',
        'X-API-Secret': 'ваш-secret'
      }
    })
      .then(res => res.json())
      .then(data => setAreas(data.data));
  }, []);
  
  return (
    <div>
      <button onClick={toggleLanguage}>
        Switch to {language === 'en' ? 'Russian' : 'English'}
      </button>
      
      {areas.map(area => (
        <div key={area.id}>
          <h2>{language === 'ru' ? area.nameRu : area.nameEn}</h2>
          <p>{getMultilingualText(area.description, language)}</p>
          <p>{getMultilingualText(area.infrastructure, language)}</p>
        </div>
      ))}
    </div>
  );
}

function DevelopersList() {
  const { language } = useLanguage('en');
  const [developers, setDevelopers] = useState([]);
  
  useEffect(() => {
    fetch('/api/public/developers', {
      headers: {
        'X-API-Key': 'ваш-ключ',
        'X-API-Secret': 'ваш-secret'
      }
    })
      .then(res => res.json())
      .then(data => setDevelopers(data.data));
  }, []);
  
  return (
    <div>
      {developers.map(developer => (
        <div key={developer.id}>
          <h2>{developer.name}</h2>
          <p>{getDeveloperDescription(developer, language)}</p>
          <span>Projects: {developer.projectsCount.total}</span>
        </div>
      ))}
    </div>
  );
}
```

---

## 📋 Повний приклад інтеграції

```typescript
// api.ts
const API_BASE_URL = 'https://api.propart.ae/api/public';
const API_KEY = 'ваш-api-ключ';
const API_SECRET = 'ваш-api-secret';

const headers = {
  'X-API-Key': API_KEY,
  'X-API-Secret': API_SECRET,
  'Content-Type': 'application/json'
};

export const fetchAreas = async (cityId?: string) => {
  const url = cityId 
    ? `${API_BASE_URL}/areas?cityId=${cityId}`
    : `${API_BASE_URL}/areas`;
  
  const response = await fetch(url, { headers });
  const data = await response.json();
  
  if (data.success) {
    return data.data;
  }
  throw new Error(data.message || 'Failed to fetch areas');
};

export const fetchDevelopers = async () => {
  const response = await fetch(`${API_BASE_URL}/developers`, { headers });
  const data = await response.json();
  
  if (data.success) {
    return data.data;
  }
  throw new Error(data.message || 'Failed to fetch developers');
};

// App.tsx
import { fetchAreas, fetchDevelopers } from './api';
import { useLanguage } from './utils';
import { getMultilingualText, getDeveloperDescription } from './utils';

function App() {
  const { language, toggleLanguage } = useLanguage('en');
  const [areas, setAreas] = useState([]);
  const [developers, setDevelopers] = useState([]);
  
  useEffect(() => {
    Promise.all([
      fetchAreas(),
      fetchDevelopers()
    ]).then(([areasData, developersData]) => {
      setAreas(areasData);
      setDevelopers(developersData);
    });
  }, []);
  
  return (
    <div>
      <button onClick={toggleLanguage}>
        {language === 'en' ? '🇬🇧' : '🇷🇺'} 
        {language === 'en' ? 'English' : 'Русский'}
      </button>
      
      <section>
        <h1>Areas</h1>
        {areas.map(area => (
          <div key={area.id}>
            <h2>{language === 'ru' ? area.nameRu : area.nameEn}</h2>
            <p>{getMultilingualText(area.description, language)}</p>
            <p>{getMultilingualText(area.infrastructure, language)}</p>
          </div>
        ))}
      </section>
      
      <section>
        <h1>Developers</h1>
        {developers.map(dev => (
          <div key={dev.id}>
            <h2>{dev.name}</h2>
            <p>{getDeveloperDescription(dev, language)}</p>
          </div>
        ))}
      </section>
    </div>
  );
}
```

---

## ⚠️ Важливо

1. **Backward Compatibility**: API підтримує старий формат `description` як рядок для зворотної сумісності
2. **Fallback**: Завжди використовуйте fallback на `en` якщо переклад на потрібну мову відсутній
3. **Null Safety**: Завжди перевіряйте наявність `description` та `infrastructure` перед доступом до вкладених властивостей
4. **Мови**: Наразі підтримуються тільки `en` та `ru`. `ar` буде додано пізніше

---

## 🔄 Оновлення

Дані автоматично оновлюються при зміні в адмін-панелі. Немає необхідності в додаткових запитах для перевірки оновлень (окрім периодичного рефетчу на фронтенді).

