#!/bin/bash

# Виправлення портів та перебудова контейнерів

SERVER_IP="135.181.201.185"
SERVER_USER="root"

echo "🔧 Виправлення production..."
echo ""

read -sp "Введіть пароль для root@${SERVER_IP}: " SERVER_PASSWORD
echo ""

sshpass -p "${SERVER_PASSWORD}" ssh -o StrictHostKeyChecking=no ${SERVER_USER}@${SERVER_IP} << 'ENDSSH'
cd /opt/admin-pro-part

echo "🔄 Оновлюємо код з репозиторію..."
git pull origin main || echo "⚠️  Не вдалося оновити"

echo ""
echo "🛑 Зупиняємо контейнери..."
docker-compose -f docker-compose.prod.yml down

echo ""
echo "🔨 Перебудовуємо контейнери..."
docker-compose -f docker-compose.prod.yml build --no-cache

echo ""
echo "🚀 Запускаємо контейнери..."
docker-compose -f docker-compose.prod.yml up -d

echo ""
echo "⏳ Чекаємо 15 секунд для запуску..."
sleep 15

echo ""
echo "📊 Статус контейнерів:"
docker-compose -f docker-compose.prod.yml ps

echo ""
echo "🔍 Перевірка health endpoints:"
echo "Backend /health:"
curl -s http://localhost:4001/health | head -5 || echo "   ❌ Не працює"
echo ""
echo "Frontend:"
curl -s http://localhost:3002 | head -5 || echo "   ❌ Не працює"

echo ""
echo "📋 Логи backend (останні 10 рядків):"
docker logs admin-pro-part-backend --tail=10

echo ""
echo "📋 Логи frontend (останні 10 рядків):"
docker logs admin-pro-part-frontend --tail=10

ENDSSH

echo ""
echo "✅ Готово!"

