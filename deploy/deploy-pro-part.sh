#!/bin/bash

# Скрипт для деплою admin_pro-part на app.pro-part.online
# Сервер: 135.181.201.185

set -e

SERVER_IP="135.181.201.185"
SERVER_USER="root"
PROJECT_DIR="/opt/admin-pro-part"
REPO_URL="https://github.com/dvytvytskyi/admin_pro-part_git.git"
DOMAIN="app.pro-part.online"

echo "🚀 Деплой admin_pro-part на ${DOMAIN}..."
echo "📡 Сервер: ${SERVER_IP}"
echo ""

# Перевірка чи є sshpass
if ! command -v sshpass &> /dev/null; then
    echo "❌ sshpass не встановлено. Встановіть: brew install hudochenkov/sshpass/sshpass"
    exit 1
fi

# Запитуємо пароль
read -sp "Введіть пароль для root@${SERVER_IP}: " SERVER_PASSWORD
echo ""

echo "📦 Підключення до сервера..."

# Створюємо скрипт для виконання на сервері
sshpass -p "${SERVER_PASSWORD}" ssh -o StrictHostKeyChecking=no ${SERVER_USER}@${SERVER_IP} << 'ENDSSH'
set -e

PROJECT_DIR="/opt/admin-pro-part"
REPO_URL="https://github.com/dvytvytskyi/admin_pro-part_git.git"
DOMAIN="app.pro-part.online"

echo "📦 Оновлення системи..."
apt update -qq

echo "📦 Перевірка Docker..."
if ! command -v docker &> /dev/null; then
    echo "🐳 Встановлення Docker..."
    apt install -y docker.io docker-compose nginx certbot python3-certbot-nginx
    systemctl enable docker
    systemctl start docker
fi

echo "📁 Створення директорії проекту..."
mkdir -p ${PROJECT_DIR}
mkdir -p ${PROJECT_DIR}/backups
cd ${PROJECT_DIR}

echo "📥 Клонування/оновлення репозиторію..."
if [ -d "${PROJECT_DIR}/.git" ]; then
    echo "   Оновлення існуючого репозиторію..."
    git pull origin main || true
else
    echo "   Клонування нового репозиторію..."
    git clone ${REPO_URL} .
fi

echo "📝 Створення .env файлів..."

# Генеруємо паролі
DB_PASSWORD=$(openssl rand -base64 24 | tr -d "=+/" | cut -c1-24)
ADMIN_PASSWORD=$(openssl rand -base64 16 | tr -d "=+/" | cut -c1-16)
JWT_SECRET=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-32)

# Корінь проекту .env (для docker-compose)
if [ ! -f "${PROJECT_DIR}/.env" ]; then
    cat > ${PROJECT_DIR}/.env << ENVEOF
DB_PASSWORD=${DB_PASSWORD}
ENVEOF
    echo "   ✅ Створено ${PROJECT_DIR}/.env"
else
    echo "   ⊘ ${PROJECT_DIR}/.env вже існує"
fi

# Backend .env
if [ ! -f "${PROJECT_DIR}/admin-panel-backend/.env" ]; then
    cat > ${PROJECT_DIR}/admin-panel-backend/.env << ENVEOF
DATABASE_URL=postgresql://admin:${DB_PASSWORD}@admin-pro-part-db:5432/admin_panel_propart
ADMIN_EMAIL=admin@pro-part.online
ADMIN_PASSWORD=${ADMIN_PASSWORD}
ADMIN_JWT_SECRET=${JWT_SECRET}
NODE_ENV=production
PORT=4000
CLOUDINARY_CLOUD_NAME=dgv0rxd60
CLOUDINARY_API_KEY=141613625537469
CLOUDINARY_API_SECRET=GgziMAcVfQvOGD44Yj0OlNqitPg
ENVEOF
    echo "   ✅ Створено ${PROJECT_DIR}/admin-panel-backend/.env"
    echo "   📋 Паролі збережено в .env файлі"
else
    echo "   ⊘ ${PROJECT_DIR}/admin-panel-backend/.env вже існує"
fi

# Frontend .env.production
if [ ! -f "${PROJECT_DIR}/admin-panel/.env.production" ]; then
    cat > ${PROJECT_DIR}/admin-panel/.env.production << ENVEOF
NEXT_PUBLIC_API_URL=https://${DOMAIN}/api
ENVEOF
    echo "   ✅ Створено ${PROJECT_DIR}/admin-panel/.env.production"
else
    echo "   ⊘ ${PROJECT_DIR}/admin-panel/.env.production вже існує"
fi

echo ""
echo "🐳 Налаштування Docker Compose..."

# Створюємо docker-compose.prod.yml якщо немає
if [ ! -f "${PROJECT_DIR}/docker-compose.prod.yml" ]; then
    cat > ${PROJECT_DIR}/docker-compose.prod.yml << 'COMPOSEEOF'
version: '3.8'

services:
  admin-pro-part-db:
    image: postgres:15-alpine
    container_name: admin-pro-part-db
    restart: unless-stopped
    environment:
      POSTGRES_USER: admin
      POSTGRES_PASSWORD: ${DB_PASSWORD}
      POSTGRES_DB: admin_panel_propart
    volumes:
      - admin-pro-part-db-data:/var/lib/postgresql/data
    networks:
      - admin-pro-part-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U admin"]
      interval: 10s
      timeout: 5s
      retries: 5

  admin-pro-part-backend:
    build:
      context: ./admin-panel-backend
      dockerfile: Dockerfile
    container_name: admin-pro-part-backend
    restart: unless-stopped
    env_file:
      - ./admin-panel-backend/.env
    ports:
      - "4001:4000"
    depends_on:
      admin-pro-part-db:
        condition: service_healthy
    networks:
      - admin-pro-part-network
    volumes:
      - ./admin-panel-backend:/app
      - /app/node_modules

  admin-pro-part-frontend:
    build:
      context: ./admin-panel
      dockerfile: Dockerfile
    container_name: admin-pro-part-frontend
    restart: unless-stopped
    env_file:
      - ./admin-panel/.env.production
    ports:
      - "3002:3000"
    depends_on:
      - admin-pro-part-backend
    networks:
      - admin-pro-part-network

networks:
  admin-pro-part-network:
    driver: bridge

volumes:
  admin-pro-part-db-data:
COMPOSEEOF
    echo "   ✅ Створено docker-compose.prod.yml"
else
    echo "   ⊘ docker-compose.prod.yml вже існує"
fi

echo ""
echo "🌐 Налаштування Nginx..."

# Створюємо Nginx конфігурацію
cat > /etc/nginx/sites-available/${DOMAIN} << NGINXEOF
server {
    listen 80;
    server_name ${DOMAIN};

    # Redirect HTTP to HTTPS
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name ${DOMAIN};

    ssl_certificate /etc/letsencrypt/live/${DOMAIN}/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/${DOMAIN}/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    # Frontend
    location / {
        proxy_pass http://localhost:3002;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
    }

    # Backend API
    location /api {
        proxy_pass http://localhost:4001;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
NGINXEOF

# Активуємо конфігурацію
if [ ! -L "/etc/nginx/sites-enabled/${DOMAIN}" ]; then
    ln -s /etc/nginx/sites-available/${DOMAIN} /etc/nginx/sites-enabled/
    echo "   ✅ Створено Nginx конфігурацію"
else
    echo "   ⊘ Nginx конфігурація вже активна"
fi

# Перевіряємо Nginx конфігурацію
nginx -t && echo "   ✅ Nginx конфігурація валідна" || echo "   ⚠️  Помилка в Nginx конфігурації"

echo ""
echo "🔒 Налаштування SSL (Let's Encrypt)..."

# Отримуємо SSL сертифікат
if [ ! -d "/etc/letsencrypt/live/${DOMAIN}" ]; then
    echo "   Отримання SSL сертифікату..."
    certbot --nginx -d ${DOMAIN} --non-interactive --agree-tos --email admin@pro-part.online --redirect || echo "   ⚠️  Не вдалося отримати SSL (можливо домен не налаштований)"
else
    echo "   ⊘ SSL сертифікат вже існує"
fi

echo ""
echo "🐳 Запуск Docker контейнерів..."

cd ${PROJECT_DIR}

# Зупиняємо старі контейнери
docker-compose -f docker-compose.prod.yml down 2>/dev/null || true

# Будуюємо образи
echo "   Будівництво образів..."
docker-compose -f docker-compose.prod.yml build --no-cache

# Запускаємо контейнери
echo "   Запуск контейнерів..."
docker-compose -f docker-compose.prod.yml up -d

# Чекаємо поки БД запуститься
echo "   Очікування запуску БД..."
sleep 10

# Запускаємо міграції та seed
echo "   Запуск міграцій..."
docker exec admin-pro-part-backend npm run migration:run || echo "   ⚠️  Міграції не знайдені або вже виконані"

echo "   Запуск seed..."
docker exec admin-pro-part-backend npm run seed || echo "   ⚠️  Seed не знайдено або вже виконано"

echo ""
echo "🔄 Перезавантаження Nginx..."
systemctl reload nginx

echo ""
echo "✅ Деплой завершено!"
echo ""
echo "📊 Статус контейнерів:"
docker-compose -f docker-compose.prod.yml ps

echo ""
echo "🌐 Домен: https://${DOMAIN}"
echo "📋 Паролі збережені в .env файлах на сервері"
echo ""
echo "📝 Наступні кроки:"
echo "   1. Переконайтеся, що DNS для ${DOMAIN} вказує на ${SERVER_IP}"
echo "   2. Якщо SSL не встановлено, запустіть: certbot --nginx -d ${DOMAIN}"
echo "   3. Перевірте логи: docker-compose -f docker-compose.prod.yml logs -f"

ENDSSH

echo ""
echo "✅ Скрипт виконано на сервері!"
echo ""
echo "🌐 Перевірте: https://${DOMAIN}"

