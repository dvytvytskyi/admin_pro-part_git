#!/bin/bash

# Перезапуск бекенду після створення таблиць

set -e

echo "🔄 Перезапуск бекенду..."
echo ""

cd /opt/admin-pro-part

# 1. Знайти контейнер БД та отримати правильний пароль
DB_CONTAINER=$(docker ps | grep postgres | grep pro-part | awk '{print $1}' | head -1)
echo "✅ Контейнер БД: $DB_CONTAINER"

# 2. Перевірити чи БД доступна
echo ""
echo "🔍 Перевірка підключення до БД..."
docker exec $DB_CONTAINER psql -U admin -d admin_panel_propart -c "SELECT 1;" > /dev/null 2>&1 && echo "✅ БД доступна" || echo "❌ БД не доступна"

# 3. Перевірити чи таблиця users існує
echo ""
echo "🔍 Перевірка таблиці users..."
docker exec $DB_CONTAINER psql -U admin -d admin_panel_propart -c "\d users" > /dev/null 2>&1 && echo "✅ Таблиця users існує" || echo "❌ Таблиця users не знайдена"

# 4. Оновити DATABASE_URL на localhost (якщо використовується host network)
# Або залишити admin-pro-part-db якщо використовується docker network
echo ""
echo "📝 Перевірка DATABASE_URL..."
CURRENT_DB_URL=$(grep DATABASE_URL admin-panel-backend/.env | cut -d '=' -f2)
echo "   Поточний: $CURRENT_DB_URL"

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
echo "⏳ Очікування запуску (10 секунд)..."
sleep 10

# 7. Перевірити логи
echo ""
echo "📋 Логи бекенду:"
docker logs --tail=30 admin-pro-part-backend

echo ""
echo "✅ Готово! Спробуйте залогінитися"

