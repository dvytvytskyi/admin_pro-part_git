#!/bin/bash

# Скрипт для налаштування Nginx спочатку на HTTP, потім SSL

set -e

DOMAIN="admin.foryou-realestate.com"
PROJECT_DIR="/opt/admin-panel"

echo "🌐 Налаштування Nginx..."

# Крок 1: Використовуємо HTTP конфігурацію спочатку
echo "1️⃣ Встановлюємо HTTP конфігурацію..."
cp $PROJECT_DIR/deploy/nginx-http-only.conf /etc/nginx/sites-available/${DOMAIN}
ln -sf /etc/nginx/sites-available/${DOMAIN} /etc/nginx/sites-enabled/

# Перевірка та перезапуск
echo "2️⃣ Перевірка конфігурації..."
if nginx -t; then
    echo "✅ Конфігурація валідна"
    systemctl restart nginx
    echo "✅ Nginx перезапущено (HTTP)"
else
    echo "❌ Помилка в конфігурації!"
    exit 1
fi

# Крок 2: Встановлюємо SSL
echo ""
echo "3️⃣ Встановлення SSL сертифікату..."
echo "   (це може зайняти кілька хвилин)"

if certbot --nginx -d ${DOMAIN} --non-interactive --agree-tos --email admin@foryou-realestate.com --redirect 2>&1 | tee /tmp/certbot.log; then
    echo "✅ SSL сертифікат встановлено!"
    
    # Certbot автоматично оновлює конфігурацію, але перевіримо
    if nginx -t; then
        systemctl restart nginx
        echo "✅ Nginx перезапущено з SSL"
    else
        echo "⚠️  Помилка після встановлення SSL, перевірте конфігурацію"
    fi
else
    echo "⚠️  Не вдалося встановити SSL автоматично"
    echo "   Спробуйте вручну: certbot --nginx -d ${DOMAIN}"
    echo "   Або використовуйте HTTP версію поки що"
fi

echo ""
echo "✅ Налаштування завершено!"
echo "🌐 Сайт: http://${DOMAIN} (HTTP) або https://${DOMAIN} (HTTPS якщо SSL встановлено)"
echo ""
echo "📝 Перевірка:"
echo "   curl -I http://${DOMAIN}"
echo "   curl -I http://localhost:3001"

