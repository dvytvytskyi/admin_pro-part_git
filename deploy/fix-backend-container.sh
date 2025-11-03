#!/bin/bash

# Скрипт для виправлення помилки ContainerConfig
# ВИКОРИСТОВУЙТЕ ЦЕЙ СКРИПТ НА СЕРВЕРІ!

set -e

PROJECT_DIR="/opt/admin-panel"

if [ ! -d "${PROJECT_DIR}" ]; then
    echo "❌ Помилка: Цей скрипт має виконуватися на сервері!"
    exit 1
fi

cd ${PROJECT_DIR}

echo "🛑 Зупинка та видалення проблемного контейнера..."

# Зупиняємо та видаляємо контейнер різними способами
docker stop for-you-admin-panel-backend-prod 2>/dev/null || true
docker rm -f for-you-admin-panel-backend-prod 2>/dev/null || true

# Видаляємо через docker-compose
docker-compose -f docker-compose.prod.yml stop admin-panel-backend 2>/dev/null || true
docker-compose -f docker-compose.prod.yml rm -f admin-panel-backend 2>/dev/null || true

echo ""
echo "🔧 Оновлення коду з Git..."
git pull origin main

echo ""
echo "🏗️  Перебудова backend контейнера..."
docker-compose -f docker-compose.prod.yml build --no-cache admin-panel-backend

echo ""
echo "🚀 Запуск backend..."
docker-compose -f docker-compose.prod.yml up -d admin-panel-backend

echo ""
echo "⏳ Очікуємо запуск backend (10 секунд)..."
sleep 10

echo ""
echo "📋 Останні 20 рядків логів backend:"
docker logs --tail 20 for-you-admin-panel-backend-prod 2>&1 | tail -20

echo ""
echo "✅ Backend виправлено та запущено!"
echo ""
echo "🌐 Перевірте API: curl http://localhost:4000/health"

