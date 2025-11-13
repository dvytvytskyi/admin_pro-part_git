#!/bin/bash

# Скрипт для виправлення 502 через HTTPS

set -e

SERVER_IP="135.181.201.185"
SERVER_USER="root"
DOMAIN="system.pro-part.online"

echo "🔧 Виправлення 502 через HTTPS для ${DOMAIN}..."
echo ""

read -sp "Введіть пароль для root@${SERVER_IP}: " SERVER_PASSWORD
echo ""

sshpass -p "${SERVER_PASSWORD}" ssh -o StrictHostKeyChecking=no ${SERVER_USER}@${SERVER_IP} << 'ENDSSH'
set -e

DOMAIN="system.pro-part.online"

echo "📋 Поточна конфігурація nginx для ${DOMAIN}:"
echo ""
cat /etc/nginx/sites-available/${DOMAIN}
echo ""

echo "🔍 Перевірка SSL сертифікату:"
if [ -d "/etc/letsencrypt/live/${DOMAIN}" ]; then
    echo "   ✅ SSL сертифікат існує"
    ls -la /etc/letsencrypt/live/${DOMAIN}/ | head -5
else
    echo "   ⚠️  SSL сертифікат не знайдено"
fi
echo ""

echo "📝 Створення правильної конфігурації з виправленням для HTTPS..."
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

    # Збільшуємо таймаути для upstream
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
        
        # Додаткові налаштування для стабільності
        proxy_buffering off;
        proxy_request_buffering off;
    }

    # Backend API
    location /api {
        proxy_pass http://localhost:4001;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Додаткові налаштування для стабільності
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

# Якщо SSL сертифікат не існує, створюємо тимчасову конфігурацію без SSL
if [ ! -d "/etc/letsencrypt/live/${DOMAIN}" ]; then
    echo "   ⚠️  SSL сертифікат не знайдено - створюємо тимчасову конфігурацію..."
    cat > /etc/nginx/sites-available/${DOMAIN} << 'NGINXEOF'
server {
    listen 80;
    server_name system.pro-part.online;

    # Збільшуємо таймаути для upstream
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
        
        # Додаткові налаштування для стабільності
        proxy_buffering off;
        proxy_request_buffering off;
    }

    # Backend API
    location /api {
        proxy_pass http://localhost:4001;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Додаткові налаштування для стабільності
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

echo "   Тест через HTTP:"
curl -s http://localhost/api/health | head -3 || echo "   ⚠️  Не працює"
echo ""

echo "   Тест через HTTPS:"
curl -s -k https://localhost/api/health | head -3 || echo "   ⚠️  Не працює"
echo ""

echo "✅ Виправлення завершено"

ENDSSH

echo ""
echo "✅ Готово!"

