#!/bin/bash

# Скрипт для виправлення проблеми з API URL у frontend

set -e

PROJECT_DIR="/opt/admin-panel"
DOMAIN="admin.foryou-realestate.com"

echo "🔍 Діагностика проблеми з API URL..."
echo ""

# Перевірка статусу контейнерів
echo "📊 Статус контейнерів:"
docker-compose -f ${PROJECT_DIR}/docker-compose.prod.yml ps
echo ""

# Перевірка .env.production
echo "📝 Перевірка .env.production:"
if [ -f "${PROJECT_DIR}/admin-panel/.env.production" ]; then
    cat ${PROJECT_DIR}/admin-panel/.env.production
else
    echo "❌ Файл .env.production не знайдено!"
fi
echo ""

# Перевірка чи працює backend
echo "🔍 Перевірка backend API:"
curl -s http://localhost:4000/api/health || echo "❌ Backend не відповідає на localhost:4000"
echo ""

# Перевірка чи працює frontend
echo "🔍 Перевірка frontend:"
curl -s -I http://localhost:3001 | head -1 || echo "❌ Frontend не відповідає на localhost:3001"
echo ""

# Виправлення .env.production
echo "🔧 Виправлення .env.production..."
cat > ${PROJECT_DIR}/admin-panel/.env.production << EOF
NEXT_PUBLIC_API_URL=https://${DOMAIN}/api
EOF

echo "✅ .env.production оновлено:"
cat ${PROJECT_DIR}/admin-panel/.env.production
echo ""

# Перебілд frontend
echo "🔨 Перебілд frontend контейнера з правильним API URL..."
cd ${PROJECT_DIR}
docker-compose -f docker-compose.prod.yml stop admin-panel-frontend
docker-compose -f docker-compose.prod.yml rm -f admin-panel-frontend
docker-compose -f docker-compose.prod.yml build --no-cache admin-panel-frontend
docker-compose -f docker-compose.prod.yml up -d admin-panel-frontend

echo "⏳ Очікування запуску frontend (10 секунд)..."
sleep 10

echo ""
echo "📊 Фінальний статус контейнерів:"
docker-compose -f ${PROJECT_DIR}/docker-compose.prod.yml ps

echo ""
echo "✅ Готово! Тепер frontend має використовувати правильний API URL: https://${DOMAIN}/api"
echo "🌐 Відкрийте в браузері: https://${DOMAIN}"

