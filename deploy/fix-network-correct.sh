#!/bin/bash

# Правильне отримання network та запуск бекенду

set -e

echo "🔧 Виправлення network бекенду..."
echo ""

cd /opt/admin-pro-part

# 1. Знайти контейнер БД
DB_CONTAINER=$(docker ps | grep postgres | grep pro-part | awk '{print $1}' | head -1)
echo "✅ Контейнер БД: $DB_CONTAINER"

# 2. Правильне отримання network
DB_NETWORK=$(docker inspect $DB_CONTAINER --format='{{range $k, $v := .NetworkSettings.Networks}}{{$k}}{{end}}')
echo "✅ Network БД: $DB_NETWORK"

# 3. Якщо network не знайдено, спробувати знайти через docker-compose
if [ -z "$DB_NETWORK" ] || [ "$DB_NETWORK" = "Networks" ]; then
    echo "⚠️  Network не знайдено через inspect, шукаємо через docker network ls..."
    DB_NETWORK=$(docker network ls | grep pro-part | awk '{print $1}' | head -1)
    if [ -z "$DB_NETWORK" ]; then
        # Спробувати знайти network через docker-compose
        if [ -f "docker-compose.prod.yml" ]; then
            DB_NETWORK=$(grep -A 5 "networks:" docker-compose.prod.yml | grep -v "^#" | head -1 | awk '{print $1}' | tr -d ':')
        fi
    fi
fi

# 4. Якщо все ще не знайдено, використати default bridge
if [ -z "$DB_NETWORK" ] || [ "$DB_NETWORK" = "Networks" ]; then
    echo "⚠️  Використовуємо bridge network..."
    DB_NETWORK="bridge"
fi

echo "✅ Використовуємо network: $DB_NETWORK"

# 5. Перевірити чи DATABASE_URL правильний
echo ""
echo "📝 Перевірка DATABASE_URL..."
grep DATABASE_URL admin-panel-backend/.env

# 6. Перезапустити бекенд
echo ""
echo "🔄 Перезапуск бекенду..."
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

# 7. Почекати
echo ""
echo "⏳ Очікування запуску (10 секунд)..."
sleep 10

# 8. Перевірити логи
echo ""
echo "📋 Логи бекенду:"
docker logs --tail=30 admin-pro-part-backend

echo ""
echo "✅ Готово!"

