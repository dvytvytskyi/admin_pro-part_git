#!/bin/bash

# Автоматичне налаштування основного сайту foryou-realestate.com на порту 3000
# ВИКОРИСТОВУЙТЕ ЦЕЙ СКРИПТ НА СЕРВЕРІ!

set -e

MAIN_DOMAIN="foryou-realestate.com"
ADMIN_DOMAIN="admin.foryou-realestate.com"
PROJECT_DIR="/opt/admin-panel"
NGINX_SITES_DIR="/etc/nginx/sites-available"
NGINX_ENABLED_DIR="/etc/nginx/sites-enabled"
MAIN_PORT="3000"  # Основний сайт працює на порту 3000

if [ ! -d "/opt/admin-panel" ]; then
    echo "❌ Помилка: Цей скрипт має виконуватися на сервері!"
    exit 1
fi

echo "🌐 Налаштування основного сайту ${MAIN_DOMAIN} на порту ${MAIN_PORT}..."
echo ""

# 1. Перевірка чи конфігурація існує
if [ ! -f "${PROJECT_DIR}/deploy/nginx-main-site.conf" ]; then
    echo "❌ Файл конфігурації не знайдено: ${PROJECT_DIR}/deploy/nginx-main-site.conf"
    exit 1
fi

# 2. Перевірка чи порт 3000 зайнятий
if ! netstat -tln 2>/dev/null | grep -q ":${MAIN_PORT} " && ! ss -tln 2>/dev/null | grep -q ":${MAIN_PORT} "; then
    echo "⚠️  Порт ${MAIN_PORT} не зайнятий. Перевірте чи основний сайт запущений."
    read -p "Продовжити? (yes/no): " continue
    if [ "$continue" != "yes" ]; then
        exit 1
    fi
fi

# 3. Копіюємо конфігурацію і налаштовуємо порт
echo "📋 Копіювання конфігурації..."
cp "${PROJECT_DIR}/deploy/nginx-main-site.conf" "${NGINX_SITES_DIR}/${MAIN_DOMAIN}"

# 4. Замінюємо порт на 3000
echo "🔧 Налаштування порту ${MAIN_PORT}..."
sed -i "s|proxy_pass http://127.0.0.1:3000;|proxy_pass http://127.0.0.1:${MAIN_PORT};|" "${NGINX_SITES_DIR}/${MAIN_DOMAIN}"
sed -i "s|proxy_pass http://127.0.0.1:3000/api;|proxy_pass http://127.0.0.1:${MAIN_PORT}/api;|" "${NGINX_SITES_DIR}/${MAIN_DOMAIN}"

# 5. Створюємо симлінк
echo "🔗 Створення симлінку..."
ln -sf "${NGINX_SITES_DIR}/${MAIN_DOMAIN}" "${NGINX_ENABLED_DIR}/${MAIN_DOMAIN}"

# 6. Перевірка конфігурації
echo ""
echo "🔍 Перевірка конфігурації Nginx..."
if nginx -t 2>&1; then
    echo "✅ Конфігурація валідна"
else
    echo "❌ Помилка в конфігурації Nginx!"
    echo "   Перевірте: ${NGINX_SITES_DIR}/${MAIN_DOMAIN}"
    exit 1
fi

# 7. Перезапуск Nginx
echo ""
echo "🔄 Перезапуск Nginx..."
systemctl restart nginx
echo "✅ Nginx перезапущено"

# 8. SSL сертифікат
echo ""
echo "🔒 Перевірка SSL сертифікату..."
if [ -f "/etc/letsencrypt/live/${MAIN_DOMAIN}/fullchain.pem" ]; then
    echo "✅ SSL сертифікат вже встановлено"
else
    echo "⚠️  SSL сертифікат не знайдено"
    echo ""
    echo "📧 Встановлюємо SSL сертифікат..."
    certbot --nginx -d ${MAIN_DOMAIN} -d www.${MAIN_DOMAIN} --non-interactive --agree-tos --email admin@foryou-realestate.com --redirect 2>&1 || {
        echo "⚠️  Не вдалося встановити SSL автоматично"
        echo "   Встановіть вручну: certbot --nginx -d ${MAIN_DOMAIN} -d www.${MAIN_DOMAIN}"
    }
    systemctl restart nginx
fi

# 9. Фінальна перевірка
echo ""
echo "📊 Статус Nginx:"
systemctl status nginx --no-pager | head -5

echo ""
echo "📋 Активні конфігурації:"
ls -la ${NGINX_ENABLED_DIR}/ | grep -E "(foryou-realestate|admin)" || echo "   Немає активних конфігурацій"

echo ""
echo "✅ Готово!"
echo ""
echo "🌐 Домени:"
echo "   - https://${MAIN_DOMAIN} - основний сайт (порт ${MAIN_PORT})"
echo "   - https://www.${MAIN_DOMAIN} - основний сайт (www)"
echo "   - https://${ADMIN_DOMAIN} - адмін панель"
echo ""
echo "🧪 Перевірка:"
echo "   curl -I http://localhost:${MAIN_PORT}"
echo "   curl -I https://${MAIN_DOMAIN}"
