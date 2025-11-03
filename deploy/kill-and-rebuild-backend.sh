#!/bin/bash

# Радикальне виправлення: повне видалення та перебудова
# ВИКОРИСТОВУЙТЕ ЦЕЙ СКРИПТ НА СЕРВЕРІ!

set -e

PROJECT_DIR="/opt/admin-panel"

if [ ! -d "${PROJECT_DIR}" ]; then
    echo "❌ Помилка: Цей скрипт має виконуватися на сервері!"
    exit 1
fi

cd ${PROJECT_DIR}

echo "🔄 Оновлення коду з Git..."
git pull origin main

echo ""
echo "💀 Радикальне видалення backend (контейнер + образ)..."
docker-compose -f docker-compose.prod.yml down admin-panel-backend 2>/dev/null || true
docker stop for-you-admin-panel-backend-prod 2>/dev/null || true
docker rm -f for-you-admin-panel-backend-prod 2>/dev/null || true
docker-compose -f docker-compose.prod.yml rm -f admin-panel-backend 2>/dev/null || true

# Видаляємо всі образи backend
docker images | grep "admin-panel.*backend" | awk '{print $3}' | xargs -r docker rmi -f 2>/dev/null || true
docker images | grep "admin-panel_admin-panel-backend" | awk '{print $3}' | xargs -r docker rmi -f 2>/dev/null || true

echo "✅ Видалено"

echo ""
echo "🔧 Перевірка та виправлення конфігурації БД..."
./deploy/check-and-fix-db.sh

echo ""
echo "🏗️  Перебудова backend з нуля (без кешу)..."
docker-compose -f docker-compose.prod.yml build --no-cache --pull admin-panel-backend

echo ""
echo "🚀 Створення та запуск нового контейнера..."
# Використовуємо --no-deps щоб не чекати на інші сервіси
docker-compose -f docker-compose.prod.yml up -d --force-recreate --no-deps admin-panel-backend

echo ""
echo "⏳ Очікуємо запуск backend (15 секунд)..."
sleep 15

echo ""
echo "📋 Останні 30 рядків логів backend:"
echo "=========================================="
docker logs --tail 30 for-you-admin-panel-backend-prod 2>&1 || echo "Контейнер не запущено"
echo "=========================================="
echo ""

echo "🔍 Перевірка health endpoint:"
curl -s http://localhost:4000/health 2>&1 | head -5 || echo "API не відповідає"
echo ""
echo ""

echo "📊 Статус контейнерів:"
docker-compose -f docker-compose.prod.yml ps
echo ""

echo "✅ Процес завершено!"
echo ""
echo "🌐 Перевірте в браузері: https://admin.foryou-realestate.com"
echo "📋 Для детальних логів: ./deploy/check-backend-logs.sh"

