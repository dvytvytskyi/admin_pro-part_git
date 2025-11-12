# Чеклист запуску проекту

## ✅ Що вже зроблено:
- [x] Скопійовано проект
- [x] Запущено БД (`docker-compose up -d admin-panel-db`)
- [x] Виконано міграції (`npm run migration:run`)
- [x] Імпортовано дані (`npm run import:exported-offplan`)

## 📋 Наступні кроки:

### Крок 1: Налаштування Backend

#### 1.1. Перевірити .env файл backend
```bash
cd /Users/vytvytskyi/admin_pro-part/admin-panel-backend
cat .env
```

Має містити:
```env
DATABASE_URL=postgresql://admin:admin123@localhost:5436/admin_panel
PORT=4000
JWT_SECRET=your_secret_here
NODE_ENV=development
```

**Якщо .env не існує або неповний:**
```bash
# Скопіювати з .env.example
cp .env.example .env

# Або створити вручну
nano .env
```

#### 1.2. Встановити залежності backend
```bash
cd /Users/vytvytskyi/admin_pro-part/admin-panel-backend
npm install
```

#### 1.3. Запустити backend
```bash
npm run dev
```

Backend має запуститися на `http://localhost:4000`

**Перевірити:**
- Відкрити `http://localhost:4000/api/public/data` (має повернути дані)
- Або перевірити логи - має бути `Server is running on port 4000`

---

### Крок 2: Налаштування Frontend

#### 2.1. Створити .env.local файл для frontend
```bash
cd /Users/vytvytskyi/admin_pro-part/admin-panel
```

Створити файл `.env.local`:
```env
NEXT_PUBLIC_API_URL=http://localhost:4000/api
NEXTAUTH_URL=http://localhost:3001
NEXTAUTH_SECRET=your_nextauth_secret_here
```

**Створити файл:**
```bash
cat > .env.local << EOF
NEXT_PUBLIC_API_URL=http://localhost:4000/api
NEXTAUTH_URL=http://localhost:3001
NEXTAUTH_SECRET=$(openssl rand -base64 32)
EOF
```

#### 2.2. Встановити залежності frontend
```bash
cd /Users/vytvytskyi/admin_pro-part/admin-panel
npm install
```

#### 2.3. Запустити frontend
```bash
npm run dev
```

Frontend має запуститися на `http://localhost:3001`

---

### Крок 3: Перевірка роботи

#### 3.1. Перевірити Backend API
```bash
# Перевірити публічний endpoint
curl http://localhost:4000/api/public/data

# Або відкрити в браузері
open http://localhost:4000/api/public/data
```

#### 3.2. Перевірити Frontend
- Відкрити `http://localhost:3001` в браузері
- Має відкритися сторінка логіну або dashboard

#### 3.3. Створити користувача (якщо потрібно)
Якщо немає користувача для входу, можна:
- Використати існуючого користувача зі старої БД (якщо імпортували)
- Або створити нового через API або скрипт

---

### Крок 4: Адаптація під новий проект (опціонально)

#### 4.1. Оновити назви в package.json
**Frontend:**
```bash
cd /Users/vytvytskyi/admin_pro-part/admin-panel
```

Змінити в `package.json`:
- `"name": "for-you-real-estate-admin"` → `"name": "admin-pro-part-panel"`
- `"description": "Веб-панель адміністратора For You Real Estate"` → `"description": "Веб-панель адміністратора нового проекту"`

#### 4.2. Оновити метадані в layout.tsx
**Файл:** `admin-panel/src/app/layout.tsx`

Змінити:
```typescript
export const metadata: Metadata = {
  title: 'Новий Проект - Адмін Панель',
  description: 'Панель адміністратора для управління новим проектом',
}
```

---

## 🚀 Швидкий старт (всі команди разом)

```bash
# 1. Backend
cd /Users/vytvytskyi/admin_pro-part/admin-panel-backend
npm install
npm run dev

# 2. Frontend (в новому терміналі)
cd /Users/vytvytskyi/admin_pro-part/admin-panel
# Створити .env.local (див. вище)
npm install
npm run dev
```

---

## ⚠️ Можливі проблеми та рішення

### Проблема: Backend не підключається до БД
**Рішення:**
- Перевірити, що БД запущена: `docker ps | grep admin-pro-part-postgres`
- Перевірити `DATABASE_URL` в `.env` (порт має бути 5436)
- Перевірити, що БД приймає з'єднання: `docker exec admin-pro-part-postgres psql -U admin -d admin_panel -c "SELECT 1;"`

### Проблема: Frontend не підключається до Backend
**Рішення:**
- Перевірити `NEXT_PUBLIC_API_URL` в `.env.local`
- Перевірити, що backend запущений на порту 4000
- Перевірити CORS налаштування в backend

### Проблема: Помилки при npm install
**Рішення:**
- Видалити `node_modules` та `package-lock.json`
- Запустити `npm install` знову
- Перевірити версію Node.js (має бути 18+)

---

## 📝 Нотатки

- Backend працює на порту **4000**
- Frontend працює на порту **3001**
- БД працює на порту **5436**
- Всі дані вже імпортовані (1455 off-plan properties)

---

## ✅ Фінальна перевірка

Після запуску перевірити:
- [ ] Backend запущений (`http://localhost:4000`)
- [ ] Frontend запущений (`http://localhost:3001`)
- [ ] API відповідає (`http://localhost:4000/api/public/data`)
- [ ] Можна зайти в адмін панель
- [ ] Properties відображаються на фронті

