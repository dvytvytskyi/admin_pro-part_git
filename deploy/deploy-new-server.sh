#!/bin/bash

# Скрипт для деплою admin_pro-part на новий сервер
# Сервер: 88.99.38.25
# Домен: system.pro-part.online

set -e

SERVER_IP="88.99.38.25"
SERVER_USER="root"
SERVER_PASSWORD="PgTeNqcgnwWu"
PROJECT_DIR="/opt/admin-pro-part"
REPO_URL="https://github.com/dvytvytskyi/admin_pro-part_git.git"
DOMAIN="system.pro-part.online"

echo "🚀 Деплой admin_pro-part на ${DOMAIN}..."
echo "📡 Сервер: ${SERVER_IP}"
echo ""

# Перевірка чи є sshpass
if ! command -v sshpass &> /dev/null; then
    echo "❌ sshpass не встановлено. Встановіть: brew install hudochenkov/sshpass/sshpass"
    exit 1
fi

echo "📦 Підключення до сервера..."

# Створюємо скрипт для виконання на сервері
sshpass -p "${SERVER_PASSWORD}" ssh -o StrictHostKeyChecking=no ${SERVER_USER}@${SERVER_IP} << ENDSSH
set -e

PROJECT_DIR="${PROJECT_DIR}"
REPO_URL="${REPO_URL}"
DOMAIN="${DOMAIN}"

echo "📦 Оновлення системи..."
export DEBIAN_FRONTEND=noninteractive
apt update -qq

echo "📦 Перевірка Docker..."
if ! command -v docker &> /dev/null; then
    echo "🐳 Встановлення Docker..."
    apt install -y docker.io docker-compose nginx certbot python3-certbot-nginx curl git
    systemctl enable docker
    systemctl start docker
fi

echo "📁 Створення директорії проекту..."
mkdir -p \${PROJECT_DIR}/backups

echo "📥 Клонування/оновлення репозиторію..."
if [ -d "\${PROJECT_DIR}/.git" ]; then
    echo "   Оновлення існуючого репозиторію..."
    cd \${PROJECT_DIR}
    git pull origin main || true
else
    echo "   Підготовка до клонування..."
    # Якщо директорія існує і не порожня (крім backups), створюємо тимчасову
    if [ -d "\${PROJECT_DIR}" ] && [ "$(ls -A \${PROJECT_DIR} 2>/dev/null | grep -v '^backups$' | wc -l)" -gt 0 ]; then
        echo "   Директорія не порожня - створюємо тимчасову..."
        TEMP_DIR=\${PROJECT_DIR}.tmp.\$(date +%s)
        git clone \${REPO_URL} \${TEMP_DIR}
        # Переміщуємо backups якщо потрібно
        if [ -d "\${PROJECT_DIR}/backups" ]; then
            mv \${PROJECT_DIR}/backups \${TEMP_DIR}/ 2>/dev/null || true
        fi
        # Видаляємо стару та перейменовуємо нову
        rm -rf \${PROJECT_DIR}
        mv \${TEMP_DIR} \${PROJECT_DIR}
    else
        echo "   Клонування нового репозиторію..."
        if [ -d "\${PROJECT_DIR}" ] && [ -z "$(ls -A \${PROJECT_DIR} 2>/dev/null | grep -v '^backups$')" ]; then
            cd \${PROJECT_DIR}
            git clone \${REPO_URL} .
        else
            git clone \${REPO_URL} \${PROJECT_DIR}
        fi
    fi
fi

cd \${PROJECT_DIR}

echo "📝 Створення .env файлів..."

# Генеруємо паролі
DB_PASSWORD=\$(openssl rand -base64 24 | tr -d "=+/" | cut -c1-24)
ADMIN_PASSWORD=\$(openssl rand -base64 16 | tr -d "=+/" | cut -c1-16)
JWT_SECRET=\$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-32)

# Корінь проекту .env (для docker-compose)
if [ ! -f "\${PROJECT_DIR}/.env" ]; then
    cat > \${PROJECT_DIR}/.env << ENVEOF
DB_PASSWORD=\${DB_PASSWORD}
ENVEOF
    echo "   ✅ Створено \${PROJECT_DIR}/.env"
else
    echo "   ⊘ \${PROJECT_DIR}/.env вже існує"
    # Оновлюємо DB_PASSWORD якщо його немає
    if ! grep -q "DB_PASSWORD" \${PROJECT_DIR}/.env; then
        echo "DB_PASSWORD=\${DB_PASSWORD}" >> \${PROJECT_DIR}/.env
    fi
fi

# Backend .env
if [ ! -f "\${PROJECT_DIR}/admin-panel-backend/.env" ]; then
    cat > \${PROJECT_DIR}/admin-panel-backend/.env << ENVEOF
DATABASE_URL=postgresql://admin:\${DB_PASSWORD}@admin-pro-part-db:5432/admin_panel_propart
ADMIN_EMAIL=admin@foryou.ae
ADMIN_PASSWORD=\${ADMIN_PASSWORD}
ADMIN_JWT_SECRET=\${JWT_SECRET}
NODE_ENV=production
PORT=4000
CLOUDINARY_CLOUD_NAME=dgv0rxd60
CLOUDINARY_API_KEY=141613625537469
CLOUDINARY_API_SECRET=GgziMAcVfQvOGD44Yj0OlNqitPg
ENVEOF
    echo "   ✅ Створено \${PROJECT_DIR}/admin-panel-backend/.env"
    echo "   📋 Паролі збережено в .env файлі"
    echo "   🔑 Admin email: admin@foryou.ae"
    echo "   🔑 Admin пароль: \${ADMIN_PASSWORD}"
else
    echo "   ⊘ \${PROJECT_DIR}/admin-panel-backend/.env вже існує"
    # Оновлюємо ADMIN_EMAIL якщо його немає або він неправильний
    if ! grep -q "ADMIN_EMAIL=admin@foryou.ae" \${PROJECT_DIR}/admin-panel-backend/.env; then
        sed -i 's/ADMIN_EMAIL=.*/ADMIN_EMAIL=admin@foryou.ae/' \${PROJECT_DIR}/admin-panel-backend/.env || echo "ADMIN_EMAIL=admin@foryou.ae" >> \${PROJECT_DIR}/admin-panel-backend/.env
        echo "   ✅ Оновлено ADMIN_EMAIL"
    fi
fi

# Frontend .env.production
cat > \${PROJECT_DIR}/admin-panel/.env.production << ENVEOF
NEXT_PUBLIC_API_URL=https://\${DOMAIN}/api
ENVEOF
echo "   ✅ Створено/оновлено \${PROJECT_DIR}/admin-panel/.env.production"

echo ""
echo "🐳 Налаштування Docker Compose..."

# Створюємо docker-compose.prod.yml
cat > \${PROJECT_DIR}/docker-compose.prod.yml << 'COMPOSEEOF'
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
    # Не монтуємо volume для production - використовуємо збілджений образ
    # volumes:
    #   - ./admin-panel-backend:/app
    #   - /app/node_modules

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
echo "   ✅ Створено/оновлено docker-compose.prod.yml"

echo ""
echo "🌐 Налаштування Nginx..."

# Видаляємо старі конфігурації
rm -f /etc/nginx/sites-enabled/default
rm -f /etc/nginx/sites-enabled/*admin.foryou* 2>/dev/null || true
rm -f /etc/nginx/sites-available/*admin.foryou* 2>/dev/null || true

# Видаляємо стару конфігурацію для system.pro-part.online якщо вона є
rm -f /etc/nginx/sites-enabled/\${DOMAIN} 2>/dev/null || true

# Створюємо Nginx конфігурацію (спочатку HTTP)
cat > /etc/nginx/sites-available/\${DOMAIN} << NGINXEOF
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name system.pro-part.online *.pro-part.online;

    # Gzip Compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml+rss application/json application/javascript;

    # Client Max Body Size
    client_max_body_size 10M;

    # Frontend
    location / {
        proxy_pass http://localhost:3002;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \\\$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \\\$host;
        proxy_set_header X-Real-IP \\\$remote_addr;
        proxy_set_header X-Forwarded-For \\\$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \\\$scheme;
        proxy_cache_bypass \\\$http_upgrade;
        proxy_read_timeout 300s;
        proxy_connect_timeout 75s;
    }

    # Backend API
    location /api {
        proxy_pass http://localhost:4001;
        proxy_http_version 1.1;
        proxy_set_header Host \\\$host;
        proxy_set_header X-Real-IP \\\$remote_addr;
        proxy_set_header X-Forwarded-For \\\$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \\\$scheme;
        proxy_read_timeout 300s;
        proxy_connect_timeout 75s;
    }

    # Health check (без /api префіксу)
    location /health {
        proxy_pass http://localhost:4001/health;
        proxy_http_version 1.1;
        proxy_set_header Host \\\$host;
        access_log off;
    }

    # Health check через /api (для сумісності)
    location /api/health {
        proxy_pass http://localhost:4001/health;
        proxy_http_version 1.1;
        proxy_set_header Host \\\$host;
        access_log off;
    }
}
NGINXEOF

# Активуємо конфігурацію
ln -sf /etc/nginx/sites-available/\${DOMAIN} /etc/nginx/sites-enabled/\${DOMAIN}

# Перевіряємо Nginx конфігурацію
echo "   Перевірка Nginx конфігурації..."
if nginx -t; then
    echo "   ✅ Nginx конфігурація валідна"
    systemctl reload nginx
else
    echo "   ❌ Помилка в Nginx конфігурації!"
    nginx -t
    exit 1
fi

echo ""
echo "🐳 Запуск Docker контейнерів..."

cd \${PROJECT_DIR}

# Перевіряємо, яка версія docker compose доступна
if command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE_CMD="docker-compose"
elif docker compose version &> /dev/null; then
    DOCKER_COMPOSE_CMD="docker compose"
else
    echo "   ❌ Docker Compose не знайдено!"
    exit 1
fi

# Зупиняємо старі контейнери
\${DOCKER_COMPOSE_CMD} -f docker-compose.prod.yml down 2>/dev/null || true

# Будуюємо образи
echo "   Будівництво образів..."
\${DOCKER_COMPOSE_CMD} -f docker-compose.prod.yml build --no-cache

# Запускаємо контейнери
echo "   Запуск контейнерів..."
\${DOCKER_COMPOSE_CMD} -f docker-compose.prod.yml up -d

# Чекаємо поки БД запуститься
echo "   Очікування запуску БД..."
sleep 15

# Перевіряємо статус
echo ""
echo "📊 Статус контейнерів:"
\${DOCKER_COMPOSE_CMD} -f docker-compose.prod.yml ps

echo ""
echo "🔄 Запуск міграцій бази даних..."
# Чекаємо поки бекенд повністю запуститься
sleep 10
docker exec admin-pro-part-backend npm run migration:run || {
    echo "   ⚠️  Міграції не знайдено або вже виконані"
    echo "   ℹ️  Це нормально, якщо таблиці вже існують"
}

echo ""
echo "🔒 Налаштування SSL (Let's Encrypt)..."

# Отримуємо SSL сертифікат
if [ ! -d "/etc/letsencrypt/live/\${DOMAIN}" ]; then
    echo "   Отримання SSL сертифікату..."
    certbot --nginx -d \${DOMAIN} --non-interactive --agree-tos --email admin@pro-part.online --redirect || {
        echo "   ⚠️  Не вдалося отримати SSL (можливо домен не налаштований або ще не активний)"
        echo "   💡 Можна спробувати пізніше: certbot --nginx -d \${DOMAIN}"
    }
    systemctl reload nginx
else
    echo "   ⊘ SSL сертифікат вже існує"
fi

echo ""
echo "🧪 Перевірка роботи бекенду..."
sleep 5

# Перевірка health check
if curl -s --max-time 5 http://localhost:4001/health > /dev/null 2>&1; then
    echo "   ✅ Бекенд відповідає на /health"
    curl -s http://localhost:4001/health | head -3
else
    echo "   ⚠️  Бекенд не відповідає на /health (може потребувати більше часу)"
fi

echo ""
echo "🧪 Перевірка через nginx..."
if curl -s --max-time 5 http://localhost/api/health > /dev/null 2>&1; then
    echo "   ✅ Nginx проксує запити до бекенду"
    curl -s http://localhost/api/health | head -3
else
    echo "   ⚠️  Nginx не може проксувати запити (може потребувати більше часу)"
fi

echo ""
echo "✅ Деплой завершено!"
echo ""
echo "📊 Статус контейнерів:"
\${DOCKER_COMPOSE_CMD} -f docker-compose.prod.yml ps

echo ""
echo "🌐 Домен: http://\${DOMAIN} (або https://\${DOMAIN} якщо SSL встановлено)"
echo "📋 Паролі збережені в .env файлах на сервері"
echo ""
echo "🔑 Дані для входу:"
echo "   Email: admin@foryou.ae"
echo "   Password: (збережено в \${PROJECT_DIR}/admin-panel-backend/.env)"
echo "   Для перегляду пароля: grep ADMIN_PASSWORD \${PROJECT_DIR}/admin-panel-backend/.env"
echo ""
echo "📝 Наступні кроки:"
echo "   1. Переконайтеся, що DNS для \${DOMAIN} вказує на ${SERVER_IP}"
echo "   2. Якщо SSL не встановлено, запустіть: certbot --nginx -d \${DOMAIN}"
echo "   3. Перевірте логи: \${DOCKER_COMPOSE_CMD} -f docker-compose.prod.yml logs -f"
echo "   4. Для імпорту даних: docker exec admin-pro-part-backend npm run import:all"
echo "   5. Перевірте логи бекенду: docker logs admin-pro-part-backend -f"

ENDSSH

echo ""
echo "✅ Скрипт виконано на сервері!"
echo ""
echo "🌐 Перевірте: http://${DOMAIN}"

