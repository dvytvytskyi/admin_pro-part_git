# Приклад оновленого ChatWidget для фронтенду

## Повний код оновленого компонента

```typescript
'use client'
import { useState, useEffect, useRef } from 'react'
import styles from './ChatWidget.module.css'

const API_BASE_URL = 'https://api.propart.ae/api/public/chat'
const API_KEY = 'ваш-api-ключ' // Винести в env
const API_SECRET = 'ваш-api-secret' // Винести в env

interface Message {
  id: string
  sender: 'user' | 'manager' | 'bot'
  messageText: string
  createdAt: string
}

export default function ChatWidget() {
  const [isOpen, setIsOpen] = useState(false)
  const [sessionId, setSessionId] = useState<string | null>(null)
  const [userSessionId, setUserSessionId] = useState<string | null>(null)
  const [userInfo, setUserInfo] = useState<{ name: string; phone: string } | null>(null)
  const [showContactForm, setShowContactForm] = useState(false)
  const [messages, setMessages] = useState<Message[]>([])
  const [inputValue, setInputValue] = useState('')
  const [formData, setFormData] = useState({ name: '', phone: '' })
  const [loading, setLoading] = useState(false)
  
  const lastMessageTimeRef = useRef<string | null>(null)
  const pollingIntervalRef = useRef<NodeJS.Timeout | null>(null)

  // Генеруємо унікальний userSessionId
  const generateUserSessionId = () => {
    return `user_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`
  }

  // Ініціалізація сесії
  const initializeSession = async () => {
    try {
      setLoading(true)
      let storedUserSessionId = localStorage.getItem('chatUserSessionId') || generateUserSessionId()
      
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
          setMessages(data.data.messages.map((msg: any) => ({
            ...msg,
            sender: msg.sender === 'manager' ? 'manager' : 'user',
          })))
          lastMessageTimeRef.current = data.data.messages[data.data.messages.length - 1].createdAt
        } else {
          // Додаємо привітальне повідомлення
          setMessages([{
            id: 'welcome',
            sender: 'bot',
            messageText: 'Hello! How can I help you today?',
            createdAt: new Date().toISOString(),
          }])
        }

        // Перевіряємо, чи є дані користувача
        if (data.data.session.userName && data.data.session.userPhone) {
          setUserInfo({
            name: data.data.session.userName,
            phone: data.data.session.userPhone,
          })
        }
      }
    } catch (error) {
      console.error('Error initializing session:', error)
    } finally {
      setLoading(false)
    }
  }

  // Відправка повідомлення
  const sendMessage = async (text: string) => {
    if (!text.trim()) return

    // Додаємо повідомлення в UI одразу
    const tempMessage: Message = {
      id: `temp_${Date.now()}`,
      sender: 'user',
      messageText: text,
      createdAt: new Date().toISOString(),
    }
    setMessages(prev => [...prev, tempMessage])
    setInputValue('')

    if (!sessionId) {
      // Створюємо сесію з першим повідомленням
      const userSessionId = localStorage.getItem('chatUserSessionId') || generateUserSessionId()
      
      try {
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
          
          // Оновлюємо повідомлення (замінюємо temp на реальне)
          setMessages(prev => {
            const filtered = prev.filter(m => m.id !== tempMessage.id)
            return [...filtered, ...data.data.messages].sort((a, b) => 
              new Date(a.createdAt).getTime() - new Date(b.createdAt).getTime()
            )
          })
          
          lastMessageTimeRef.current = data.data.messages[data.data.messages.length - 1].createdAt
          
          // Показуємо форму контактів через 1 секунду
          setTimeout(() => {
            setShowContactForm(true)
            setMessages(prev => [...prev, {
              id: `bot_${Date.now()}`,
              sender: 'bot',
              messageText: 'Thank you for your message! To continue, please provide your contact details.',
              createdAt: new Date().toISOString(),
            }])
          }, 1000)
        }
      } catch (error) {
        console.error('Error creating session:', error)
        // Видаляємо temp повідомлення при помилці
        setMessages(prev => prev.filter(m => m.id !== tempMessage.id))
      }
    } else {
      // Відправляємо повідомлення
      try {
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
          // Оновлюємо temp повідомлення на реальне
          setMessages(prev => {
            const filtered = prev.filter(m => m.id !== tempMessage.id)
            return [...filtered, data.data.message].sort((a, b) => 
              new Date(a.createdAt).getTime() - new Date(b.createdAt).getTime()
            )
          })
          lastMessageTimeRef.current = data.data.message.createdAt
          
          // Автоматична відповідь бота (якщо немає контактів)
          if (!userInfo) {
            setTimeout(() => {
              setMessages(prev => [...prev, {
                id: `bot_${Date.now()}`,
                sender: 'bot',
                messageText: 'Thank you for your message! Our team will get back to you shortly.',
                createdAt: new Date().toISOString(),
              }])
            }, 1000)
          }
        }
      } catch (error) {
        console.error('Error sending message:', error)
        // Видаляємо temp повідомлення при помилці
        setMessages(prev => prev.filter(m => m.id !== tempMessage.id))
      }
    }
  }

  // Відправка контактних даних
  const submitContactForm = async () => {
    if (!formData.name.trim() || !formData.phone.trim()) return

    const userSessionId = localStorage.getItem('chatUserSessionId') || generateUserSessionId()
    
    try {
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
        localStorage.setItem('chatUserSessionId', userSessionId)
        
        // Відправляємо повідомлення про контактні дані
        await sendMessage('Користувач залишив контактні дані')
        
        // Автоматична відповідь бота
        setTimeout(() => {
          setMessages(prev => [...prev, {
            id: `bot_${Date.now()}`,
            sender: 'bot',
            messageText: 'Thank you for providing your contact details! Our manager is connecting to the chat...',
            createdAt: new Date().toISOString(),
          }])
        }, 500)
      }
    } catch (error) {
      console.error('Error submitting contact form:', error)
    }
  }

  // Polling для нових повідомлень від менеджера
  const pollNewMessages = async () => {
    if (!sessionId || !isOpen) return

    const since = lastMessageTimeRef.current || new Date(Date.now() - 60000).toISOString()
    
    try {
      const response = await fetch(
        `${API_BASE_URL}/sessions/${sessionId}/messages?since=${encodeURIComponent(since)}`,
        {
          headers: {
            'X-API-Key': API_KEY,
            'X-API-Secret': API_SECRET,
          },
        }
      )

      const data = await response.json()
      if (data.success && data.data.messages && data.data.messages.length > 0) {
        setMessages(prev => {
          const existingIds = new Set(prev.map(m => m.id))
          const newMessages = data.data.messages
            .filter((m: any) => !existingIds.has(m.id))
            .map((m: any) => ({
              ...m,
              sender: m.sender === 'manager' ? 'manager' : 'user',
            }))
          
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

  // Відкриття чату
  const handleOpen = () => {
    setIsOpen(true)
    if (!sessionId) {
      initializeSession()
    }
  }

  // Ініціалізація при завантаженні
  useEffect(() => {
    const storedSessionId = localStorage.getItem('chatSessionId')
    const storedUserSessionId = localStorage.getItem('chatUserSessionId')
    
    if (storedSessionId && storedUserSessionId) {
      setSessionId(storedSessionId)
      setUserSessionId(storedUserSessionId)
      
      // Завантажуємо повідомлення
      fetch(`${API_BASE_URL}/sessions/${storedSessionId}/messages`, {
        headers: {
          'X-API-Key': API_KEY,
          'X-API-Secret': API_SECRET,
        },
      })
        .then(res => res.json())
        .then(data => {
          if (data.success && data.data.messages) {
            setMessages(data.data.messages.map((msg: any) => ({
              ...msg,
              sender: msg.sender === 'manager' ? 'manager' : 'user',
            })))
            if (data.data.messages.length > 0) {
              lastMessageTimeRef.current = data.data.messages[data.data.messages.length - 1].createdAt
            }
          }
        })
        .catch(console.error)
    }
  }, [])

  // Запуск polling при наявності сесії та відкритому чаті
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

  return (
    <>
      {/* Chat Button */}
      {!isOpen && (
        <button
          onClick={handleOpen}
          className={styles.chatButton}
          aria-label="Open chat"
        >
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
            <path
              d="M20 2H4C2.9 2 2 2.9 2 4V22L6 18H20C21.1 18 22 17.1 22 16V4C22 2.9 21.1 2 20 2Z"
              fill="currentColor"
            />
          </svg>
        </button>
      )}

      {/* Chat Window */}
      {isOpen && (
        <div className={styles.chatWindow}>
          {/* Header */}
          <div className={styles.chatHeader}>
            <h3>Chat Support</h3>
            <button
              onClick={() => setIsOpen(false)}
              className={styles.closeButton}
              aria-label="Close chat"
            >
              ×
            </button>
          </div>

          {/* Messages */}
          <div className={styles.messagesContainer}>
            {messages.map((message) => (
              <div
                key={message.id}
                className={`${styles.message} ${
                  message.sender === 'user' ? styles.userMessage : 
                  message.sender === 'manager' ? styles.managerMessage : 
                  styles.botMessage
                }`}
              >
                <div className={styles.messageText}>{message.messageText}</div>
                <div className={styles.messageTime}>
                  {new Date(message.createdAt).toLocaleTimeString('uk-UA', {
                    hour: '2-digit',
                    minute: '2-digit',
                  })}
                </div>
              </div>
            ))}
          </div>

          {/* Contact Form */}
          {showContactForm && !userInfo && (
            <div className={styles.contactForm}>
              <h4>Contact Information</h4>
              <input
                type="text"
                placeholder="Your name"
                value={formData.name}
                onChange={(e) => setFormData(prev => ({ ...prev, name: e.target.value }))}
                className={styles.formInput}
              />
              <input
                type="tel"
                placeholder="Your phone"
                value={formData.phone}
                onChange={(e) => setFormData(prev => ({ ...prev, phone: e.target.value }))}
                className={styles.formInput}
              />
              <button
                onClick={submitContactForm}
                disabled={!formData.name.trim() || !formData.phone.trim()}
                className={styles.submitButton}
              >
                Submit
              </button>
            </div>
          )}

          {/* Input */}
          {!showContactForm && (
            <div className={styles.inputContainer}>
              <input
                type="text"
                value={inputValue}
                onChange={(e) => setInputValue(e.target.value)}
                onKeyDown={(e) => {
                  if (e.key === 'Enter' && !e.shiftKey) {
                    e.preventDefault()
                    sendMessage(inputValue)
                  }
                }}
                placeholder="Type a message..."
                className={styles.messageInput}
                disabled={loading}
              />
              <button
                onClick={() => sendMessage(inputValue)}
                disabled={!inputValue.trim() || loading}
                className={styles.sendButton}
              >
                Send
              </button>
            </div>
          )}
        </div>
      )}
    </>
  )
}
```

---

## Основні зміни

1. **Збереження сесії в localStorage**
   - `chatSessionId` - ID сесії в БД
   - `chatUserSessionId` - Унікальний ID користувача

2. **Polling для нових повідомлень**
   - Кожні 2 секунди перевіряємо нові повідомлення від менеджера
   - Використовуємо параметр `since` для отримання тільки нових повідомлень

3. **Відновлення сесії при завантаженні**
   - При завантаженні сторінки перевіряємо localStorage
   - Завантажуємо історію повідомлень

4. **Створення/Оновлення сесії**
   - При першому повідомленні створюємо сесію
   - При наданні контактних даних оновлюємо сесію

---

## API Endpoints для фронтенду

### 1. Створити/Отримати сесію
```
POST /api/public/chat/sessions
Headers: X-API-Key, X-API-Secret
Body: { userSessionId?, name?, phone?, firstMessage? }
```

### 2. Відправити повідомлення
```
POST /api/public/chat/sessions/:sessionId/messages
Headers: X-API-Key, X-API-Secret
Body: { message }
```

### 3. Отримати нові повідомлення (Polling)
```
GET /api/public/chat/sessions/:sessionId/messages?since=ISO_TIMESTAMP
Headers: X-API-Key, X-API-Secret
```

---

## Важливо

1. **API ключі** - Винести в `.env.local`
2. **Polling** - Запускати тільки коли чат відкритий
3. **localStorage** - Використовувати для збереження сесії
4. **Очищення** - При закритті сесії можна очистити localStorage

