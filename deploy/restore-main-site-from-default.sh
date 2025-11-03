#!/bin/bash

# Скрипт для відновлення конфігурації основного сайту з default
# ТА ВИДАЛЕННЯ default_server щоб не було конфліктів

set -e

MAIN_DOMAIN="foryou-realestate.com"
NGINX_SITES_DIR="/etc/nginx/sites-available"
NGINX_ENABLED_DIR="/etc/nginx/sites-enabled"
DEFAULT_CONFIG="/etc/nginx/sites-available/default"
BACKUP_DIR="/etc/nginx/backup-$(date +%Y%m%d-%H%M%S)"

echo "🔍 Відновлення конфігурації основного сайту..."
echo ""

# Створюємо backup
mkdir -p "$BACKUP_DIR"
echo "📦 Створюємо backup конфігурацій..."
cp "$DEFAULT_CONFIG" "$BACKUP_DIR/default.backup" 2>/dev/null || true
cp "${NGINX_SITES_DIR}/${MAIN_DOMAIN}" "$BACKUP_DIR/${MAIN_DOMAIN}.backup" 2>/dev/null || true
echo "✅ Backup створено в: $BACKUP_DIR"
echo ""

# Показуємо що в default
echo "📄 Поточна default конфігурація:"
echo "=========================================="
grep -A 50 "server_name.*foryou\|default_server" "$DEFAULT_CONFIG" | head -60 || cat "$DEFAULT_CONFIG"
echo "=========================================="
echo ""

# Питаємо чи продовжити
read -p "Використати цю конфігурацію для ${MAIN_DOMAIN}? (yes/no): " confirm
if [ "$confirm" != "yes" ]; then
    echo "❌ Скасовано"
    exit 0
fi

echo ""
echo "🔧 Відновлення конфігурації..."

# Витягуємо server block для foryou з default
# Спочатку перевіримо чи є там proxy_pass або root
if grep -q "proxy_pass" "$DEFAULT_CONFIG"; then
    echo "   Знайдено proxy_pass в default конфігурації"
    # Витягуємо server block
    awk '/server {/,/^}/' "$DEFAULT_CONFIG" | grep -A 100 "server_name.*foryou" | sed '/^server {/d; /^}/d' > /tmp/foryou-server-block.txt || true
elif grep -q "root /var/www/html" "$DEFAULT_CONFIG"; then
    echo "   Знайдено root /var/www/html в default конфігурації"
fi

# Копіюємо весь default як початкову точку
cp "$DEFAULT_CONFIG" "/tmp/default-full.txt"

# Створюємо нову конфігурацію на основі default
cat > "${NGINX_SITES_DIR}/${MAIN_DOMAIN}" << 'EOF'
# Конфігурація Nginx для основного сайту foryou-realestate.com
# Відновлено з default конфігурації

# HTTP -> HTTPS redirect
server {
    listen 80;
    listen [::]:80;
    server_name foryou-realestate.com www.foryou-realestate.com;

    # Redirect HTTP to HTTPS
    return 301 https://$server_name$request_uri;
}

# HTTPS server
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name foryou-realestate.com www.foryou-realestate.com;

    # SSL Configuration
    ssl_certificate /etc/letsencrypt/live/foryou-realestate.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/foryou-realestate.com/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    # Security Headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # Gzip Compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml+rss application/json application/javascript;

    # Client Max Body Size
    client_max_body_size 50M;

EOF

# Тепер додаємо вміст з default (location blocks та інші налаштування)
echo ""
echo "📋 Копіювання location blocks та інших налаштувань з default..."

# Витягуємо все після ssl_dhparam до кінця server block
awk '/ssl_dhparam/,/^}/' "$DEFAULT_CONFIG" | grep -v "^}" | grep -v "default_server" >> "${NGINX_SITES_DIR}/${MAIN_DOMAIN}"

# Додаємо закриваючу дужку
echo "}" >> "${NGINX_SITES_DIR}/${MAIN_DOMAIN}"

# Перевіряємо чи є proxy_pass або root
if grep -q "proxy_pass" "${NGINX_SITES_DIR}/${MAIN_DOMAIN}"; then
    echo "✅ Конфігурація з proxy_pass скопійована"
elif grep -q "root /var/www/html" "${NGINX_SITES_DIR}/${MAIN_DOMAIN}"; then
    echo "✅ Конфігурація з root /var/www/html скопійована"
else
    echo "⚠️  Можливо потрібно додати location blocks вручну"
fi

# Видаляємо default_server з default конфігурації
echo ""
echo "🔧 Видалення default_server з default конфігурації..."
sed -i 's/default_server//g' "$DEFAULT_CONFIG"
sed -i '/server_name.*foryou/d' "$DEFAULT_CONFIG" || true

# Перевірка конфігурації
echo ""
echo "🔍 Перевірка конфігурації Nginx..."
if nginx -t 2>&1; then
    echo "✅ Конфігурація валідна"
else
    echo "❌ Помилка в конфігурації!"
    echo "   Відновлюємо з backup..."
    cp "$BACKUP_DIR/default.backup" "$DEFAULT_CONFIG"
    cp "$BACKUP_DIR/${MAIN_DOMAIN}.backup" "${NGINX_SITES_DIR}/${MAIN_DOMAIN}" 2>/dev/null || true
    exit 1
fi

# Перезапуск Nginx
echo ""
echo "🔄 Перезапуск Nginx..."
systemctl restart nginx
echo "✅ Nginx перезапущено"

echo ""
echo "✅ Готово!"
echo ""
echo "📋 Перевірка:"
echo "   curl -I https://${MAIN_DOMAIN}"
echo ""
echo "📦 Backup збережено в: $BACKUP_DIR"
