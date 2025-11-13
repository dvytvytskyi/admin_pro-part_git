#!/bin/bash

# Скрипт для виправлення Nginx redirect на system.pro-part.online
# Видаляє всі редиректи на admin.foryou-realestate.com

set -e

SERVER_IP="135.181.201.185"
SERVER_USER="root"
DOMAIN="system.pro-part.online"

echo "🔧 Виправлення Nginx редиректів для ${DOMAIN}..."
echo ""

read -sp "Введіть пароль для root@${SERVER_IP}: " SERVER_PASSWORD
echo ""

sshpass -p "${SERVER_PASSWORD}" ssh -o StrictHostKeyChecking=no ${SERVER_USER}@${SERVER_IP} << 'ENDSSH'
set -e

DOMAIN="system.pro-part.online"

echo "🔍 Перевірка поточних конфігурацій..."

# 1. Видаляємо всі конфігурації з foryou
echo ""
echo "🗑️  Видаляємо конфігурації з foryou..."
rm -f /etc/nginx/sites-enabled/*admin.foryou* 2>/dev/null || true
rm -f /etc/nginx/sites-available/*admin.foryou* 2>/dev/null || true

# Перевіряємо всі конфігурації на наявність редиректів на foryou
for config in /etc/nginx/sites-enabled/* /etc/nginx/sites-available/*; do
    if [ -f "$config" ]; then
        if grep -q "admin.foryou-realestate.com\|foryou-realestate" "$config" 2>/dev/null; then
            echo "   ⚠️  Знайдено редирект на foryou в: $(basename $config)"
            echo "   🗑️  Видаляємо..."
            rm -f "$config"
        fi
    fi
done

# 2. Видаляємо default конфігурацію якщо вона редиректить
if [ -L "/etc/nginx/sites-enabled/default" ] || [ -f "/etc/nginx/sites-enabled/default" ]; then
    if grep -q "admin.foryou-realestate.com\|foryou-realestate" /etc/nginx/sites-enabled/default 2>/dev/null; then
        echo "   ⚠️  Default конфігурація містить редирект на foryou - видаляємо..."
        rm -f /etc/nginx/sites-enabled/default
    fi
fi

# 3. Перевіряємо чи є правильна конфігурація для system.pro-part.online
echo ""
echo "📋 Перевірка конфігурації ${DOMAIN}..."

if [ -f "/etc/nginx/sites-available/${DOMAIN}" ]; then
    echo "   ✅ Конфігурація існує"
    
    # Перевіряємо чи є редирект на foryou
    if grep -q "admin.foryou-realestate.com\|foryou-realestate" "/etc/nginx/sites-available/${DOMAIN}" 2>/dev/null; then
        echo "   ⚠️  Знайдено редирект на foryou - виправляємо..."
    else
        echo "   ✅ Редиректів на foryou не знайдено"
    fi
else
    echo "   ❌ Конфігурація не знайдена - створюємо..."
fi

# 4. Створюємо/оновлюємо правильну конфігурацію
echo ""
echo "📝 Створення правильної конфігурації..."

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
}
NGINXEOF

# Якщо SSL сертифікат не існує, створюємо тимчасову конфігурацію без SSL
if [ ! -d "/etc/letsencrypt/live/${DOMAIN}" ]; then
    echo "   ⚠️  SSL сертифікат не знайдено - створюємо тимчасову конфігурацію..."
    cat > /etc/nginx/sites-available/${DOMAIN} << 'NGINXEOF'
server {
    listen 80;
    server_name system.pro-part.online;

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
}
NGINXEOF
fi

# 5. Активуємо конфігурацію
echo ""
echo "🔗 Активуємо конфігурацію..."
rm -f /etc/nginx/sites-enabled/${DOMAIN}
ln -s /etc/nginx/sites-available/${DOMAIN} /etc/nginx/sites-enabled/
echo "   ✅ Активовано"

# 6. Перевіряємо конфігурацію
echo ""
echo "🔍 Перевірка Nginx конфігурації..."
if nginx -t 2>&1; then
    echo "   ✅ Конфігурація валідна"
else
    echo "   ❌ Помилка в конфігурації!"
    echo "   📄 Деталі помилки:"
    nginx -t 2>&1 || true
    exit 1
fi

# 7. Перезавантажуємо Nginx
echo ""
echo "🔄 Перезавантаження Nginx..."
systemctl reload nginx
echo "   ✅ Nginx перезавантажено"

# 8. Перевіряємо результат
echo ""
echo "📋 Активні конфігурації:"
ls -la /etc/nginx/sites-enabled/
echo ""

echo "🔍 Перевірка наявності редиректів на foryou:"
if grep -r "admin.foryou-realestate.com\|foryou-realestate" /etc/nginx/sites-enabled/ 2>/dev/null; then
    echo "   ⚠️  Все ще знайдено редиректи на foryou!"
else
    echo "   ✅ Редиректів на foryou не знайдено"
fi

echo ""
echo "✅ Виправлення завершено!"
echo ""
echo "🌐 Перевірте: https://${DOMAIN}"

ENDSSH

echo ""
echo "✅ Скрипт виконано!"

