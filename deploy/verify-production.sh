#!/bin/bash

# Перевірка production статусу

SERVER_IP="135.181.201.185"
SERVER_USER="root"

echo "🔍 Перевірка production статусу..."
echo ""

read -sp "Введіть пароль для root@${SERVER_IP}: " SERVER_PASSWORD
echo ""

sshpass -p "${SERVER_PASSWORD}" ssh -o StrictHostKeyChecking=no ${SERVER_USER}@${SERVER_IP} << 'ENDSSH'
cd /opt/admin-pro-part

echo "🐳 Статус контейнерів:"
docker-compose -f docker-compose.prod.yml ps
echo ""

echo "🔍 Backend Health:"
curl -s http://localhost:4001/health | python3 -m json.tool 2>/dev/null || curl -s http://localhost:4001/health
echo ""
echo ""

echo "🔍 Frontend (перші 500 символів):"
curl -s http://localhost:3002 | head -c 500
echo ""
echo ""

echo "🌐 Перевірка через Nginx (system.pro-part.online):"
curl -s -I http://system.pro-part.online 2>&1 | head -10
echo ""

echo "📋 Логи backend (останні 5 рядків):"
docker logs admin-pro-part-backend --tail=5 2>&1 | tail -5
echo ""

echo "📋 Логи frontend (останні 5 рядків):"
docker logs admin-pro-part-frontend --tail=5 2>&1 | tail -5
echo ""

echo "✅ Перевірка завершена!"

ENDSSH

echo ""
echo "🌐 Перевірте в браузері: http://system.pro-part.online"

