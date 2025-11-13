#!/bin/bash

# Виправлення підключення до БД при використанні host network

set -e

echo "🔧 Виправлення підключення до БД..."
echo ""

cd /opt/admin-pro-part

# 1. Знайти контейнер БД та його порт
echo "🔍 Пошук контейнера БД..."
DB_CONTAINER=$(docker ps | grep -E "postgres|db" | grep pro-part | awk '{print $1}' | head -1)
DB_PORT=$(docker port $DB_CONTAINER 2>/dev/null | grep 5432 | cut -d ':' -f2 | head -1)

if [ -z "$DB_CONTAINER" ]; then
    echo "❌ Контейнер БД не знайдено!"
    echo "   Запущені контейнери:"
    docker ps
    exit 1
fi

echo "   ✅ Контейнер БД: $DB_CONTAINER"
echo "   ✅ Порт БД: ${DB_PORT:-5432}"

# 2. Отримати DATABASE_URL з .env
DB_URL=$(grep DATABASE_URL admin-panel-backend/.env | cut -d '=' -f2)
DB_NAME=$(echo $DB_URL | sed 's/.*@[^/]*\///')
DB_USER=$(echo $DB_URL | sed 's/.*:\/\/\([^:]*\):.*/\1/')
DB_PASS=$(echo $DB_URL | sed 's/.*:\/\/[^:]*:\([^@]*\)@.*/\1/')

echo ""
echo "📋 Поточний DATABASE_URL: $DB_URL"
echo "   База: $DB_NAME"
echo "   Користувач: $DB_USER"

# 3. Створити новий DATABASE_URL з localhost
NEW_DB_URL="postgresql://${DB_USER}:${DB_PASS}@localhost:${DB_PORT:-5432}/${DB_NAME}"
echo ""
echo "📝 Новий DATABASE_URL: $NEW_DB_URL"

# 4. Оновити .env файл
echo ""
echo "💾 Оновлення .env файлу..."
sed -i "s|DATABASE_URL=.*|DATABASE_URL=${NEW_DB_URL}|" admin-panel-backend/.env

# 5. Перезапустити бекенд
echo ""
echo "🔄 Перезапуск бекенду..."
docker stop admin-pro-part-backend 2>/dev/null || true
docker rm admin-pro-part-backend 2>/dev/null || true

cd admin-panel-backend
docker build -t admin-pro-part-backend:latest .
cd ..

docker run -d \
  --name admin-pro-part-backend \
  --network host \
  --env-file admin-panel-backend/.env \
  -e NODE_ENV=production \
  admin-pro-part-backend:latest

# 6. Почекати
echo ""
echo "⏳ Очікування підключення (10 секунд)..."
sleep 10

# 7. Перевірити логи
echo ""
echo "📋 Логи бекенду:"
docker logs --tail=30 admin-pro-part-backend

echo ""
echo "✅ Готово!"

