#!/bin/bash

# Скрипт для виправлення nginx - прибрати /api префікс при проксуванні

set -e

SERVER_IP="135.181.201.185"
SERVER_USER="root"
DOMAIN="system.pro-part.online"

echo "🔧 Виправлення nginx конфігурації - прибрати /api префікс..."
echo ""

read -sp "Введіть пароль для root@${SERVER_IP}: " SERVER_PASSWORD
echo ""

sshpass -p "${SERVER_PASSWORD}" ssh -o StrictHostKeyChecking=no ${SERVER_USER}@${SERVER_IP} << 'ENDSSH'
set -e

DOMAIN="system.pro-part.online"

echo "📋 Поточна конфігурація:"
grep -A 10 "location /api" /etc/nginx/sites-available/${DOMAIN} | head -15
echo ""

echo "📝 Створення правильної конфігурації (без /api префіксу)..."
echo ""

# Читаємо поточну конфігурацію
CURRENT_CONFIG=$(cat /etc/nginx/sites-available/${DOMAIN})

# Перевіряємо чи є SSL
HAS_SSL=$(echo "$CURRENT_CONFIG" | grep -q "listen 443" && echo "yes" || echo "no")

if [ "$HAS_SSL" = "yes" ]; then
    # Конфігурація з SSL
    cat > /etc/nginx/sites-available/${DOMAIN} << 'NGINXEOF'
server {
    listen 80;
    server_name system.pro-part.online;
    
    # Redirect HTTP to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name system.pro-part.online;

    # SSL сертифікат
    ssl_certificate /etc/letsencrypt/live/system.pro-part.online/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/system.pro-part.online/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    # Таймаути
    proxy_connect_timeout 60s;
    proxy_send_timeout 60s;
    proxy_read_timeout 60s;

    # Frontend
    location / {
        proxy_pass http://localhost:3002;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        proxy_buffering off;
        proxy_request_buffering off;
    }

    # Backend API - ВИПРАВЛЕНО: прибираємо /api префікс
    location /api {
        # Використовуємо rewrite для прибирання /api префіксу
        rewrite ^/api/(.*) /$1 break;
        proxy_pass http://localhost:4001;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
        proxy_buffering off;
        proxy_request_buffering off;
    }

    # Health check endpoint
    location /health {
        proxy_pass http://localhost:4001/health;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
    }
}
NGINXEOF
else
    # Конфігурація без SSL
    cat > /etc/nginx/sites-available/${DOMAIN} << 'NGINXEOF'
server {
    listen 80;
    server_name system.pro-part.online;

    # Таймаути
    proxy_connect_timeout 60s;
    proxy_send_timeout 60s;
    proxy_read_timeout 60s;

    # Frontend
    location / {
        proxy_pass http://localhost:3002;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        proxy_buffering off;
        proxy_request_buffering off;
    }

    # Backend API - ВИПРАВЛЕНО: прибираємо /api префікс
    location /api {
        # Використовуємо rewrite для прибирання /api префіксу
        rewrite ^/api/(.*) /$1 break;
        proxy_pass http://localhost:4001;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
        proxy_buffering off;
        proxy_request_buffering off;
    }

    # Health check endpoint
    location /health {
        proxy_pass http://localhost:4001/health;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
    }
}
NGINXEOF
fi

echo "   ✅ Конфігурація оновлена"
echo ""

# Перевіряємо конфігурацію
echo "🔍 Перевірка конфігурації..."
if nginx -t 2>&1; then
    echo "   ✅ Конфігурація валідна"
else
    echo "   ❌ Помилка в конфігурації!"
    nginx -t 2>&1
    exit 1
fi
echo ""

# Перезавантажуємо nginx
echo "🔄 Перезавантаження nginx..."
systemctl reload nginx
echo "   ✅ Nginx перезавантажено"
echo ""

# Тестуємо
echo "🧪 Тестування після виправлення:"
sleep 2

echo "   Тест /api/health:"
curl -s http://localhost/api/health | head -3 || echo "   ⚠️  Не працює"
echo ""

echo "   Тест /api/auth/login (методом POST):"
curl -s -X POST http://localhost/api/auth/login -H "Content-Type: application/json" -d '{"email":"test","password":"test"}' | head -3 || echo "   ⚠️  Не працює"
echo ""

echo "✅ Виправлення завершено"

ENDSSH

echo ""
echo "✅ Готово!"

