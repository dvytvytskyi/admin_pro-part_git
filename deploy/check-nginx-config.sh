#!/bin/bash

# Скрипт для перевірки Nginx конфігурації на сервері

set -e

SERVER_IP="135.181.201.185"
SERVER_USER="root"
DOMAIN="system.pro-part.online"

echo "🔍 Перевірка Nginx конфігурації для ${DOMAIN}..."
echo ""

read -sp "Введіть пароль для root@${SERVER_IP}: " SERVER_PASSWORD
echo ""

sshpass -p "${SERVER_PASSWORD}" ssh -o StrictHostKeyChecking=no ${SERVER_USER}@${SERVER_IP} << 'ENDSSH'
set -e

DOMAIN="system.pro-part.online"

echo "📋 Активні Nginx конфігурації:"
echo ""
ls -la /etc/nginx/sites-enabled/
echo ""

echo "🔍 Пошук редиректів на admin.foryou-realestate.com:"
echo ""
grep -r "admin.foryou-realestate.com\|foryou-realestate" /etc/nginx/sites-enabled/ 2>/dev/null || echo "   ✅ Редиректів на foryou не знайдено"
echo ""

echo "📄 Конфігурація для ${DOMAIN}:"
echo ""
if [ -f "/etc/nginx/sites-available/${DOMAIN}" ]; then
    cat /etc/nginx/sites-available/${DOMAIN}
else
    echo "   ❌ Конфігурація не знайдена"
fi
echo ""

echo "🔍 Перевірка default конфігурації:"
echo ""
if [ -f "/etc/nginx/sites-enabled/default" ] || [ -L "/etc/nginx/sites-enabled/default" ]; then
    echo "   ⚠️  Знайдено default конфігурацію:"
    cat /etc/nginx/sites-enabled/default | head -30
else
    echo "   ✅ Default конфігурація не знайдена"
fi
echo ""

echo "🔍 Перевірка всіх server blocks на редиректи:"
echo ""
for config in /etc/nginx/sites-enabled/*; do
    if [ -f "$config" ]; then
        echo "   📄 $(basename $config):"
        grep -E "return|rewrite|proxy_pass" "$config" | head -5 || echo "      (немає редиректів)"
        echo ""
    fi
done

echo "✅ Перевірка завершена"

ENDSSH

echo ""
echo "✅ Готово!"

