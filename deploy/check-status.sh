#!/bin/bash

# Скрипт для перевірки статусу system.pro-part.online на сервері

SERVER_IP="135.181.201.185"
SERVER_USER="root"

echo "🔍 Перевірка статусу system.pro-part.online..."
echo ""

read -sp "Введіть пароль для root@${SERVER_IP}: " SERVER_PASSWORD
echo ""

sshpass -p "${SERVER_PASSWORD}" ssh -o StrictHostKeyChecking=no ${SERVER_USER}@${SERVER_IP} << 'ENDSSH'
echo "📋 Статус Nginx конфігурації:"
nginx -t 2>&1 | tail -2
echo ""

echo "🐳 Docker контейнери admin-pro-part:"
docker ps | grep admin-pro-part || echo "   ❌ Контейнери не запущені"
echo ""

echo "🌐 Активні Nginx конфігурації:"
ls -la /etc/nginx/sites-enabled/ | grep -E "(system|for-you|default)"
echo ""

echo "📊 Перевірка портів:"
netstat -tulpn | grep -E ":(3002|4001)" || ss -tulpn | grep -E ":(3002|4001)"
echo ""

echo "📄 Вміст конфігурації system.pro-part.online:"
cat /etc/nginx/sites-available/system.pro-part.online 2>/dev/null || echo "   ❌ Файл не знайдено"
echo ""

ENDSSH

echo ""
echo "✅ Перевірка завершена!"

