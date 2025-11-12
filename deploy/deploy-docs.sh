#!/bin/bash

set -e

echo "🚀 Деплой API документації на docs.pro-part.online..."

# Кольори для виводу
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Конфігурація сервера
SERVER_IP="88.99.38.25"
SERVER_USER="root"
SERVER_PASSWORD="VandiPCEXeep"
DOMAIN="docs.pro-part.online"
PROJECT_DIR="/opt/admin-pro-part"

# Функція для виконання команд на сервері
ssh_exec() {
    sshpass -p "${SERVER_PASSWORD}" ssh -o StrictHostKeyChecking=no ${SERVER_USER}@${SERVER_IP} "$1"
}

# Функція для копіювання файлів на сервер
scp_copy() {
    local source="$1"
    local dest="$2"
    local filename=$(basename "$source")
    echo -e "${BLUE}  → Копіювання $filename...${NC}"
    sshpass -p "${SERVER_PASSWORD}" scp -o StrictHostKeyChecking=no -r "$source" ${SERVER_USER}@${SERVER_IP}:"$dest"
    echo -e "${GREEN}  ✓ $filename скопійовано${NC}"
}

echo -e "${BLUE}📋 Конфігурація:${NC}"
echo -e "  Server: ${SERVER_USER}@${SERVER_IP}"
echo -e "  Domain: ${DOMAIN}"
echo -e "  Project Dir: ${PROJECT_DIR}"

# Копіюємо нову сторінку документації
echo -e "\n${YELLOW}📤 Копіювання файлів документації...${NC}"
scp_copy "/Users/vytvytskyi/admin_pro-part/admin-panel/src/app/docs/page.tsx" "${PROJECT_DIR}/admin-panel/src/app/docs/"
scp_copy "/Users/vytvytskyi/admin_pro-part/admin-panel/src/app/docs/layout.tsx" "${PROJECT_DIR}/admin-panel/src/app/docs/"
scp_copy "/Users/vytvytskyi/admin_pro-part/deploy/nginx-docs.conf" "${PROJECT_DIR}/"

# Перебудовуємо frontend
echo -e "\n${YELLOW}🔨 Перебудова frontend...${NC}"
ssh_exec "cd ${PROJECT_DIR} && docker compose -f docker-compose.prod.yml build admin-panel-frontend --no-cache 2>&1 | tail -10"

# Перезапускаємо frontend
echo -e "\n${YELLOW}🚀 Перезапуск frontend...${NC}"
ssh_exec "cd ${PROJECT_DIR} && docker compose -f docker-compose.prod.yml up -d admin-panel-frontend"

# Налаштування Nginx
echo -e "\n${YELLOW}🌐 Налаштування Nginx...${NC}"
ssh_exec "cp ${PROJECT_DIR}/nginx-docs.conf /etc/nginx/sites-available/${DOMAIN}"
ssh_exec "ln -sf /etc/nginx/sites-available/${DOMAIN} /etc/nginx/sites-enabled/"

# Тестування конфігурації Nginx
echo -e "\n${YELLOW}✅ Тестування конфігурації Nginx...${NC}"
NGINX_TEST=$(ssh_exec "nginx -t 2>&1")
if echo "$NGINX_TEST" | grep -q "syntax is ok"; then
    echo -e "${GREEN}✅ Nginx конфігурація валідна${NC}"
else
    echo -e "${RED}❌ Помилка в конфігурації Nginx:${NC}"
    echo "$NGINX_TEST"
    exit 1
fi

# Перезавантаження Nginx
ssh_exec "systemctl reload nginx"

# Отримання SSL сертифікату
echo -e "\n${YELLOW}🔒 Отримання SSL сертифікату...${NC}"
# Спочатку перезапускаємо nginx з HTTP конфігурацією
ssh_exec "sed -i 's/listen 443/listen 80 #listen 443/' /etc/nginx/sites-available/${DOMAIN} || true"
ssh_exec "sed -i 's/ssl_certificate/#ssl_certificate/' /etc/nginx/sites-available/${DOMAIN} || true"
ssh_exec "systemctl reload nginx"

# Отримуємо сертифікат
echo -e "${YELLOW}Отримання SSL сертифікату через certbot...${NC}"
ssh_exec "certbot --nginx -d ${DOMAIN} --non-interactive --agree-tos --email admin@pro-part.online --redirect || certbot certonly --nginx -d ${DOMAIN} --non-interactive --agree-tos --email admin@pro-part.online"

# Відновлюємо повну конфігурацію
scp_copy "/Users/vytvytskyi/admin_pro-part/deploy/nginx-docs.conf" "/etc/nginx/sites-available/${DOMAIN}"
ssh_exec "systemctl reload nginx"

echo -e "\n${GREEN}✅ Деплой документації завершено!${NC}"
echo -e "${GREEN}🌐 Документація доступна за адресою: https://${DOMAIN}${NC}"

