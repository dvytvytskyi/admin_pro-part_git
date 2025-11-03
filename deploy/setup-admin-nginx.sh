#!/bin/bash

set -e

PROJECT_DIR="/opt/admin-panel"
DOMAIN="admin.foryou-realestate.com"
NGINX_CONFIG="/etc/nginx/sites-available/${DOMAIN}"

echo "🌐 Налаштування Nginx для адмін панелі..."
echo ""

# Перевірка чи є проект
if [ ! -d "$PROJECT_DIR" ]; then
    echo "❌ Проект не знайдено в $PROJECT_DIR"
    exit 1
fi

# Перевірка чи є nginx.conf
if [ ! -f "$PROJECT_DIR/deploy/nginx.conf" ]; then
    echo "❌ Не знайдено $PROJECT_DIR/deploy/nginx.conf"
    exit 1
fi

# Копіюємо конфігурацію
echo "📋 Копіювання конфігурації Nginx..."
cp $PROJECT_DIR/deploy/nginx.conf $NGINX_CONFIG

# Створюємо симлінк
echo "🔗 Створення симлінку..."
ln -sf $NGINX_CONFIG /etc/nginx/sites-enabled/${DOMAIN}

# Перевірка чи не конфліктує default
if [ -f "/etc/nginx/sites-enabled/default" ]; then
    if grep -q "admin.foryou-realestate.com" /etc/nginx/sites-enabled/default 2>/dev/null; then
        echo "⚠️  Видаляю default конфігурацію (конфлікт)..."
        rm -f /etc/nginx/sites-enabled/default
    fi
fi

# Перевірка конфігурації
echo "✅ Перевірка конфігурації Nginx..."
if nginx -t; then
    echo "✅ Конфігурація валідна"
else
    echo "❌ Помилка в конфігурації Nginx!"
    exit 1
fi

# Перезапуск Nginx
echo "🔄 Перезапуск Nginx..."
systemctl restart nginx
systemctl status nginx --no-pager | head -5

echo ""
echo "✅ Nginx налаштовано!"
echo "🌐 Домен: https://${DOMAIN}"
echo ""
echo "📝 Перевірте статус Docker контейнерів:"
echo "   cd $PROJECT_DIR && docker-compose -f docker-compose.prod.yml ps"

