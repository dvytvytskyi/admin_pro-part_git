#!/bin/bash

# Скрипт для пошуку та відновлення конфігурації основного сайту foryou-realestate.com

set -e

MAIN_DOMAIN="foryou-realestate.com"
NGINX_SITES_DIR="/etc/nginx/sites-available"
NGINX_ENABLED_DIR="/etc/nginx/sites-enabled"
NGINX_CONF_DIR="/etc/nginx/conf.d"

echo "🔍 Пошук старої конфігурації для ${MAIN_DOMAIN}..."
echo ""

# 1. Перевірка поточних конфігурацій
echo "📋 Поточні конфігурації в sites-available:"
ls -la ${NGINX_SITES_DIR}/ | grep -i "foryou\|main" || echo "   Не знайдено"
echo ""

echo "📋 Активні конфігурації в sites-enabled:"
ls -la ${NGINX_ENABLED_DIR}/ | grep -i "foryou\|main" || echo "   Не знайдено"
echo ""

# 2. Перевірка конфігурацій в conf.d
echo "📋 Конфігурації в conf.d:"
if [ -d "${NGINX_CONF_DIR}" ]; then
    ls -la ${NGINX_CONF_DIR}/ | grep -i "foryou\|main" || echo "   Не знайдено"
else
    echo "   Директорія не існує"
fi
echo ""

# 3. Пошук в усіх конфігураціях Nginx
echo "🔍 Пошук згадок ${MAIN_DOMAIN} в конфігураціях Nginx..."
echo ""
grep -r "foryou-realestate.com" /etc/nginx/ 2>/dev/null | grep -v ".gz" | head -20 || echo "   Не знайдено згадок"
echo ""

# 4. Перевірка backup файлів
echo "📦 Пошук backup файлів..."
find /etc/nginx/ -name "*foryou*" -o -name "*main*" -o -name "*.bak" -o -name "*.backup" 2>/dev/null | head -10 || echo "   Не знайдено backup файлів"
echo ""

# 5. Перевірка чи є старий проект
echo "📁 Пошук старого проекту..."
if [ -d "/var/www" ]; then
    echo "Директорії в /var/www:"
    ls -la /var/www/ | grep -i "foryou\|realestate" || echo "   Не знайдено"
fi
if [ -d "/opt" ]; then
    echo ""
    echo "Директорії в /opt:"
    ls -la /opt/ | grep -i "foryou\|realestate" || echo "   Не знайдено"
fi
echo ""

# 6. Перевірка які процеси слухають порти
echo "🔌 Процеси на популярних портах:"
for port in 3000 5000 8080 8081; do
    echo "Порт ${port}:"
    netstat -tlnp 2>/dev/null | grep ":${port} " | head -1 || ss -tlnp 2>/dev/null | grep ":${port} " | head -1 || echo "   Вільний"
done
echo ""

# 7. Перевірка логів Nginx
echo "📝 Останні записи в логах Nginx (що стосуються foryou):"
if [ -f "/var/log/nginx/access.log" ]; then
    grep -i "foryou" /var/log/nginx/access.log 2>/dev/null | tail -5 || echo "   Не знайдено"
fi
echo ""

# 8. Перевірка чи працює сайт на домені
echo "🌐 Перевірка доступності сайту:"
if curl -s -o /dev/null -w "%{http_code}" --max-time 5 "http://${MAIN_DOMAIN}" 2>/dev/null | grep -q "200\|301\|302"; then
    echo "✅ Сайт доступний через HTTP"
    curl -I "http://${MAIN_DOMAIN}" 2>/dev/null | head -3
else
    echo "❌ Сайт не доступний через HTTP"
fi

if curl -s -o /dev/null -w "%{http_code}" --max-time 5 "https://${MAIN_DOMAIN}" 2>/dev/null | grep -q "200\|301\|302"; then
    echo "✅ Сайт доступний через HTTPS"
    curl -I "https://${MAIN_DOMAIN}" 2>/dev/null | head -3
else
    echo "❌ Сайт не доступний через HTTPS"
fi
echo ""

# 9. Рекомендації
echo "💡 Рекомендації:"
echo ""
echo "1. Якщо знайдено стару конфігурацію - відновіть її:"
echo "   cp /etc/nginx/sites-available/СТАРИЙ_ФАЙЛ /etc/nginx/sites-available/${MAIN_DOMAIN}"
echo "   ln -sf /etc/nginx/sites-available/${MAIN_DOMAIN} /etc/nginx/sites-enabled/"
echo "   nginx -t && systemctl restart nginx"
echo ""
echo "2. Якщо конфігурація не знайдена, але сайт працював:"
echo "   - Перевірте чи працює процес на якомусь порту"
echo "   - Можливо конфігурація була в default або іншому файлі"
echo "   - Перевірте /etc/nginx/nginx.conf на наявність server blocks"
echo ""
echo "3. Якщо нічого не знайдено - створіть нову конфігурацію:"
echo "   ./deploy/setup-main-site-interactive.sh"
echo ""

# 10. Перевірка default конфігурації
echo "📄 Перевірка default конфігурації:"
if [ -f "/etc/nginx/sites-available/default" ]; then
    if grep -q "foryou-realestate.com\|server_name.*foryou" /etc/nginx/sites-available/default 2>/dev/null; then
        echo "⚠️  Знайдено згадку foryou в default конфігурації!"
        echo "   Можливо там була конфігурація основного сайту"
        grep -A 10 "server_name.*foryou\|foryou-realestate" /etc/nginx/sites-available/default | head -15
    else
        echo "   Не знайдено"
    fi
else
    echo "   Файл не існує"
fi

echo ""
echo "✅ Перевірка завершена!"
