#!/bin/bash

set -e

echo "🚀 Початок деплою Admin Panel на admin.pro-part.online..."

# Перевірка, чи не запущений вже процес деплою
if pgrep -f "deploy-pro-part.sh" | grep -v $$ > /dev/null; then
    echo "⚠️  Знайдено запущений процес деплою. Зупиняю..."
    pkill -f "deploy-pro-part.sh" || true
    sleep 2
fi

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
DOMAIN="admin.pro-part.online"
PROJECT_DIR="/opt/admin-pro-part"
LOCAL_PROJECT_DIR="/Users/vytvytskyi/admin_pro-part"

echo -e "${BLUE}📋 Конфігурація:${NC}"
echo -e "  Server: ${SERVER_USER}@${SERVER_IP}"
echo -e "  Domain: ${DOMAIN}"
echo -e "  Project Dir: ${PROJECT_DIR}"

# Функція для виконання команд на сервері
ssh_exec() {
    sshpass -p "${SERVER_PASSWORD}" ssh -o StrictHostKeyChecking=no ${SERVER_USER}@${SERVER_IP} "$1"
}

# Функція для копіювання файлів на сервер (виключає node_modules)
scp_copy() {
    local source="$1"
    local dest="$2"
    local filename=$(basename "$source")
    echo -e "${BLUE}  → Копіювання $filename (без node_modules)...${NC}"
    # Використовуємо rsync для виключення node_modules та інших непотрібних файлів
    sshpass -p "${SERVER_PASSWORD}" rsync -avz --progress \
        --exclude 'node_modules' \
        --exclude '.next' \
        --exclude 'dist' \
        --exclude '.git' \
        --exclude '*.log' \
        --exclude '.env.local' \
        -e "ssh -o StrictHostKeyChecking=no" \
        "$source" ${SERVER_USER}@${SERVER_IP}:"$dest"
    echo -e "${GREEN}  ✓ $filename скопійовано${NC}"
}

echo -e "\n${YELLOW}📦 Перевірка та встановлення необхідних пакетів на сервері...${NC}"
ssh_exec "apt update && apt install -y curl git docker.io docker-compose-plugin nginx certbot python3-certbot-nginx sshpass rsync || true"

echo -e "\n${YELLOW}🐳 Перевірка Docker...${NC}"
ssh_exec "systemctl enable docker && systemctl start docker"

echo -e "\n${YELLOW}📁 Створення директорії проекту...${NC}"
ssh_exec "mkdir -p ${PROJECT_DIR} && mkdir -p ${PROJECT_DIR}/admin-panel-backend/uploads"

echo -e "\n${YELLOW}📤 Копіювання файлів проекту на сервер...${NC}"
# Копіюємо основні файли
scp_copy "${LOCAL_PROJECT_DIR}/docker-compose.prod.yml" "${PROJECT_DIR}/"

echo -e "${YELLOW}  ⏳ Копіювання admin-panel (без node_modules - швидко)...${NC}"
scp_copy "${LOCAL_PROJECT_DIR}/admin-panel" "${PROJECT_DIR}/"

echo -e "${YELLOW}  ⏳ Копіювання admin-panel-backend (без node_modules - швидко)...${NC}"
scp_copy "${LOCAL_PROJECT_DIR}/admin-panel-backend" "${PROJECT_DIR}/"

scp_copy "${LOCAL_PROJECT_DIR}/deploy/nginx-pro-part.conf" "${PROJECT_DIR}/"

echo -e "\n${YELLOW}📝 Перевірка .env файлів...${NC}"
# Перевіряємо, чи існують .env файли на сервері
ENV_EXISTS=$(ssh_exec "test -f ${PROJECT_DIR}/.env && echo 'yes' || echo 'no'")
if [ "$ENV_EXISTS" = "no" ]; then
    echo -e "${RED}⚠️  УВАГА: .env файл не знайдено на сервері!${NC}"
    echo -e "${YELLOW}Будь ласка, створіть .env файл на сервері в ${PROJECT_DIR}/.env${NC}"
    echo -e "${YELLOW}Та ${PROJECT_DIR}/admin-panel-backend/.env${NC}"
    read -p "Продовжити деплой? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo -e "\n${YELLOW}🐳 Зупинка старих контейнерів...${NC}"
ssh_exec "cd ${PROJECT_DIR} && docker compose -f docker-compose.prod.yml down || true"

echo -e "\n${YELLOW}🔨 Будівництво Docker образів...${NC}"
ssh_exec "cd ${PROJECT_DIR} && docker compose -f docker-compose.prod.yml build --no-cache"

echo -e "\n${YELLOW}🚀 Запуск Docker контейнерів...${NC}"
ssh_exec "cd ${PROJECT_DIR} && docker compose -f docker-compose.prod.yml up -d"

echo -e "\n${YELLOW}⏳ Очікування запуску сервісів...${NC}"
sleep 15

echo -e "\n${YELLOW}🌐 Налаштування Nginx...${NC}"
ssh_exec "cp ${PROJECT_DIR}/nginx-pro-part.conf /etc/nginx/sites-available/${DOMAIN}"
ssh_exec "ln -sf /etc/nginx/sites-available/${DOMAIN} /etc/nginx/sites-enabled/"
ssh_exec "rm -f /etc/nginx/sites-enabled/default"

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
ssh_exec "systemctl restart nginx"
ssh_exec "systemctl enable nginx"

echo -e "\n${YELLOW}🔒 Отримання SSL сертифікату...${NC}"
# Спочатку перезапускаємо nginx з HTTP конфігурацією
ssh_exec "sed -i 's/listen 443/listen 80 #listen 443/' /etc/nginx/sites-available/${DOMAIN} || true"
ssh_exec "sed -i 's/ssl_certificate/#ssl_certificate/' /etc/nginx/sites-available/${DOMAIN} || true"
ssh_exec "systemctl reload nginx"

# Отримуємо сертифікат
echo -e "${YELLOW}Отримання SSL сертифікату через certbot...${NC}"
ssh_exec "certbot --nginx -d ${DOMAIN} --non-interactive --agree-tos --email admin@pro-part.online --redirect || certbot certonly --nginx -d ${DOMAIN} --non-interactive --agree-tos --email admin@pro-part.online"

# Відновлюємо повну конфігурацію
scp_copy "${LOCAL_PROJECT_DIR}/deploy/nginx-pro-part.conf" "/etc/nginx/sites-available/${DOMAIN}"
ssh_exec "systemctl reload nginx"

echo -e "\n${YELLOW}✅ Перевірка статусу сервісів...${NC}"
ssh_exec "cd ${PROJECT_DIR} && docker compose -f docker-compose.prod.yml ps"

echo -e "\n${YELLOW}📊 Перевірка логів...${NC}"
echo -e "${BLUE}Backend logs:${NC}"
ssh_exec "cd ${PROJECT_DIR} && docker compose -f docker-compose.prod.yml logs --tail=20 admin-panel-backend"
echo -e "\n${BLUE}Frontend logs:${NC}"
ssh_exec "cd ${PROJECT_DIR} && docker compose -f docker-compose.prod.yml logs --tail=20 admin-panel-frontend"

echo -e "\n${GREEN}✅ Деплой завершено!${NC}"
echo -e "${GREEN}🌐 Сайт доступний за адресою: https://${DOMAIN}${NC}"
echo -e "${GREEN}🔗 API доступне за адресою: https://${DOMAIN}/api${NC}"

echo -e "\n${YELLOW}📝 Наступні кроки:${NC}"
echo -e "  1. Перевірте, чи працює сайт: https://${DOMAIN}"
echo -e "  2. Перевірте API: https://${DOMAIN}/api/health (якщо є такий endpoint)"
echo -e "  3. Перевірте логи: ssh ${SERVER_USER}@${SERVER_IP} 'cd ${PROJECT_DIR} && docker compose -f docker-compose.prod.yml logs -f'"

