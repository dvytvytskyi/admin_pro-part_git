# API Документація: Чат для фронтенду

## Огляд

API для інтеграції чату на фронтенді з підтримкою збереження сесій та повідомлень в базі даних.

---

## 🔑 Аутентифікація

Всі публічні endpoints потребують API ключа:
```
X-API-Key: ваш-api-ключ
X-API-Secret: ваш-api-secret
```

---

## 📡 Endpoints для фронтенду

### 1. Створити/Отримати сесію чату

#### Endpoint
```
POST /api/public/chat/sessions
```

#### Request Body
```json
{
  "name": "Ім'я користувача" (опціонально),
  "phone": "+380123456789" (опціонально),
  "userSessionId": "унікальний-id-з-localStorage" (опціонально, але рекомендується),
  "firstMessage": "Текст першого повідомлення" (опціонально)
}
```

#### Response
```json
{
  "success": true,
  "data": {
    "sessionId": "uuid",
    "session": {
      "id": "uuid",
      "userName": "Ім'я",
      "userPhone": "+380...",
      "status": "active",
      "createdAt": "2024-01-20T10:30:00.000Z"
    },
    "messages": [
      {
        "id": "uuid",
        "sender": "user",
        "messageText": "Текст повідомлення",
        "createdAt": "2024-01-20T10:30:00.000Z"
      }
    ]
  }
}
```

#### Використання
```javascript
// При першому відкритті чату
const response = await fetch('https://api.propart.ae/api/public/chat/sessions', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'X-API-Key': 'ваш-api-ключ',
    'X-API-Secret': 'ваш-api-secret'
  },
  body: JSON.stringify({
    userSessionId: localStorage.getItem('chatSessionId') || generateSessionId(),
    // Інші поля опціональні
  })
});

const data = await response.json();
if (data.success) {
  // Зберігаємо sessionId
  localStorage.setItem('chatSessionId', data.data.sessionId);
  localStorage.setItem('chatUserSessionId', data.data.sessionId); // для пошуку
}
```

---

### 2. Відправити повідомлення

#### Endpoint
```
POST /api/public/chat/sessions/:sessionId/messages
```

#### Request Body
```json
{
  "message": "Текст повідомлення" (обов'язково)
}
```

#### Response
```json
{
  "success": true,
  "data": {
    "message": {
      "id": "uuid",
      "sender": "user",
      "messageText": "Текст повідомлення",
      "createdAt": "2024-01-20T10:30:00.000Z"
    }
  }
}
```

#### Використання
```javascript
const sessionId = localStorage.getItem('chatSessionId');

await fetch(`https://api.propart.ae/api/public/chat/sessions/${sessionId}/messages`, {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'X-API-Key': 'ваш-api-ключ',
    'X-API-Secret': 'ваш-api-secret'
  },
  body: JSON.stringify({
    message: 'Текст повідомлення'
  })
});
```

---

### 3. Отримати нові повідомлення (Polling)

#### Endpoint
```
GET /api/public/chat/sessions/:sessionId/messages?since=2024-01-20T10:30:00.000Z
```

#### Query Parameters
- `since` (опціонально) - ISO timestamp. Повертає тільки повідомлення, створені після цієї дати.

#### Response
```json
{
  "success": true,
  "data": {
    "messages": [
      {
        "id": "uuid",
        "sender": "manager",
        "messageText": "Відповідь менеджера",
        "createdAt": "2024-01-20T10:35:00.000Z"
      }
    ]
  }
}
```

#### Використання (Polling)
```javascript
// Запустити polling кожні 2-3 секунди
let lastMessageTime = new Date().toISOString();

const pollMessages = async () => {
  const sessionId = localStorage.getItem('chatSessionId');
  
  const response = await fetch(
    `https://api.propart.ae/api/public/chat/sessions/${sessionId}/messages?since=${lastMessageTime}`,
    {
      headers: {
        'X-API-Key': 'ваш-api-ключ',
        'X-API-Secret': 'ваш-api-secret'
      }
    }
  );
  
  const data = await response.json();
  
  if (data.success && data.data.messages.length > 0) {
    // Додати нові повідомлення до UI
    data.data.messages.forEach(msg => {
      addMessageToUI(msg);
    });
    
    // Оновити lastMessageTime
    lastMessageTime = data.data.messages[data.data.messages.length - 1].createdAt;
  }
};

// Запускати кожні 2 секунди
const pollingInterval = setInterval(pollMessages, 2000);

// При закритті чату зупинити polling
// clearInterval(pollingInterval);
```

---

### 4. Legacy Endpoint (для сумісності)

#### Endpoint
```
POST /api/public/chat/notify
```

#### Request Body
```json
{
  "name": "Ім'я" (опціонально),
  "phone": "+380..." (опціонально),
  "message": "Текст повідомлення" (обов'язково),
  "timestamp": "2024-01-20T10:30:00.000Z" (опціонально)
}
```

Цей endpoint автоматично створює/шукає сесію та зберігає повідомлення в БД.

---

## 🔄 Оновлена логіка ChatWidget

### Потік роботи

1. **При відкритті чату:**
   - Перевіряємо `localStorage.getItem('chatSessionId')`
   - Якщо немає - генеруємо унікальний `userSessionId`
   - Викликаємо `POST /api/public/chat/sessions` з `userSessionId`
   - Зберігаємо `sessionId` в localStorage
   - Завантажуємо історію повідомлень

2. **При відправці першого повідомлення:**
   - Якщо ще немає сесії - створюємо через `POST /api/public/chat/sessions` з `firstMessage`
   - Якщо сесія вже є - відправляємо через `POST /api/public/chat/sessions/:id/messages`

3. **При зборі контактних даних:**
   - Оновлюємо сесію через `POST /api/public/chat/sessions` з `name` та `phone`
   - Відправляємо повідомлення про контактні дані

4. **Polling для нових повідомлень:**
   - Запускаємо polling кожні 2-3 секунди
   - Викликаємо `GET /api/public/chat/sessions/:id/messages?since=...`
   - Оновлюємо UI при отриманні нових повідомлень

### Приклад оновленого ChatWidget

```typescript
'use client'
import { useState, useEffect, useRef } from 'react'

const API_BASE_URL = 'https://api.propart.ae/api/public/chat'
const API_KEY = 'ваш-api-ключ'
const API_SECRET = 'ваш-api-secret'

function ChatWidget() {
  const [sessionId, setSessionId] = useState<string | null>(null)
  const [userSessionId, setUserSessionId] = useState<string | null>(null)
  const [messages, setMessages] = useState<any[]>([])
  const [isOpen, setIsOpen] = useState(false)
  const [showContactForm, setShowContactForm] = useState(false)
  const [userInfo, setUserInfo] = useState<{ name: string; phone: string } | null>(null)
  const [inputValue, setInputValue] = useState('')
  const [formData, setFormData] = useState({ name: '', phone: '' })
  const lastMessageTimeRef = useRef<string | null>(null)
  const pollingIntervalRef = useRef<NodeJS.Timeout | null>(null)

  // Генеруємо унікальний userSessionId
  const generateUserSessionId = () => {
    return `user_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`
  }

  // Ініціалізація сесії
  const initializeSession = async () => {
    let storedSessionId = localStorage.getItem('chatSessionId')
    let storedUserSessionId = localStorage.getItem('chatUserSessionId') || generateUserSessionId()

    try {
      const response = await fetch(`${API_BASE_URL}/sessions`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': API_KEY,
          'X-API-Secret': API_SECRET,
        },
        body: JSON.stringify({
          userSessionId: storedUserSessionId,
        }),
      })

      const data = await response.json()
      if (data.success) {
        setSessionId(data.data.sessionId)
        setUserSessionId(storedUserSessionId)
        localStorage.setItem('chatSessionId', data.data.sessionId)
        localStorage.setItem('chatUserSessionId', storedUserSessionId)
        
        // Завантажуємо історію повідомлень
        if (data.data.messages && data.data.messages.length > 0) {
          setMessages(data.data.messages)
          lastMessageTimeRef.current = data.data.messages[data.data.messages.length - 1].createdAt
        }
      }
    } catch (error) {
      console.error('Error initializing session:', error)
    }
  }

  // Відправка повідомлення
  const sendMessage = async (text: string) => {
    if (!sessionId) {
      // Створюємо сесію з першим повідомленням
      const userSessionId = localStorage.getItem('chatUserSessionId') || generateUserSessionId()
      
      const response = await fetch(`${API_BASE_URL}/sessions`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': API_KEY,
          'X-API-Secret': API_SECRET,
        },
        body: JSON.stringify({
          userSessionId,
          firstMessage: text,
        }),
      })

      const data = await response.json()
      if (data.success) {
        setSessionId(data.data.sessionId)
        localStorage.setItem('chatSessionId', data.data.sessionId)
        localStorage.setItem('chatUserSessionId', userSessionId)
        setMessages(data.data.messages || [])
        if (data.data.messages && data.data.messages.length > 0) {
          lastMessageTimeRef.current = data.data.messages[data.data.messages.length - 1].createdAt
        }
        
        // Показуємо форму контактів через 1 секунду
        setTimeout(() => {
          setShowContactForm(true)
        }, 1000)
        
        // Автоматична відповідь бота
        setTimeout(() => {
          setMessages(prev => [...prev, {
            id: Date.now().toString(),
            sender: 'bot',
            messageText: 'Thank you for your message! To continue, please provide your contact details.',
            createdAt: new Date().toISOString(),
          }])
        }, 1000)
      }
    } else {
      // Відправляємо повідомлення
      const response = await fetch(`${API_BASE_URL}/sessions/${sessionId}/messages`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': API_KEY,
          'X-API-Secret': API_SECRET,
        },
        body: JSON.stringify({
          message: text,
        }),
      })

      const data = await response.json()
      if (data.success) {
        setMessages(prev => [...prev, data.data.message])
        lastMessageTimeRef.current = data.data.message.createdAt
        
        // Автоматична відповідь бота
        setTimeout(() => {
          setMessages(prev => [...prev, {
            id: Date.now().toString(),
            sender: 'bot',
            messageText: 'Thank you for your message! Our team will get back to you shortly.',
            createdAt: new Date().toISOString(),
          }])
        }, 1000)
      }
    }
  }

  // Відправка контактних даних
  const submitContactForm = async () => {
    if (!formData.name || !formData.phone) return

    const userSessionId = localStorage.getItem('chatUserSessionId') || generateUserSessionId()
    
    const response = await fetch(`${API_BASE_URL}/sessions`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-API-Key': API_KEY,
        'X-API-Secret': API_SECRET,
      },
      body: JSON.stringify({
        name: formData.name,
        phone: formData.phone,
        userSessionId,
      }),
    })

    const data = await response.json()
    if (data.success) {
      setUserInfo({ name: formData.name, phone: formData.phone })
      setShowContactForm(false)
      setSessionId(data.data.sessionId)
      localStorage.setItem('chatSessionId', data.data.sessionId)
      
      // Відправляємо повідомлення про контактні дані
      await sendMessage('Користувач залишив контактні дані')
      
      // Автоматична відповідь бота
      setTimeout(() => {
        setMessages(prev => [...prev, {
          id: Date.now().toString(),
          sender: 'bot',
          messageText: 'Thank you for providing your contact details! Our manager is connecting to the chat...',
          createdAt: new Date().toISOString(),
        }])
      }, 500)
    }
  }

  // Polling для нових повідомлень від менеджера
  const pollNewMessages = async () => {
    if (!sessionId) return

    const since = lastMessageTimeRef.current || new Date().toISOString()
    
    try {
      const response = await fetch(
        `${API_BASE_URL}/sessions/${sessionId}/messages?since=${since}`,
        {
          headers: {
            'X-API-Key': API_KEY,
            'X-API-Secret': API_SECRET,
          },
        }
      )

      const data = await response.json()
      if (data.success && data.data.messages.length > 0) {
        setMessages(prev => {
          const existingIds = new Set(prev.map(m => m.id))
          const newMessages = data.data.messages.filter((m: any) => !existingIds.has(m.id))
          
          if (newMessages.length > 0) {
            lastMessageTimeRef.current = newMessages[newMessages.length - 1].createdAt
            return [...prev, ...newMessages].sort((a, b) => 
              new Date(a.createdAt).getTime() - new Date(b.createdAt).getTime()
            )
          }
          
          return prev
        })
      }
    } catch (error) {
      console.error('Error polling messages:', error)
    }
  }

  // Ініціалізація при відкритті
  useEffect(() => {
    if (isOpen && !sessionId) {
      initializeSession()
    }
  }, [isOpen])

  // Запуск polling при наявності сесії
  useEffect(() => {
    if (sessionId && isOpen) {
      pollingIntervalRef.current = setInterval(pollNewMessages, 2000)
      return () => {
        if (pollingIntervalRef.current) {
          clearInterval(pollingIntervalRef.current)
        }
      }
    }
  }, [sessionId, isOpen])

  // Відновлення сесії при завантаженні
  useEffect(() => {
    const storedSessionId = localStorage.getItem('chatSessionId')
    if (storedSessionId) {
      setSessionId(storedSessionId)
      // Завантажуємо повідомлення
      fetch(`${API_BASE_URL}/sessions/${storedSessionId}/messages`, {
        headers: {
          'X-API-Key': API_KEY,
          'X-API-Secret': API_SECRET,
        },
      })
        .then(res => res.json())
        .then(data => {
          if (data.success) {
            setMessages(data.data.messages)
            if (data.data.messages.length > 0) {
              lastMessageTimeRef.current = data.data.messages[data.data.messages.length - 1].createdAt
            }
          }
        })
        .catch(console.error)
    }
  }, [])

  // ... решта UI компонента
}
```

---

## 📋 Повна структура відповідей

### ChatSession
```typescript
interface ChatSession {
  id: string
  userName: string | null
  userPhone: string | null
  status: 'active' | 'closed' | 'archived'
  managerId: string | null
  userSessionId: string | null
  createdAt: string
  updatedAt: string
}
```

### ChatMessage
```typescript
interface ChatMessage {
  id: string
  sender: 'user' | 'manager'
  messageText: string
  managerId: string | null
  createdAt: string
}
```

---

## ⚠️ Важливі моменти

1. **userSessionId** - Унікальний ID для ідентифікації користувача (генерується на клієнті, зберігається в localStorage)
2. **sessionId** - ID сесії в БД (отримується з API, зберігається в localStorage)
3. **Polling** - Рекомендується інтервал 2-3 секунди
4. **Автоматичні відповіді бота** - Можна залишити на фронтенді або перенести на бекенд
5. **Відновлення сесії** - При завантаженні сторінки перевіряти localStorage та завантажувати історію

---

## 🔄 Потік даних

```
Користувач на сайті
    ↓
ChatWidget (React)
    ↓
POST /api/public/chat/sessions (створення/отримання сесії)
    ↓
БД (chat_sessions, chat_messages)
    ↓
POST /api/public/chat/sessions/:id/messages (відправка повідомлення)
    ↓
GET /api/public/chat/sessions/:id/messages?since=... (polling)
    ↓
Оновлення UI з новими повідомленнями від менеджера
```

---

## 📱 Приклад повної інтеграції

Дивіться файл `API_CHAT_FRONTEND.md` для детального прикладу оновленого `ChatWidget`.

