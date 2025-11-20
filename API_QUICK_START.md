# API Quick Start: Areas та Developers

## 🚀 Швидкий старт

### 1. Отримати всі райони

```javascript
const response = await fetch('https://api.propart.ae/api/public/areas', {
  headers: {
    'X-API-Key': 'ваш-api-ключ',
    'X-API-Secret': 'ваш-api-secret'
  }
});

const { data } = await response.json();
// data - масив районів
```

### 2. Отримати райони конкретного міста

```javascript
const cityId = 'uuid-міста';
const response = await fetch(
  `https://api.propart.ae/api/public/areas?cityId=${cityId}`,
  {
    headers: {
      'X-API-Key': 'ваш-api-ключ',
      'X-API-Secret': 'ваш-api-secret'
    }
  }
);

const { data } = await response.json();
```

### 3. Отримати всіх девелоперів

```javascript
const response = await fetch('https://api.propart.ae/api/public/developers', {
  headers: {
    'X-API-Key': 'ваш-api-ключ',
    'X-API-Secret': 'ваш-api-secret'
  }
});

const { data } = await response.json();
// data - масив девелоперів
```

---

## 📝 Приклад роботи з мовами

### JavaScript

```javascript
// Функція для отримання опису району
function getAreaDescription(area, lang = 'en') {
  if (!area.description) return '';
  return area.description[lang]?.description || 
         area.description.en?.description || 
         '';
}

// Функція для отримання опису девелопера
function getDeveloperDescription(developer, lang = 'en') {
  if (!developer.description) return '';
  
  // Старий формат (рядок)
  if (typeof developer.description === 'string') {
    return developer.description;
  }
  
  // Новий формат (en/ru)
  return developer.description[lang]?.description || 
         developer.description.en?.description || 
         '';
}

// Використання
const area = areas[0];
console.log('EN:', getAreaDescription(area, 'en'));
console.log('RU:', getAreaDescription(area, 'ru'));

const developer = developers[0];
console.log('EN:', getDeveloperDescription(developer, 'en'));
console.log('RU:', getDeveloperDescription(developer, 'ru'));
```

### React Hook

```tsx
import { useState } from 'react';

export function useMultilingualData() {
  const [language, setLanguage] = useState<'en' | 'ru'>('en');
  
  const getAreaDescription = (area: any) => {
    if (!area?.description) return '';
    return area.description[language]?.description || 
           area.description.en?.description || 
           '';
  };
  
  const getAreaInfrastructure = (area: any) => {
    if (!area?.infrastructure) return '';
    return area.infrastructure[language]?.description || 
           area.infrastructure.en?.description || 
           '';
  };
  
  const getDeveloperDescription = (developer: any) => {
    if (!developer?.description) return '';
    
    if (typeof developer.description === 'string') {
      return developer.description;
    }
    
    return developer.description[language]?.description || 
           developer.description.en?.description || 
           '';
  };
  
  const getAreaName = (area: any) => {
    return language === 'ru' ? area.nameRu : area.nameEn;
  };
  
  return {
    language,
    setLanguage,
    getAreaDescription,
    getAreaInfrastructure,
    getDeveloperDescription,
    getAreaName,
  };
}
```

### Використання Hook

```tsx
function AreasList({ areas }) {
  const { 
    language, 
    setLanguage, 
    getAreaDescription, 
    getAreaInfrastructure,
    getAreaName 
  } = useMultilingualData();
  
  return (
    <div>
      <button onClick={() => setLanguage(lang => lang === 'en' ? 'ru' : 'en')}>
        {language === 'en' ? '🇬🇧 EN' : '🇷🇺 RU'}
      </button>
      
      {areas.map(area => (
        <div key={area.id}>
          <h2>{getAreaName(area)}</h2>
          <p>{getAreaDescription(area)}</p>
          <p>{getAreaInfrastructure(area)}</p>
        </div>
      ))}
    </div>
  );
}
```

---

## 📊 Структура даних

### Area
```typescript
{
  id: string;
  nameEn: string;
  nameRu: string;
  nameAr: string;
  description?: {
    en?: { title?: string; description?: string };
    ru?: { title?: string; description?: string };
  };
  infrastructure?: {
    en?: { title?: string; description?: string };
    ru?: { title?: string; description?: string };
  };
  images: string[];
  projectsCount: {
    total: number;
    offPlan: number;
    secondary: number;
  };
}
```

### Developer
```typescript
{
  id: string;
  name: string;
  logo?: string;
  description?: {
    en?: { description?: string };
    ru?: { description?: string };
  } | string; // може бути рядком для backward compatibility
  images: string[];
  projectsCount: {
    total: number;
    offPlan: number;
    secondary: number;
  };
}
```

---

## 🔗 Endpoints

- `GET /api/public/areas` - Всі райони (опціонально: `?cityId=uuid`)
- `GET /api/public/developers` - Всі девелопери

---

Див. повну документацію в `API_SCHEMA_AREAS_DEVELOPERS.md`

