#!/bin/bash

# Виправлення backend з правильними назвами контейнерів та мережі
# ВИКОРИСТОВУЙТЕ ЦЕЙ СКРИПТ НА СЕРВЕРІ!

set -e

PROJECT_DIR="/opt/admin-panel"

if [ ! -d "${PROJECT_DIR}" ]; then
    echo "❌ Помилка: Цей скрипт має виконуватися на сервері!"
    exit 1
fi

cd ${PROJECT_DIR}

# Правильні назви з вашого проекту
DB_CONTAINER="for-you-admin-panel-postgres-prod"
BACKEND_CONTAINER="for-you-admin-panel-backend-prod"
NETWORK="for-you-network"

echo "📦 Використовувані контейнери:"
echo "   БД: ${DB_CONTAINER}"
echo "   Backend: ${BACKEND_CONTAINER}"
echo "   Мережа: ${NETWORK}"
echo ""

# Перевірка чи існує БД контейнер
if ! docker ps -a --format "{{.Names}}" | grep -q "^${DB_CONTAINER}$"; then
    echo "❌ БД контейнер ${DB_CONTAINER} не знайдено!"
    echo "Доступні контейнери:"
    docker ps -a --format "{{.Names}}" | grep -i postgres
    exit 1
fi

echo "✅ БД контейнер знайдено"

# Перевірка чи запущена БД
if ! docker ps --format "{{.Names}}" | grep -q "^${DB_CONTAINER}$"; then
    echo "⚠️  БД контейнер не запущено, запускаємо..."
    docker start ${DB_CONTAINER}
    sleep 5
fi

# Видалення старого backend контейнера (включаючи з docker-compose)
if docker ps -a --format "{{.Names}}" | grep -q "^${BACKEND_CONTAINER}$"; then
    echo ""
    echo "🛑 Видалення старого backend контейнера..."
    docker stop ${BACKEND_CONTAINER} 2>/dev/null || true
    docker rm -f ${BACKEND_CONTAINER} 2>/dev/null || true
    echo "✅ Видалено"
fi

# Також перевіряємо контейнери з docker-compose
docker-compose -f docker-compose.prod.yml rm -f admin-panel-backend 2>/dev/null || true

echo ""
echo "🔄 Оновлення коду з Git..."
git pull origin main

echo ""
echo "⚠️  УВАГА: Скрипт check-and-fix-db.sh може очистити БД!"
echo "Пропускаємо перевірку БД, щоб не втратити дані"
echo ""
# ./deploy/check-and-fix-db.sh  # Пропускаємо, щоб не очистити БД

echo ""
echo "🏗️  Перебудова backend (без кешу)..."
docker-compose -f docker-compose.prod.yml build --no-cache admin-panel-backend

echo ""
echo "🚀 Запуск backend через docker run (з правильною мережею)..."

# Читаємо конфігурацію
if [ -f "${PROJECT_DIR}/.env" ]; then
    DB_PASSWORD=$(grep "DB_PASSWORD" ${PROJECT_DIR}/.env | cut -d '=' -f2 || echo "admin123")
else
    DB_PASSWORD="admin123"
fi

# Створюємо мережу якщо не існує
if ! docker network ls | grep -q "${NETWORK}"; then
    echo "Створюємо мережу ${NETWORK}..."
    docker network create ${NETWORK} 2>/dev/null || true
fi

# Запускаємо backend контейнер
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
echo "⏳ Очікуємо запуск backend (25 секунд)..."
sleep 25

echo ""
echo "📋 Останні 40 рядків логів backend:"
echo "=========================================="
docker logs --tail 40 ${BACKEND_CONTAINER} 2>&1
echo "=========================================="
echo ""

echo "🔍 Перевірка health:"
curl -s http://localhost:4000/health 2>&1 | head -10
echo ""
echo ""

echo "📊 Кількість properties в БД:"
docker exec ${DB_CONTAINER} psql -U admin -d admin_panel -t -c "SELECT COUNT(*) FROM properties;" 2>&1 | tr -d ' '
echo ""

echo "✅ Завершено!"
echo ""
echo "📊 Статус контейнерів:"
docker ps | grep -E "(${DB_CONTAINER}|${BACKEND_CONTAINER})"
echo ""
echo "🌐 Перевірте в браузері: https://admin.foryou-realestate.com/properties"

