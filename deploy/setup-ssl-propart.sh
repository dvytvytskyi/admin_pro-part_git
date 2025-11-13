#!/bin/bash

# Налаштування SSL для system.pro-part.online

set -e

DOMAIN="system.pro-part.online"
EMAIL="admin@pro-part.online"

echo "🔒 Налаштування SSL для ${DOMAIN}..."
echo ""

# Перевірка DNS
echo "🔍 Перевірка DNS..."
DNS_IP=$(dig +short ${DOMAIN} | tail -n1)
SERVER_IP=$(curl -s ifconfig.me || curl -s ipinfo.io/ip)

echo "   DNS вказує на: ${DNS_IP}"
echo "   Сервер має IP: ${SERVER_IP}"

if [ "$DNS_IP" != "$SERVER_IP" ]; then
    echo "⚠️  УВАГА: DNS не вказує на цей сервер!"
    echo "   Налаштуйте A запис: ${DOMAIN} -> ${SERVER_IP}"
    echo "   Продовжити все одно? (y/n)"
    read -r answer
    if [ "$answer" != "y" ]; then
        exit 1
    fi
fi

# Перевірка чи встановлено certbot
if ! command -v certbot &> /dev/null; then
    echo "📦 Встановлення Certbot..."
    apt-get update -qq
    apt-get install -y certbot python3-certbot-nginx
fi

# Перевірка Nginx конфігурації
if [ ! -f "/etc/nginx/sites-available/${DOMAIN}" ]; then
    echo "❌ Nginx конфігурація не знайдена!"
    echo "   Створюємо базову конфігурацію..."
    
    cat > /etc/nginx/sites-available/${DOMAIN} << 'NGINXEOF'
server {
    listen 80;
    listen [::]:80;
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

    location /health {
        proxy_pass http://localhost:4001/health;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
    }
}
NGINXEOF

    ln -sf /etc/nginx/sites-available/${DOMAIN} /etc/nginx/sites-enabled/
    nginx -t && systemctl reload nginx
    echo "✅ Базова конфігурація створена"
fi

# Отримання SSL сертифікату
echo ""
echo "🔐 Отримання SSL сертифікату через Certbot..."
echo "   Це може зайняти кілька хвилин..."

# Спробуємо отримати сертифікат
if certbot --nginx -d ${DOMAIN} --non-interactive --agree-tos --email ${EMAIL} --redirect; then
    echo ""
    echo "✅ SSL сертифікат успішно встановлено!"
    echo ""
    echo "🌐 Перевірте: https://${DOMAIN}"
    echo ""
    echo "📋 Статус сертифікату:"
    certbot certificates | grep -A 5 "${DOMAIN}" || echo "   Деталі: certbot certificates"
else
    echo ""
    echo "❌ Не вдалося отримати SSL сертифікат"
    echo ""
    echo "Можливі причини:"
    echo "   1. DNS не налаштовано правильно"
    echo "   2. Домен не вказує на цей сервер (${SERVER_IP})"
    echo "   3. Порт 80 заблоковано firewall"
    echo ""
    echo "Перевірте:"
    echo "   - DNS: dig ${DOMAIN}"
    echo "   - Firewall: ufw status"
    echo "   - Nginx: systemctl status nginx"
    echo ""
    echo "Детальні логи: /var/log/letsencrypt/letsencrypt.log"
    exit 1
fi

# Перезавантаження Nginx
echo ""
echo "🔄 Перезавантаження Nginx..."
systemctl reload nginx

echo ""
echo "✅ SSL налаштовано успішно!"
echo "🌐 Сайт доступний: https://${DOMAIN}"

