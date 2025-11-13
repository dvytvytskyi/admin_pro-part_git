#!/bin/bash

# Скрипт для детальної діагностики помилки 502

set -e

SERVER_IP="135.181.201.185"
SERVER_USER="root"
DOMAIN="system.pro-part.online"

echo "🔍 Детальна діагностика помилки 502..."
echo ""

read -sp "Введіть пароль для root@${SERVER_IP}: " SERVER_PASSWORD
echo ""

sshpass -p "${SERVER_PASSWORD}" ssh -o StrictHostKeyChecking=no ${SERVER_USER}@${SERVER_IP} << 'ENDSSH'
set -e

DOMAIN="system.pro-part.online"

echo "1️⃣ Перевірка бекенду:"
echo ""
echo "   Статус контейнера:"
docker ps | grep admin-pro-part-backend || echo "   ❌ Контейнер не знайдено"
echo ""

echo "   Health check:"
curl -s http://localhost:4001/health || echo "   ❌ Не відповідає"
echo ""

echo "   Логи бекенду (останні 30 рядків):"
docker logs --tail 30 admin-pro-part-backend 2>&1 | tail -20
echo ""

echo "2️⃣ Перевірка nginx:"
echo ""
echo "   Поточна конфігурація для /api:"
grep -A 15 "location /api" /etc/nginx/sites-available/${DOMAIN} || echo "   ⚠️  Не знайдено"
echo ""

echo "   Тест з'єднання nginx -> бекенд:"
curl -v http://localhost:4001/api/health 2>&1 | head -20 || echo "   ⚠️  Помилка"
echo ""

echo "3️⃣ Перевірка помилок nginx:"
echo ""
echo "   Останні помилки (502, Bad Gateway, upstream):"
tail -50 /var/log/nginx/error.log | grep -E "502|Bad Gateway|upstream|admin-pro-part|4001" || echo "   Помилок не знайдено"
echo ""

echo "4️⃣ Тестування через різні шляхи:"
echo ""
echo "   Прямий запит до бекенду:"
curl -s http://localhost:4001/health | head -3
echo ""

echo "   Через nginx HTTP:"
curl -s http://localhost/api/health 2>&1 | head -5
echo ""

echo "   Через nginx HTTPS:"
curl -s -k https://localhost/api/health 2>&1 | head -5
echo ""

echo "5️⃣ Перевірка мережі Docker:"
echo ""
echo "   IP адреса контейнера бекенду:"
docker inspect admin-pro-part-backend | grep -A 5 "IPAddress" | head -10 || echo "   Не знайдено"
echo ""

echo "6️⃣ Перевірка портів:"
echo ""
netstat -tlnp | grep -E "4001|3002" || ss -tlnp | grep -E "4001|3002"
echo ""

echo "✅ Діагностика завершена"

ENDSSH

echo ""
echo "✅ Готово!"

