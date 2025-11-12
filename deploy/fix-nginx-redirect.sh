#!/bin/bash

# Скрипт для виправлення Nginx redirect на system.pro-part.online
# Перевіряє та виправляє конфігурацію Nginx

set -e

SERVER_IP="135.181.201.185"
SERVER_USER="root"
DOMAIN="system.pro-part.online"

echo "🔍 Перевірка Nginx конфігурації для ${DOMAIN}..."
echo ""

read -sp "Введіть пароль для root@${SERVER_IP}: " SERVER_PASSWORD
echo ""

sshpass -p "${SERVER_PASSWORD}" ssh -o StrictHostKeyChecking=no ${SERVER_USER}@${SERVER_IP} << ENDSSH
set -e

DOMAIN="${DOMAIN}"

echo "📋 Перевірка поточних Nginx конфігурацій..."
echo ""

# Перевіряємо чи існує конфігурація для system.pro-part.online
if [ -f "/etc/nginx/sites-available/${DOMAIN}" ]; then
    echo "✅ Конфігурація ${DOMAIN} існує"
    echo ""
    echo "📄 Поточний вміст:"
    cat /etc/nginx/sites-available/${DOMAIN}
    echo ""
else
    echo "❌ Конфігурація ${DOMAIN} не знайдена"
    echo ""
fi

# Перевіряємо default конфігурацію
if [ -f "/etc/nginx/sites-enabled/default" ]; then
    echo "⚠️  Знайдено default конфігурацію:"
    cat /etc/nginx/sites-enabled/default | grep -A 5 "server_name" || echo "   (немає server_name)"
    echo ""
fi

# Перевіряємо всі активні конфігурації
echo "📋 Всі активні Nginx конфігурації:"
ls -la /etc/nginx/sites-enabled/
echo ""

# Перевіряємо чи є redirect на foryou
echo "🔍 Пошук redirect на foryou-realestate.com..."
grep -r "foryou-realestate.com" /etc/nginx/sites-enabled/ 2>/dev/null || echo "   Не знайдено"
echo ""

# Перевіряємо чи є default server block з redirect
echo "🔍 Перевірка default server blocks..."
grep -A 10 "default_server" /etc/nginx/sites-enabled/* 2>/dev/null || echo "   Не знайдено default_server"
echo ""

echo "✅ Перевірка завершена"
echo ""
echo "💡 Якщо потрібно виправити конфігурацію, виконайте на сервері:"
echo "   1. nano /etc/nginx/sites-available/${DOMAIN}"
echo "   2. Переконайтеся що server_name = ${DOMAIN}"
echo "   3. nginx -t"
echo "   4. systemctl reload nginx"

ENDSSH

echo ""
echo "✅ Перевірка завершена!"

