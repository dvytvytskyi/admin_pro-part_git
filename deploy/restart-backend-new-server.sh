#!/bin/bash

# Перезапуск бекенду на новому сервері

set -e

SERVER_IP="88.99.38.25"
SERVER_USER="root"
SERVER_PASSWORD="PgTeNqcgnwWu"

echo "🔄 Перезапуск бекенду..."
echo ""

sshpass -p "${SERVER_PASSWORD}" ssh -o StrictHostKeyChecking=no ${SERVER_USER}@${SERVER_IP} << ENDSSH
set -e

cd /opt/admin-pro-part

# Перевіряємо, яка версія docker compose доступна
if command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE_CMD="docker-compose"
elif docker compose version &> /dev/null; then
    DOCKER_COMPOSE_CMD="docker compose"
else
    echo "   ❌ Docker Compose не знайдено!"
    exit 1
fi

echo "🛑 Зупинка бекенду..."
\$DOCKER_COMPOSE_CMD -f docker-compose.prod.yml stop admin-pro-part-backend || true
\$DOCKER_COMPOSE_CMD -f docker-compose.prod.yml rm -f admin-pro-part-backend || true

echo "🔨 Перебудова бекенду..."
\$DOCKER_COMPOSE_CMD -f docker-compose.prod.yml build --no-cache admin-pro-part-backend

echo "🚀 Запуск бекенду..."
\$DOCKER_COMPOSE_CMD -f docker-compose.prod.yml up -d admin-pro-part-backend

echo "⏳ Чекаємо 10 секунд..."
sleep 10

echo "📊 Статус бекенду:"
docker ps -a | grep admin-pro-part-backend

echo ""
echo "📋 Останні логи:"
docker logs admin-pro-part-backend --tail 30 2>&1

ENDSSH

echo ""
echo "✅ Готово!"

