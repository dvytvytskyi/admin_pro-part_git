#!/bin/bash

# Повне виправлення Nginx для system.pro-part.online
# Видаляє всі конфліктуючі конфігурації та створює правильну

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
        if grep -q "admin.foryou-realestate.com" "$config" 2>/dev/null; then
            echo "   ⚠️  Видаляємо конфігурацію з foryou: $(basename $config)"
            rm -f "$config"
            rm -f "/etc/nginx/sites-available/$(basename $config)" 2>/dev/null || true
        fi
    fi
done

# Створюємо правильну конфігурацію для system.pro-part.online
echo "📝 Створюємо конфігурацію для ${DOMAIN}..."

cat > /etc/nginx/sites-available/${DOMAIN} << EOF
# HTTP - перенаправлення на HTTPS (якщо SSL встановлено)
server {
    listen 80;
    listen [::]:80;
    server_name ${DOMAIN} *.pro-part.online;
    
    # Якщо SSL встановлено - редирект на HTTPS
    # Якщо ні - працюємо на HTTP
    # return 301 https://\$server_name\$request_uri;
}

# HTTPS (якщо SSL встановлено)
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name ${DOMAIN} *.pro-part.online;

    # SSL сертифікат (якщо встановлено)
    # ssl_certificate /etc/letsencrypt/live/${DOMAIN}/fullchain.pem;
    # ssl_certificate_key /etc/letsencrypt/live/${DOMAIN}/privkey.pem;
    # ssl_protocols TLSv1.2 TLSv1.3;
    # ssl_ciphers HIGH:!aNULL:!MD5;

    # Gzip Compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml+rss application/json application/javascript;

    # Client Max Body Size
    client_max_body_size 10M;

    # Frontend
    location / {
        proxy_pass http://localhost:${FRONTEND_PORT};
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection upgrade;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
        proxy_read_timeout 300s;
        proxy_connect_timeout 75s;
    }

    # Backend API
    location /api {
        proxy_pass http://localhost:${BACKEND_PORT};
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_read_timeout 300s;
        proxy_connect_timeout 75s;
    }

    # Health check
    location /health {
        proxy_pass http://localhost:${BACKEND_PORT}/health;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        access_log off;
    }
}
EOF

# Якщо SSL встановлено, розкоментуємо SSL блок
if [ -d "/etc/letsencrypt/live/${DOMAIN}" ]; then
    echo "   ✅ SSL сертифікат знайдено - активуємо HTTPS..."
    sed -i 's/# return 301/return 301/' /etc/nginx/sites-available/${DOMAIN}
    sed -i 's/# ssl_certificate/ssl_certificate/' /etc/nginx/sites-available/${DOMAIN}
    sed -i 's/# ssl_certificate_key/ssl_certificate_key/' /etc/nginx/sites-available/${DOMAIN}
    sed -i 's/# ssl_protocols/ssl_protocols/' /etc/nginx/sites-available/${DOMAIN}
    sed -i 's/# ssl_ciphers/ssl_ciphers/' /etc/nginx/sites-available/${DOMAIN}
else
    echo "   ⚠️  SSL сертифікат не знайдено - працюємо на HTTP"
fi

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
    echo "   ✅ Frontend контейнер запущений (порт ${FRONTEND_PORT})"
else
    echo "   ⚠️  Frontend контейнер не запущений на порту ${FRONTEND_PORT}"
fi

if docker ps | grep -q "admin-pro-part-backend\|4001"; then
    echo "   ✅ Backend контейнер запущений (порт ${BACKEND_PORT})"
else
    echo "   ⚠️  Backend контейнер не запущений на порту ${BACKEND_PORT}"
fi

# Тест запиту
echo ""
echo "🌐 Тест запиту до ${DOMAIN}..."
curl -I http://${DOMAIN} 2>&1 | head -10 || echo "   ⚠️  Не вдалося зробити запит"

echo ""
echo "✅ Виправлення завершено!"
echo ""
echo "🌐 Перевірте: http://${DOMAIN} (або https://${DOMAIN} якщо SSL встановлено)"
echo ""

