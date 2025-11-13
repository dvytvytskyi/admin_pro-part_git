#!/bin/bash

# Діагностичний скрипт для проблеми з логіном

set -e

SERVER_IP="135.181.201.185"
SERVER_USER="root"
DOMAIN="system.pro-part.online"

echo "🔍 Діагностика проблеми з логіном..."
echo ""

read -sp "Введіть пароль для root@${SERVER_IP}: " SERVER_PASSWORD
echo ""

sshpass -p "${SERVER_PASSWORD}" ssh -o StrictHostKeyChecking=no ${SERVER_USER}@${SERVER_IP} << 'ENDSSH'
set -e

DOMAIN="system.pro-part.online"

echo "═══════════════════════════════════════════════════════════"
echo "1️⃣  Перевірка статусу бекенду"
echo "═══════════════════════════════════════════════════════════"
docker ps | grep admin-panel-backend || echo "   ⚠️  Бекенд контейнер не знайдено"
echo ""

echo "═══════════════════════════════════════════════════════════"
echo "2️⃣  Перевірка nginx конфігурації для /api"
echo "═══════════════════════════════════════════════════════════"
echo "Поточна конфігурація location /api:"
grep -A 15 "location /api" /etc/nginx/sites-available/${DOMAIN} || echo "   ⚠️  location /api не знайдено"
echo ""

echo "═══════════════════════════════════════════════════════════"
echo "3️⃣  Перевірка логів nginx (останні 10 рядків)"
echo "═══════════════════════════════════════════════════════════"
tail -10 /var/log/nginx/error.log | grep -i "system.pro-part\|502\|error" || echo "   ℹ️  Помилок не знайдено"
echo ""

echo "═══════════════════════════════════════════════════════════"
echo "4️⃣  Перевірка доступності бекенду локально"
echo "═══════════════════════════════════════════════════════════"
echo "Тест /health:"
curl -s http://localhost:4001/health | head -3 || echo "   ❌ Бекенд не відповідає на порту 4001"
echo ""

echo "Тест /api/health:"
curl -s http://localhost:4001/api/health | head -3 || echo "   ❌ /api/health не працює"
echo ""

echo "═══════════════════════════════════════════════════════════"
echo "5️⃣  Тест через nginx (локально)"
echo "═══════════════════════════════════════════════════════════"
echo "Тест /api/health через nginx:"
curl -s http://localhost/api/health | head -3 || echo "   ❌ Nginx не проксує запит"
echo ""

echo "Тест /api/auth/login через nginx (POST):"
RESPONSE=$(curl -s -X POST http://localhost/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@foryou.ae","password":"admin123"}')
echo "$RESPONSE" | head -5
if echo "$RESPONSE" | grep -q "success"; then
    echo "   ✅ Логін працює!"
elif echo "$RESPONSE" | grep -q "502"; then
    echo "   ❌ 502 Bad Gateway"
elif echo "$RESPONSE" | grep -q "404"; then
    echo "   ❌ 404 Not Found - роут не знайдено"
else
    echo "   ⚠️  Неочікувана відповідь"
fi
echo ""

echo "═══════════════════════════════════════════════════════════"
echo "6️⃣  Перевірка логів бекенду (останні 20 рядків)"
echo "═══════════════════════════════════════════════════════════"
docker logs admin-panel-backend --tail 20 2>&1 | grep -i "error\|login\|auth" || echo "   ℹ️  Релевантних логів не знайдено"
echo ""

echo "═══════════════════════════════════════════════════════════"
echo "7️⃣  Перевірка змінних середовища бекенду"
echo "═══════════════════════════════════════════════════════════"
docker exec admin-panel-backend env | grep -E "PORT|DATABASE_URL|ADMIN_" | head -5 || echo "   ⚠️  Не вдалося отримати змінні"
echo ""

echo "✅ Діагностика завершена"

ENDSSH

echo ""
echo "✅ Готово!"

