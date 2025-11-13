#!/bin/bash

# Команди для ручного виконання на сервері
# Скопіюйте та виконайте ці команди на сервері через SSH або консоль

echo "🔧 Команди для виправлення Nginx на сервері"
echo "============================================"
echo ""
echo "Виконайте ці команди на сервері (root@135.181.201.185):"
echo ""

cat << 'COMMANDS'
# 1. Видаляємо всі конфліктуючі конфігурації
echo "🗑️  Видаляємо конфліктуючі конфігурації..."
rm -f /etc/nginx/sites-enabled/default
rm -f /etc/nginx/sites-available/default
rm -f /etc/nginx/sites-enabled/*admin.foryou* 2>/dev/null || true
rm -f /etc/nginx/sites-available/*admin.foryou* 2>/dev/null || true
rm -f /etc/nginx/sites-enabled/system.pro-part.online 2>/dev/null || true
rm -f /etc/nginx/sites-available/system.pro-part.online 2>/dev/null || true

# 2. Перевіряємо та видаляємо конфігурації з foryou
echo "🔍 Перевірка наявних конфігурацій..."
for config in /etc/nginx/sites-enabled/*; do
    if [ -f "$config" ]; then
        if grep -q "admin.foryou-realestate.com\|foryou-realestate" "$config" 2>/dev/null; then
            echo "   ⚠️  Видаляємо: $(basename $config)"
            rm -f "$config"
            rm -f "/etc/nginx/sites-available/$(basename $config)" 2>/dev/null || true
        fi
    fi
done

for config in /etc/nginx/sites-available/*; do
    if [ -f "$config" ]; then
        if grep -q "admin.foryou-realestate.com\|foryou-realestate" "$config" 2>/dev/null; then
            echo "   ⚠️  Видаляємо: $(basename $config)"
            rm -f "$config"
            rm -f "/etc/nginx/sites-enabled/$(basename $config)" 2>/dev/null || true
        fi
    fi
done

# 3. Створюємо правильну конфігурацію для system.pro-part.online
echo "📝 Створюємо конфігурацію для system.pro-part.online..."

cat > /etc/nginx/sites-available/system.pro-part.online << 'NGINXEOF'
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

# 4. Активуємо конфігурацію
echo "🔗 Активуємо конфігурацію..."
ln -sf /etc/nginx/sites-available/system.pro-part.online /etc/nginx/sites-enabled/

# 5. Перевіряємо конфігурацію
echo ""
echo "🔍 Перевірка Nginx конфігурації..."
if nginx -t; then
    echo "   ✅ Конфігурація валідна"
else
    echo "   ❌ Помилка в конфігурації!"
    nginx -t 2>&1
    exit 1
fi

# 6. Перезавантажуємо Nginx
echo ""
echo "🔄 Перезавантаження Nginx..."
systemctl reload nginx
echo "   ✅ Nginx перезавантажено"

# 7. Перевіряємо результат
echo ""
echo "📋 Активні конфігурації:"
ls -la /etc/nginx/sites-enabled/

echo ""
echo "🐳 Перевірка Docker контейнерів:"
docker ps | grep -E "admin-pro-part|3002|4001" || echo "   ⚠️  Контейнери не знайдено"

echo ""
echo "🌐 Тест запиту:"
curl -I http://localhost:3002 2>&1 | head -3 || echo "   ⚠️  Frontend не відповідає"
curl -I http://localhost:4001/health 2>&1 | head -3 || echo "   ⚠️  Backend не відповідає"

echo ""
echo "✅ Готово! Перевірте: http://system.pro-part.online"
COMMANDS

echo ""
echo "============================================"
echo "Або виконайте весь скрипт одразу:"
echo ""
echo "bash <(curl -s https://raw.githubusercontent.com/dvytvytskyi/admin_pro-part_git/main/deploy/fix-nginx-propart-complete.sh)"
echo ""
echo "Або скопіюйте файл на сервер:"
echo "scp deploy/fix-nginx-propart-complete.sh root@135.181.201.185:/tmp/"
echo "ssh root@135.181.201.185 'bash /tmp/fix-nginx-propart-complete.sh'"

