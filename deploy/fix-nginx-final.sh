#!/bin/bash

# Фінальне виправлення Nginx - видаляє всі конфлікти

SERVER_IP="135.181.201.185"
SERVER_USER="root"

echo "🔧 Фінальне виправлення Nginx..."
echo ""

read -sp "Введіть пароль для root@${SERVER_IP}: " SERVER_PASSWORD
echo ""

sshpass -p "${SERVER_PASSWORD}" ssh -o StrictHostKeyChecking=no ${SERVER_USER}@${SERVER_IP} << 'ENDSSH'
set -e

echo "🔍 Перевірка поточних конфігурацій..."
echo ""
echo "Активні конфігурації:"
ls -la /etc/nginx/sites-enabled/
echo ""

echo "Пошук конфігурацій з foryou:"
grep -r "foryou-realestate.com" /etc/nginx/sites-enabled/ 2>/dev/null || echo "   Не знайдено"
echo ""

echo "Пошук default server:"
grep -r "default_server" /etc/nginx/sites-enabled/ 2>/dev/null || echo "   Не знайдено"
echo ""

# Видаляємо default якщо є
if [ -L "/etc/nginx/sites-enabled/default" ]; then
    echo "🗑️  Видаляємо default конфігурацію..."
    rm -f /etc/nginx/sites-enabled/default
fi

# Видаляємо стару конфігурацію system.pro-part.online
rm -f /etc/nginx/sites-available/system.pro-part.online
rm -f /etc/nginx/sites-enabled/system.pro-part.online

# Створюємо правильну конфігурацію
echo "📝 Створюємо правильну конфігурацію..."
cat > /etc/nginx/sites-available/system.pro-part.online << 'NGINXEOF'
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name system.pro-part.online _;

    # Frontend
    location / {
        proxy_pass http://localhost:3002;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Backend API
    location /api {
        proxy_pass http://localhost:4001;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Health endpoint
    location /health {
        proxy_pass http://localhost:4001/health;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
    }
}
NGINXEOF

# Активуємо
ln -s /etc/nginx/sites-available/system.pro-part.online /etc/nginx/sites-enabled/

# Перевіряємо
echo ""
echo "🔍 Перевірка конфігурації..."
if nginx -t; then
    echo "✅ Конфігурація валідна"
    systemctl reload nginx
    echo "✅ Nginx перезавантажено"
else
    echo "❌ Помилка в конфігурації"
    exit 1
fi

# Перевіряємо
echo ""
echo "🌐 Тест запиту:"
curl -I http://system.pro-part.online 2>&1 | head -10

ENDSSH

echo ""
echo "✅ Готово!"

