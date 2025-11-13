#!/bin/bash

# Скрипт для виправлення Nginx на сервері через SSH

set -e

SERVER_IP="135.181.201.185"
SERVER_USER="root"
DOMAIN="system.pro-part.online"

echo "🔧 Виправлення Nginx для ${DOMAIN} на сервері ${SERVER_IP}..."
echo ""

# Завантажуємо скрипт на сервер та виконуємо
ssh ${SERVER_USER}@${SERVER_IP} << 'ENDSSH'
set -e

DOMAIN="system.pro-part.online"
FRONTEND_PORT="3002"
BACKEND_PORT="4001"

echo "🔧 Виправлення Nginx для ${DOMAIN}..."
echo ""

# Видаляємо ВСІ конфігурації, які можуть конфліктувати
echo "🗑️  Видаляємо конфліктуючі конфігурації..."
rm -f /etc/nginx/sites-enabled/default
rm -f /etc/nginx/sites-available/default
rm -f /etc/nginx/sites-enabled/*admin.foryou* 2>/dev/null || true
rm -f /etc/nginx/sites-available/*admin.foryou* 2>/dev/null || true
rm -f /etc/nginx/sites-enabled/${DOMAIN} 2>/dev/null || true
rm -f /etc/nginx/sites-available/${DOMAIN} 2>/dev/null || true

# Видаляємо конфігурації з редиректами на foryou
echo "🔍 Перевірка наявних конфігурацій..."
for config in /etc/nginx/sites-enabled/*; do
    if [ -f "$config" ]; then
        if grep -q "admin.foryou-realestate.com" "$config" 2>/dev/null || grep -q "foryou-realestate" "$config" 2>/dev/null; then
            echo "   ⚠️  Видаляємо конфігурацію з foryou: $(basename $config)"
            rm -f "$config"
            rm -f "/etc/nginx/sites-available/$(basename $config)" 2>/dev/null || true
        fi
    fi
done

# Перевіряємо чи є конфігурації, які редиректять на foryou
echo "🔍 Перевірка конфігурацій на редиректи..."
for config in /etc/nginx/sites-available/*; do
    if [ -f "$config" ]; then
        if grep -q "admin.foryou-realestate.com" "$config" 2>/dev/null || grep -q "foryou-realestate" "$config" 2>/dev/null; then
            echo "   ⚠️  Видаляємо конфігурацію з foryou: $(basename $config)"
            rm -f "$config"
            rm -f "/etc/nginx/sites-enabled/$(basename $config)" 2>/dev/null || true
        fi
    fi
done

# Створюємо правильну конфігурацію для system.pro-part.online
echo "📝 Створюємо конфігурацію для ${DOMAIN}..."

cat > /etc/nginx/sites-available/${DOMAIN} << 'NGINXEOF'
# HTTP - працюємо на HTTP (SSL можна додати пізніше)
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name system.pro-part.online *.pro-part.online;

    # Gzip Compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml+rss application/json application/javascript;

    # Client Max Body Size
    client_max_body_size 10M;

    # Frontend
    location / {
        proxy_pass http://localhost:3002;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection upgrade;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        proxy_read_timeout 300s;
        proxy_connect_timeout 75s;
    }

    # Backend API
    location /api {
        proxy_pass http://localhost:4001;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 300s;
        proxy_connect_timeout 75s;
    }

    # Health check
    location /health {
        proxy_pass http://localhost:4001/health;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        access_log off;
    }
}
NGINXEOF

# Активуємо конфігурацію
echo "🔗 Активуємо конфігурацію..."
ln -sf /etc/nginx/sites-available/${DOMAIN} /etc/nginx/sites-enabled/

# Перевіряємо конфігурацію
echo ""
echo "🔍 Перевірка Nginx конфігурації..."
if nginx -t; then
    echo "   ✅ Конфігурація валідна"
else
    echo "   ❌ Помилка в конфігурації!"
    echo ""
    echo "📋 Деталі помилки:"
    nginx -t 2>&1
    exit 1
fi

# Перезавантажуємо Nginx
echo ""
echo "🔄 Перезавантаження Nginx..."
systemctl reload nginx
echo "   ✅ Nginx перезавантажено"

# Перевіряємо статус
echo ""
echo "📊 Статус Nginx:"
systemctl status nginx --no-pager | head -5

# Перевіряємо активні конфігурації
echo ""
echo "📋 Активні конфігурації:"
ls -la /etc/nginx/sites-enabled/

# Перевіряємо чи запущені контейнери
echo ""
echo "🐳 Перевірка Docker контейнерів..."
if docker ps | grep -q "admin-pro-part-frontend\|3002"; then
    echo "   ✅ Frontend контейнер запущений (порт 3002)"
else
    echo "   ⚠️  Frontend контейнер не запущений на порту 3002"
    echo "   💡 Запустіть: cd /opt/admin-pro-part && docker ps -a | grep frontend"
fi

if docker ps | grep -q "admin-pro-part-backend\|4001"; then
    echo "   ✅ Backend контейнер запущений (порт 4001)"
else
    echo "   ⚠️  Backend контейнер не запущений на порту 4001"
    echo "   💡 Запустіть: cd /opt/admin-pro-part && docker ps -a | grep backend"
fi

# Тест запиту
echo ""
echo "🌐 Тест запиту до ${DOMAIN}..."
curl -I http://localhost:3002 2>&1 | head -5 || echo "   ⚠️  Frontend не відповідає на порту 3002"
curl -I http://localhost:4001/health 2>&1 | head -5 || echo "   ⚠️  Backend не відповідає на порту 4001"

echo ""
echo "✅ Виправлення завершено!"
echo ""
echo "🌐 Перевірте: http://${DOMAIN}"
echo ""

ENDSSH

echo ""
echo "✅ Скрипт виконано на сервері!"

