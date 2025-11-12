#!/bin/bash

# Виконайте цей скрипт НА СЕРВЕРІ (ssh root@135.181.201.185)

set -e

echo "🔧 Виправлення Nginx для system.pro-part.online..."
echo ""

# Видаляємо default та старі конфігурації
echo "🗑️  Видаляємо конфліктуючі конфігурації..."
rm -f /etc/nginx/sites-enabled/default
rm -f /etc/nginx/sites-available/system.pro-part.online
rm -f /etc/nginx/sites-enabled/system.pro-part.online

# Створюємо правильну конфігурацію
echo "📝 Створюємо конфігурацію..."
cat > /etc/nginx/sites-available/system.pro-part.online << 'EOF'
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name system.pro-part.online _;

    location / {
        proxy_pass http://localhost:3002;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /api {
        proxy_pass http://localhost:4001;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /health {
        proxy_pass http://localhost:4001/health;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
    }
}
EOF

# Активуємо
echo "🔗 Активуємо конфігурацію..."
ln -sf /etc/nginx/sites-available/system.pro-part.online /etc/nginx/sites-enabled/

# Перевіряємо
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
curl -I http://system.pro-part.online 2>&1 | head -5

echo ""
echo "✅ Готово! Перевірте: http://system.pro-part.online"

