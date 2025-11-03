#!/bin/bash

# Просто перезапуск backend без очищення БД
# ВИКОРИСТОВУЙТЕ ЦЕЙ СКРИПТ НА СЕРВЕРІ!

set -e

PROJECT_DIR="/opt/admin-panel"

if [ ! -d "${PROJECT_DIR}" ]; then
    echo "❌ Помилка: Цей скрипт має виконуватися на сервері!"
    exit 1
fi

cd ${PROJECT_DIR}

DB_CONTAINER="for-you-admin-panel-postgres-prod"
BACKEND_CONTAINER="for-you-admin-panel-backend-prod"
NETWORK="for-you-network"

echo "🔄 Перезапуск backend..."
echo ""

# Перевірка чи існує БД контейнер
if ! docker ps --format "{{.Names}}" | grep -q "^${DB_CONTAINER}$"; then
    echo "❌ БД контейнер не запущений!"
    exit 1
fi

echo "✅ БД контейнер запущений"

# Видалення старого backend
if docker ps -a --format "{{.Names}}" | grep -q "^${BACKEND_CONTAINER}$"; then
    echo "🛑 Зупинка та видалення старого backend..."
    docker stop ${BACKEND_CONTAINER} 2>/dev/null || true
    docker rm -f ${BACKEND_CONTAINER} 2>/dev/null || true
    docker-compose -f docker-compose.prod.yml rm -f admin-panel-backend 2>/dev/null || true
fi

echo ""
echo "🔄 Оновлення коду з Git..."
git pull origin main

echo ""
echo "🏗️  Перебудова backend..."
docker-compose -f docker-compose.prod.yml build --no-cache admin-panel-backend

echo ""
echo "🚀 Запуск backend через docker run..."

# Читаємо конфігурацію
DB_PASSWORD=$(grep "DB_PASSWORD" .env 2>/dev/null | cut -d '=' -f2 || echo "admin123")

# Створюємо мережу якщо не існує
docker network create ${NETWORK} 2>/dev/null || true

# Запускаємо backend
docker run -d \
  --name ${BACKEND_CONTAINER} \
  --restart unless-stopped \
  -p 127.0.0.1:4000:4000 \
  --network ${NETWORK} \
  -e NODE_ENV=production \
  -e DATABASE_URL="postgresql://admin:${DB_PASSWORD}@${DB_CONTAINER}:5432/admin_panel" \
  -v ${PROJECT_DIR}/admin-panel-backend/uploads:/app/uploads \
  --env-file ${PROJECT_DIR}/admin-panel-backend/.env \
  admin-panel_admin-panel-backend:latest

echo ""
echo "⏳ Очікуємо запуск backend (20 секунд)..."
sleep 20

echo ""
echo "📋 Логи backend:"
docker logs --tail 30 ${BACKEND_CONTAINER} 2>&1
echo ""

echo "🔍 Health check:"
curl -s http://localhost:4000/health 2>&1
echo ""
echo ""

echo "✅ Готово!"

