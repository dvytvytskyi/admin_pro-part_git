#!/bin/bash

# Простий скрипт для виправлення Nginx - створює мінімальну робочу конфігурацію

set -e

SERVER_IP="135.181.201.185"
SERVER_USER="root"
DOMAIN="system.pro-part.online"

echo "🔧 Створення простої Nginx конфігурації для ${DOMAIN}..."
echo ""

read -sp "Введіть пароль для root@${SERVER_IP}: " SERVER_PASSWORD
echo ""

sshpass -p "${SERVER_PASSWORD}" ssh -o StrictHostKeyChecking=no ${SERVER_USER}@${SERVER_IP} << 'ENDSSH'
set -e

DOMAIN="system.pro-part.online"

# Видаляємо старі конфігурації
rm -f /etc/nginx/sites-available/${DOMAIN}
rm -f /etc/nginx/sites-enabled/${DOMAIN}

# Створюємо просту конфігурацію БЕЗ SSL спочатку
cat > /etc/nginx/sites-available/${DOMAIN} << 'NGINXEOF'
server {
    listen 80;
    server_name system.pro-part.online;

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
}
NGINXEOF

# Активуємо
ln -s /etc/nginx/sites-available/${DOMAIN} /etc/nginx/sites-enabled/

# Перевіряємо
echo "🔍 Перевірка конфігурації..."
if nginx -t 2>&1; then
    echo "✅ Конфігурація валідна!"
    systemctl reload nginx
    echo "✅ Nginx перезавантажено"
    echo ""
    echo "🌐 Перевірте: http://${DOMAIN}"
else
    echo "❌ Помилка в конфігурації"
    echo "📄 Вміст файлу:"
    cat /etc/nginx/sites-available/${DOMAIN}
    exit 1
fi

ENDSSH

echo ""
echo "✅ Готово!"

