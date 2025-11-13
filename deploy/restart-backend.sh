#!/bin/bash

# Скрипт для перезапуску бекенду на сервері

set -e

SERVER_IP="135.181.201.185"
SERVER_USER="root"
PROJECT_DIR="/opt/admin-pro-part"

echo "🔄 Перезапуск бекенду на сервері..."
echo ""

read -sp "Введіть пароль для root@${SERVER_IP}: " SERVER_PASSWORD
echo ""

sshpass -p "${SERVER_PASSWORD}" ssh -o StrictHostKeyChecking=no ${SERVER_USER}@${SERVER_IP} << 'ENDSSH'
set -e

PROJECT_DIR="/opt/admin-pro-part"

echo "🔍 Перевірка поточного стану..."
cd ${PROJECT_DIR} || { echo "❌ Директорія ${PROJECT_DIR} не знайдена"; exit 1; }

echo ""
echo "🐳 Поточні контейнери:"
docker ps --format "table {{.Names}}\t{{.Status}}" | grep -E "backend|admin-pro-part|NAMES" || echo "   Контейнери не знайдено"
echo ""

echo "🛑 Зупинка бекенду..."
if [ -f "docker-compose.prod.yml" ]; then
    docker-compose -f docker-compose.prod.yml stop admin-pro-part-backend 2>/dev/null || true
    docker-compose -f docker-compose.prod.yml rm -f admin-pro-part-backend 2>/dev/null || true
elif [ -f "docker-compose.yml" ]; then
    docker-compose stop admin-pro-part-backend 2>/dev/null || true
    docker-compose rm -f admin-pro-part-backend 2>/dev/null || true
fi

echo "   ✅ Бекенд зупинено"
echo ""

echo "🚀 Запуск бекенду..."
if [ -f "docker-compose.prod.yml" ]; then
    docker-compose -f docker-compose.prod.yml up -d admin-pro-part-backend
elif [ -f "docker-compose.yml" ]; then
    docker-compose up -d admin-pro-part-backend
else
    echo "   ❌ docker-compose файл не знайдено"
    exit 1
fi

echo "   ✅ Бекенд запущено"
echo ""

echo "⏳ Очікування запуску (10 секунд)..."
sleep 10

echo ""
echo "🔍 Перевірка статусу бекенду:"
if curl -s http://localhost:4001/health > /dev/null 2>&1; then
    echo "   ✅ Бекенд працює!"
    curl -s http://localhost:4001/health | head -3
else
    echo "   ⚠️  Бекенд ще не відповідає"
    echo "   📋 Логи бекенду:"
    docker logs --tail 20 admin-pro-part-backend 2>/dev/null || echo "   Не вдалося отримати логи"
fi
echo ""

echo "✅ Перезапуск завершено"

ENDSSH

echo ""
echo "✅ Готово!"

