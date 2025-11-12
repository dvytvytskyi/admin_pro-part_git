#!/bin/bash

# Скрипт для виправлення Nginx redirect на system.pro-part.online
# Видаляє default конфігурацію та створює правильну для system.pro-part.online

set -e

SERVER_IP="135.181.201.185"
SERVER_USER="root"
DOMAIN="system.pro-part.online"
PROJECT_DIR="/opt/admin-pro-part"

echo "🔧 Виправлення Nginx конфігурації для ${DOMAIN}..."
echo ""

read -sp "Введіть пароль для root@${SERVER_IP}: " SERVER_PASSWORD
echo ""

sshpass -p "${SERVER_PASSWORD}" ssh -o StrictHostKeyChecking=no ${SERVER_USER}@${SERVER_IP} << ENDSSH
set -e

DOMAIN="${DOMAIN}"
PROJECT_DIR="${PROJECT_DIR}"

echo "🔍 Перевірка поточного стану..."

# Перевіряємо чи існує default конфігурація
if [ -L "/etc/nginx/sites-enabled/default" ]; then
    echo "⚠️  Знайдено default конфігурацію - видаляємо..."
    rm -f /etc/nginx/sites-enabled/default
    echo "   ✅ Видалено"
fi

# Перевіряємо чи є конфігурація для system.pro-part.online
if [ ! -f "/etc/nginx/sites-available/${DOMAIN}" ]; then
    echo "📝 Створення Nginx конфігурації для ${DOMAIN}..."
    
    cat > /etc/nginx/sites-available/${DOMAIN} << NGINXEOF
server {
    listen 80;
    server_name ${DOMAIN};
    
    # Redirect HTTP to HTTPS
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name ${DOMAIN};

    # SSL сертифікат (буде встановлено certbot)
    ssl_certificate /etc/letsencrypt/live/${DOMAIN}/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/${DOMAIN}/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    # Frontend
    location / {
        proxy_pass http://localhost:3002;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
    }

    # Backend API
    location /api {
        proxy_pass http://localhost:4001;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
NGINXEOF
    echo "   ✅ Створено"
else
    echo "   ⊘ Конфігурація вже існує"
fi

# Активуємо конфігурацію
if [ ! -L "/etc/nginx/sites-enabled/${DOMAIN}" ]; then
    echo "🔗 Активуємо конфігурацію..."
    ln -s /etc/nginx/sites-available/${DOMAIN} /etc/nginx/sites-enabled/
    echo "   ✅ Активовано"
else
    echo "   ⊘ Конфігурація вже активна"
fi

# Перевіряємо чи є SSL сертифікат
if [ ! -d "/etc/letsencrypt/live/${DOMAIN}" ]; then
    echo "🔒 Отримання SSL сертифікату..."
    certbot --nginx -d ${DOMAIN} --non-interactive --agree-tos --email admin@pro-part.online --redirect || {
        echo "   ⚠️  Не вдалося отримати SSL (можливо домен не налаштований)"
        echo "   💡 Створюємо тимчасову конфігурацію без SSL..."
        
        # Тимчасова конфігурація без SSL
        cat > /etc/nginx/sites-available/${DOMAIN} << NGINXEOF
server {
    listen 80;
    server_name ${DOMAIN};

    # Frontend
    location / {
        proxy_pass http://localhost:3002;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
    }

    # Backend API
    location /api {
        proxy_pass http://localhost:4001;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
NGINXEOF
    }
else
    echo "   ✅ SSL сертифікат вже існує"
fi

# Перевіряємо конфігурацію
echo ""
echo "🔍 Перевірка Nginx конфігурації..."
if nginx -t; then
    echo "   ✅ Конфігурація валідна"
else
    echo "   ❌ Помилка в конфігурації!"
    exit 1
fi

# Перезавантажуємо Nginx
echo ""
echo "🔄 Перезавантаження Nginx..."
systemctl reload nginx
echo "   ✅ Nginx перезавантажено"

# Перевіряємо чи запущені контейнери
echo ""
echo "🐳 Перевірка Docker контейнерів..."
if docker ps | grep -q "admin-pro-part-frontend"; then
    echo "   ✅ Frontend контейнер запущений"
else
    echo "   ⚠️  Frontend контейнер не запущений"
    echo "   💡 Запустіть: cd ${PROJECT_DIR} && docker-compose -f docker-compose.prod.yml up -d"
fi

if docker ps | grep -q "admin-pro-part-backend"; then
    echo "   ✅ Backend контейнер запущений"
else
    echo "   ⚠️  Backend контейнер не запущений"
    echo "   💡 Запустіть: cd ${PROJECT_DIR} && docker-compose -f docker-compose.prod.yml up -d"
fi

echo ""
echo "✅ Виправлення завершено!"
echo ""
echo "🌐 Перевірте: http://${DOMAIN} (або https://${DOMAIN} якщо SSL встановлено)"
echo ""
echo "📋 Поточні активні конфігурації:"
ls -la /etc/nginx/sites-enabled/

ENDSSH

echo ""
echo "✅ Скрипт виконано!"

