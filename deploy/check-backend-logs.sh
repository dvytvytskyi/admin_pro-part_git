#!/bin/bash

# Скрипт для перевірки логів бекенду на новому сервері

set -e

SERVER_IP="88.99.38.25"
SERVER_USER="root"
SERVER_PASSWORD="PgTeNqcgnwWu"

echo "🔍 Перевірка логів бекенду..."
echo ""

sshpass -p "${SERVER_PASSWORD}" ssh -o StrictHostKeyChecking=no ${SERVER_USER}@${SERVER_IP} << 'ENDSSH'
set -e

echo "📋 Останні 50 рядків логів бекенду:"
docker logs admin-pro-part-backend --tail 50 2>&1

echo ""
echo "📊 Статус контейнера:"
docker ps -a | grep admin-pro-part-backend

echo ""
echo "🔍 Перевірка змінних середовища:"
docker exec admin-pro-part-backend env | grep -E "DATABASE_URL|PORT|NODE_ENV" | head -5 || echo "   ⚠️  Контейнер не запущений"

ENDSSH

echo ""
echo "✅ Готово!"

