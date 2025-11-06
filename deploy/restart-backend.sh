#!/bin/bash

# Швидкий перезапуск backend контейнера на проді
# Використання: ./restart-backend.sh

set -e

PROJECT_DIR="/opt/admin-panel"
cd $PROJECT_DIR

echo "🔄 Перезапуск backend контейнера..."

# Оновлення коду
if [ -d "$PROJECT_DIR/.git" ]; then
    echo "📥 Оновлення коду з Git..."
    git pull origin main
fi

# Перебудова тільки backend контейнера
echo "🔨 Перебудова backend контейнера..."
docker-compose -f docker-compose.prod.yml build admin-panel-backend

# Перезапуск backend контейнера
echo "🔄 Перезапуск backend..."
docker-compose -f docker-compose.prod.yml up -d --no-deps admin-panel-backend

echo "⏳ Очікування запуску backend..."
sleep 5

# Перевірка статусу
echo "📊 Статус backend контейнера:"
docker-compose -f docker-compose.prod.yml ps admin-panel-backend

# Перевірка логів
echo "📋 Останні логи backend:"
docker-compose -f docker-compose.prod.yml logs --tail=20 admin-panel-backend

echo "✅ Backend перезапущено!"

