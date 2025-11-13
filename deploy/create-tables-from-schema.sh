#!/bin/bash

# Створення всіх таблиць на production через тимчасове увімкнення synchronize

set -e

echo "🗄️  Створення всіх таблиць на production..."
echo ""

cd /opt/admin-pro-part

# 1. Тимчасово увімкнути synchronize
echo "📝 Тимчасово увімкнення synchronize для створення таблиць..."
cp admin-panel-backend/src/config/database.ts admin-panel-backend/src/config/database.ts.backup

sed -i 's/synchronize: false/synchronize: true/' admin-panel-backend/src/config/database.ts

# 2. Перебудувати та перезапустити бекенд
echo ""
echo "🔨 Перебудова бекенду..."
docker stop admin-pro-part-backend
docker rm admin-pro-part-backend

cd admin-panel-backend
docker build -t admin-pro-part-backend:latest .
cd ..

docker run -d \
  --name admin-pro-part-backend \
  --network admin-pro-part_admin-pro-part-network \
  --env-file admin-panel-backend/.env \
  -e NODE_ENV=production \
  -p 4001:4000 \
  admin-pro-part-backend:latest

# 3. Почекати поки таблиці створяться
echo ""
echo "⏳ Очікування створення таблиць (20 секунд)..."
sleep 20

# 4. Перевірити логи
echo ""
echo "📋 Логи бекенду:"
docker logs --tail=30 admin-pro-part-backend | grep -E "Table|created|synchronize|error" || docker logs --tail=30 admin-pro-part-backend

# 5. Перевірити таблиці в БД
echo ""
echo "🔍 Перевірка таблиць в БД:"
DB_CONTAINER=$(docker ps | grep postgres | grep pro-part | awk '{print $1}')
docker exec $DB_CONTAINER psql -U admin -d admin_panel_propart -c "\dt" | head -30

# 6. Вимкнути synchronize
echo ""
echo "🔒 Вимкнення synchronize (повернення до безпечного режиму)..."
cp admin-panel-backend/src/config/database.ts.backup admin-panel-backend/src/config/database.ts

# 7. Перебудувати знову
echo ""
echo "🔨 Фінальна перебудова бекенду..."
docker stop admin-pro-part-backend
docker rm admin-pro-part-backend

cd admin-panel-backend
docker build -t admin-pro-part-backend:latest .
cd ..

docker run -d \
  --name admin-pro-part-backend \
  --network admin-pro-part_admin-pro-part-network \
  --env-file admin-panel-backend/.env \
  -e NODE_ENV=production \
  -p 4001:4000 \
  admin-pro-part-backend:latest

echo ""
echo "✅ Готово! Всі таблиці створені"
echo ""
echo "📋 Перевірте дашборд - дані мають відображатися"

