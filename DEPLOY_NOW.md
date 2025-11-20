# 🚀 Інструкції для деплою змін на production

## Крок 1: Зміни вже закомічені та запушені ✅

Всі зміни вже в репозиторії:
- Система чату (entities, routes, frontend)
- Імпорт новин
- Створення користувача
- Всі оновлення API

## Крок 2: Деплой на сервер

### Варіант 1: Автоматичний деплой (рекомендовано)

```bash
cd /Users/vytvytskyi/admin_pro-part
./deploy/update-production.sh
```

Пароль для сервера: `VandiPCEXeep`

### Варіант 2: Ручний деплой через SSH

```bash
# Підключення до сервера
ssh root@88.99.38.25
# Пароль: VandiPCEXeep

# На сервері:
cd /opt/admin-pro-part
git pull origin main

# Створення таблиць чату
cd admin-panel-backend
docker-compose -f ../docker-compose.prod.yml exec admin-pro-part-backend npm run create:chat-tables

# Імпорт новин
docker-compose -f ../docker-compose.prod.yml exec admin-pro-part-backend npm run import:news-txt

# Створення користувача (якщо потрібно)
docker-compose -f ../docker-compose.prod.yml exec admin-pro-part-backend npm run create:user

# Перезапуск контейнерів
cd ..
docker-compose -f docker-compose.prod.yml up -d --build admin-pro-part-frontend
docker-compose -f docker-compose.prod.yml restart admin-pro-part-backend
```

## Крок 3: Перевірка після деплою

1. **Перевірка backend:**
   ```bash
   curl http://localhost:4001/api/health
   ```

2. **Перевірка frontend:**
   ```bash
   curl http://localhost:3002
   ```

3. **Перевірка таблиць чату:**
   ```bash
   docker-compose -f docker-compose.prod.yml exec admin-pro-part-backend npm run create:chat-tables
   # Має показати "✅ Chat tables created successfully!" або "already exists"
   ```

4. **Перевірка новин:**
   - Відкрити `/news` в адмін панелі
   - Має бути 31 стаття

5. **Перевірка чату:**
   - Відкрити `/chat` в адмін панелі
   - Має відображатися список чатів

## Крок 4: Створення користувача на production (якщо потрібно)

```bash
ssh root@88.99.38.25
cd /opt/admin-pro-part/admin-panel-backend
docker-compose -f ../docker-compose.prod.yml exec admin-pro-part-backend npm run create:user
```

## Дані для входу нового користувача:

**Email:** `anna@propart.ae`  
**Password:** `Anna2025!ProPart`

---

## ⚠️ Важливо

Після деплою обов'язково:
1. Перезапустити frontend (rebuild)
2. Перезапустити backend
3. Створити таблиці чату (якщо ще не створені)
4. Імпортувати новини (якщо ще не імпортовані)

