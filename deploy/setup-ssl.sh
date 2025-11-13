#!/bin/bash

# Налаштування SSL для system.pro-part.online

set -e

DOMAIN="system.pro-part.online"
EMAIL="admin@pro-part.online"

echo "🔒 Налаштування SSL для ${DOMAIN}..."
echo ""

# Перевіряємо чи встановлено certbot
if ! command -v certbot &> /dev/null; then
    echo "📦 Встановлення Certbot..."
    apt-get update
    apt-get install -y certbot python3-certbot-nginx
fi

# Перевіряємо поточну конфігурацію Nginx
if [ ! -f "/etc/nginx/sites-available/${DOMAIN}" ]; then
    echo "❌ Nginx конфігурація не знайдена!"
    echo "   Спочатку запустіть fix-nginx-on-server.sh"
    exit 1
fi

# Отримуємо SSL сертифікат
echo "🔐 Отримання SSL сертифікату..."
certbot --nginx -d ${DOMAIN} --non-interactive --agree-tos --email ${EMAIL} --redirect

# Перевіряємо
echo ""
echo "✅ SSL налаштовано!"
echo "🌐 Перевірте: https://${DOMAIN}"

