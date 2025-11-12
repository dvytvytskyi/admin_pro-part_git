# ⚡ Швидкий чеклист .env для деплою

## ✅ Що потрібно зробити:

### 1. Створити файл на сервері:
```bash
nano admin-panel-backend/.env
```

### 2. Вставити мінімальний вміст (скопіювати з локального, але змінити):

```env
# БД - замінити на продакшн URL
DATABASE_URL=postgresql://admin:YOUR_PASSWORD@admin-panel-db:5432/admin_panel

# JWT - ОБОВ'ЯЗКОВО змінити!
ADMIN_JWT_SECRET=your_production_secret_min_32_chars

# Admin Login - ОБОВ'ЯЗКОВО змінити!
ADMIN_EMAIL=admin@pro-part.online
ADMIN_PASSWORD=your_secure_admin_password

# Cloudinary (можна залишити як є, якщо той самий акаунт)
CLOUDINARY_CLOUD_NAME=dgv0rxd60
CLOUDINARY_API_KEY=141613625537469
CLOUDINARY_API_SECRET=GgziMAcVfQvOGD44Yj0OlNqitPg

# Сервер
NODE_ENV=production
PORT=4000

# Пароль БД для docker-compose
DB_PASSWORD=your_secure_password
```

### 3. Згенерувати секрети (на сервері):
```bash
# JWT Secret
openssl rand -base64 32

# NextAuth Secret (якщо потрібен frontend .env)
openssl rand -base64 32
```

### 4. Перевірити права:
```bash
chmod 600 admin-panel-backend/.env
```

### 5. Перезапустити:
```bash
docker-compose -f docker-compose.prod.yml restart admin-panel-backend
```

---

## 🔴 ОБОВ'ЯЗКОВО ЗМІНИТИ:

- ✅ `ADMIN_JWT_SECRET` - згенерувати новий
- ✅ `ADMIN_EMAIL` - змінити на свій email
- ✅ `ADMIN_PASSWORD` - змінити на безпечний пароль
- ✅ `DB_PASSWORD` - змінити на безпечний
- ✅ `DATABASE_URL` - перевірити, що правильний

---

## 📝 Якщо помилка "env file not found":

Перевірте:
1. Файл існує: `ls -la admin-panel-backend/.env`
2. Права доступу: `chmod 600 admin-panel-backend/.env`
3. Шлях правильний (в корені проекту, не в підпапці)
4. Docker-compose шукає файл: `docker-compose.prod.yml` має `env_file: - ./admin-panel-backend/.env`

