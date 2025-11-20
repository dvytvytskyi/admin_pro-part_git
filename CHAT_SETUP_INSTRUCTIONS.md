# 🚀 Інструкції по налаштуванню системи чату

## Крок 1: Створити таблиці в БД

```bash
cd admin-panel-backend
npm run create:chat-tables
```

## Крок 2: Перевірити, що всі файли створені

### Backend
- ✅ `src/entities/ChatSession.ts`
- ✅ `src/entities/ChatMessage.ts`
- ✅ `src/routes/chat.routes.ts`
- ✅ `src/routes/public-chat.routes.ts`
- ✅ Entities додані до `src/entities/index.ts`
- ✅ Routes додані до `src/server.ts`

### Frontend (Адмін панель)
- ✅ `src/app/chat/page.tsx` - Список чатів
- ✅ `src/app/chat/[id]/page.tsx` - Детальний перегляд чату
- ✅ `src/app/chat/layout.tsx` - Layout
- ✅ Пункт меню "Чати" доданий до `AdminLayout.tsx`

## Крок 3: Оновити ChatWidget на фронтенді

### Основні зміни:

1. **Додати збереження сесії в localStorage:**
```typescript
// При створенні сесії
localStorage.setItem('chatSessionId', sessionId)
localStorage.setItem('chatUserSessionId', userSessionId)

// При завантаженні сторінки
const storedSessionId = localStorage.getItem('chatSessionId')
if (storedSessionId) {
  // Відновити сесію та завантажити повідомлення
}
```

2. **Замінити `/api/telegram-notify` на нові endpoints:**
```typescript
// Замість старого endpoint
// fetch('/api/telegram-notify', ...)

// Використовувати нові
fetch('https://api.propart.ae/api/public/chat/sessions', {
  method: 'POST',
  headers: {
    'X-API-Key': 'ваш-api-ключ',
    'X-API-Secret': 'ваш-api-secret',
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    userSessionId: localStorage.getItem('chatUserSessionId'),
    firstMessage: 'Текст повідомлення',
  }),
})
```

3. **Додати polling для нових повідомлень:**
```typescript
useEffect(() => {
  if (sessionId && isOpen) {
    const interval = setInterval(async () => {
      const response = await fetch(
        `https://api.propart.ae/api/public/chat/sessions/${sessionId}/messages?since=${lastMessageTime}`,
        {
          headers: {
            'X-API-Key': 'ваш-api-ключ',
            'X-API-Secret': 'ваш-api-secret',
          },
        }
      )
      const data = await response.json()
      if (data.success && data.data.messages.length > 0) {
        // Додати нові повідомлення до UI
        setMessages(prev => [...prev, ...data.data.messages])
      }
    }, 2000) // Кожні 2 секунди

    return () => clearInterval(interval)
  }
}, [sessionId, isOpen])
```

4. **Оновити відправку контактних даних:**
```typescript
// Замість старого telegram-notify
// Відправляти через POST /api/public/chat/sessions з name та phone
const response = await fetch('https://api.propart.ae/api/public/chat/sessions', {
  method: 'POST',
  headers: {
    'X-API-Key': 'ваш-api-ключ',
    'X-API-Secret': 'ваш-api-secret',
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    name: formData.name,
    phone: formData.phone,
    userSessionId: localStorage.getItem('chatUserSessionId'),
  }),
})
```

## Крок 4: Налаштувати API ключі на фронтенді

Додати в `.env.local` (на фронтенді):
```
NEXT_PUBLIC_API_KEY=ваш-api-ключ
NEXT_PUBLIC_API_SECRET=ваш-api-secret
NEXT_PUBLIC_API_URL=https://api.propart.ae/api/public
```

Використовувати в коді:
```typescript
const API_KEY = process.env.NEXT_PUBLIC_API_KEY
const API_SECRET = process.env.NEXT_PUBLIC_API_SECRET
const API_URL = process.env.NEXT_PUBLIC_API_URL || 'https://api.propart.ae/api/public'
```

## Крок 5: Перевірити роботу

1. **На фронтенді:**
   - Відкрити чат
   - Відправити повідомлення
   - Перевірити, що сесія створюється в БД

2. **В адмін панелі:**
   - Відкрити `/chat`
   - Перевірити, що сесія відображається
   - Відкрити чат і відправити відповідь

3. **Перевірити polling:**
   - Відкрити чат на фронтенді
   - Відправити відповідь з адмін панелі
   - Перевірити, що відповідь з'являється через 2-3 секунди

---

## 📋 API Endpoints для фронтенду

### Base URL
```
https://api.propart.ae/api/public/chat
```

### Endpoints

1. **POST /sessions** - Створити/отримати сесію
2. **POST /sessions/:id/messages** - Відправити повідомлення
3. **GET /sessions/:id/messages?since=...** - Отримати нові повідомлення (polling)

### Headers
```
X-API-Key: ваш-api-ключ
X-API-Secret: ваш-api-secret
Content-Type: application/json
```

---

## 📋 API Endpoints для адмін панелі

### Base URL
```
https://api.propart.ae/api/chat
```

### Endpoints

1. **GET /sessions** - Список сесій (з фільтрами)
2. **GET /sessions/:id** - Деталі сесії
3. **POST /sessions/:id/messages** - Відправити відповідь
4. **POST /sessions/:id/close** - Закрити сесію
5. **GET /stats** - Статистика

### Headers
```
Authorization: Bearer ваш-jwt-token
Content-Type: application/json
```

---

## 🔄 Потік роботи

### Відкриття чату користувачем:
1. Користувач натискає кнопку чату
2. Перевіряється `localStorage.getItem('chatSessionId')`
3. Якщо немає - створюється `userSessionId` і викликається `POST /api/public/chat/sessions`
4. Зберігається `sessionId` в localStorage
5. Завантажуються повідомлення (якщо є)

### Відправка повідомлення:
1. Користувач вводить текст і відправляє
2. Викликається `POST /api/public/chat/sessions/:id/messages`
3. Повідомлення зберігається в БД
4. Відправляється в Telegram (якщо налаштовано)
5. Автоматична відповідь бота (опціонально)

### Polling нових повідомлень:
1. Кожні 2 секунди викликається `GET /api/public/chat/sessions/:id/messages?since=...`
2. Якщо є нові повідомлення - додаються до UI
3. Оновлюється `lastMessageTime` для наступного polling

### Відповідь менеджера:
1. Менеджер відкриває чат в адмін панелі
2. Відправляє відповідь через `POST /api/chat/sessions/:id/messages`
3. Повідомлення зберігається в БД
4. Polling на фронтенді отримує нове повідомлення
5. UI оновлюється автоматично

---

## ⚠️ Важливі зауваження

1. **API ключі** - НЕ зберігати в коді, використовувати env змінні
2. **Polling** - Запускати тільки коли чат відкритий, зупиняти при закритті
3. **localStorage** - Використовувати для збереження сесії між перезавантаженнями
4. **Очищення** - Можна очищати localStorage при закритті сесії (опціонально)
5. **Telegram** - Продовжує працювати через legacy endpoint `/api/public/chat/notify`

---

## 📝 Файли для оновлення на фронтенді

1. `components/ChatWidget.tsx` - Основна логіка чату
2. `.env.local` - API ключі та URL
3. Можливо потребується оновлення `lib/api.ts` для публічних endpoints

---

## ✅ Чеклист

- [ ] Створені таблиці в БД (`npm run create:chat-tables`)
- [ ] Оновлено ChatWidget на фронтенді
- [ ] Налаштовані API ключі в env змінних
- [ ] Перевірено створення сесії через фронтенд
- [ ] Перевірено відповіді через адмін панель
- [ ] Перевірено polling нових повідомлень
- [ ] Перевірено відновлення сесії при перезавантаженні

---

**Всі необхідні файли створені та готові до використання!**

