#!/bin/bash

# Перевірка роботи backend після запуску
# ВИКОРИСТОВУЙТЕ ЦЕЙ СКРИПТ НА СЕРВЕРІ!

set -e

PROJECT_DIR="/opt/admin-panel"

if [ ! -d "${PROJECT_DIR}" ]; then
    echo "❌ Помилка: Цей скрипт має виконуватися на сервері!"
    exit 1
fi

cd ${PROJECT_DIR}

echo "🔍 Перевірка backend..."
echo ""

# 1. Статус контейнера
echo "📦 Статус контейнера:"
docker ps | grep backend-prod || echo "❌ Контейнер не запущено"
echo ""

# 2. Останні 30 рядків логів
echo "📋 Останні 30 рядків логів backend:"
echo "=========================================="
docker logs --tail 30 for-you-admin-panel-backend-prod 2>&1
echo "=========================================="
echo ""

# 3. Health check
echo "🌐 Health check endpoint:"
HEALTH=$(curl -s http://localhost:4000/health 2>&1)
echo "$HEALTH"
echo ""

# Перевірка статусу БД в health
if echo "$HEALTH" | grep -q '"database":"connected"'; then
    echo "✅ БД підключено!"
elif echo "$HEALTH" | grep -q '"database":"disconnected"'; then
    echo "❌ БД НЕ підключено!"
else
    echo "⚠️  Не вдалося визначити статус БД"
fi
echo ""

# 4. Перевірка підключення до БД з контейнера
echo "🗄️  Пряма перевірка підключення до БД:"
docker exec for-you-admin-panel-backend-prod sh -c 'echo "DATABASE_URL check:"; echo $DATABASE_URL | head -c 50' 2>&1
echo "..."
echo ""

# 5. Перевірка entities
echo "📂 Перевірка entities:"
docker exec for-you-admin-panel-backend-prod sh -c 'ls -la dist/entities/ 2>&1 | head -5' || echo "⚠️  Папка dist/entities не знайдена"
echo ""

# 6. Статистика контейнера
echo "📊 Статистика контейнера:"
docker stats --no-stream for-you-admin-panel-backend-prod 2>&1 | head -2
echo ""

echo "✅ Перевірка завершена!"

