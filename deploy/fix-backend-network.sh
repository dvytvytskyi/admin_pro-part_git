#!/bin/bash

# Виправлення network бекенду для використання admin-pro-part-db

set -e

echo "🔧 Виправлення network бекенду..."
echo ""

cd /opt/admin-pro-part

# 1. Знайти контейнер БД та його network
DB_CONTAINER=$(docker ps | grep postgres | grep pro-part | awk '{print $1}' | head -1)
echo "✅ Контейнер БД: $DB_CONTAINER"

# 2. Знайти network контейнера БД
DB_NETWORK=$(docker inspect $DB_CONTAINER | grep -A 20 "Networks" | grep -o '"[^"]*":' | head -1 | tr -d '":')
echo "✅ Network БД: $DB_NETWORK"

# 3. Змінити DATABASE_URL назад на admin-pro-part-db
echo ""
echo "📝 Оновлення DATABASE_URL..."
CURRENT_DB_URL=$(grep DATABASE_URL admin-panel-backend/.env | cut -d '=' -f2)
NEW_DB_URL=$(echo $CURRENT_DB_URL | sed 's/@localhost:/@admin-pro-part-db:/')
sed -i "s|DATABASE_URL=.*|DATABASE_URL=${NEW_DB_URL}|" admin-panel-backend/.env
echo "   Новий DATABASE_URL: $NEW_DB_URL"

# 4. Перезапустити бекенд з правильним network
echo ""
echo "🔄 Перезапуск бекенду з network: $DB_NETWORK..."
docker stop admin-pro-part-backend 2>/dev/null || true
docker rm admin-pro-part-backend 2>/dev/null || true

cd admin-panel-backend
docker build -t admin-pro-part-backend:latest .
cd ..

docker run -d \
  --name admin-pro-part-backend \
  --network $DB_NETWORK \
  --env-file admin-panel-backend/.env \
  -e NODE_ENV=production \
  -p 4001:4000 \
  admin-pro-part-backend:latest

# 5. Почекати
echo ""
echo "⏳ Очікування запуску (10 секунд)..."
sleep 10

# 6. Перевірити логи
echo ""
echo "📋 Логи бекенду:"
docker logs --tail=30 admin-pro-part-backend

echo ""
echo "✅ Готово! Спробуйте залогінитися"

