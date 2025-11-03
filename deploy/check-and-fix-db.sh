#!/bin/bash

# Скрипт для перевірки та виправлення підключення до БД
# ВИКОРИСТОВУЙТЕ ЦЕЙ СКРИПТ НА СЕРВЕРІ!

set -e

PROJECT_DIR="/opt/admin-panel"

if [ ! -d "${PROJECT_DIR}" ]; then
    echo "❌ Помилка: Цей скрипт має виконуватися на сервері!"
    exit 1
fi

cd ${PROJECT_DIR}

echo "🔍 Перевірка та виправлення підключення до БД..."
echo ""

# 1. Перевірка чи існує .env в корені
if [ ! -f "${PROJECT_DIR}/.env" ]; then
    echo "📝 Створюємо .env файл в корені проекту..."
    cat > ${PROJECT_DIR}/.env << EOF
# Database password
DB_PASSWORD=admin123

# Admin credentials (буде встановлено в admin-panel-backend/.env)
EOF
    echo "✅ Створено .env"
fi

# 2. Перевірка чи існує admin-panel-backend/.env
if [ ! -f "${PROJECT_DIR}/admin-panel-backend/.env" ]; then
    echo "📝 Створюємо admin-panel-backend/.env..."
    DB_PASSWORD=$(grep "DB_PASSWORD" ${PROJECT_DIR}/.env 2>/dev/null | cut -d '=' -f2 || echo "admin123")
    
    cat > ${PROJECT_DIR}/admin-panel-backend/.env << EOF
# Database
DATABASE_URL=postgresql://admin:${DB_PASSWORD}@admin-panel-db:5432/admin_panel

# Auth
ADMIN_EMAIL=admin@foryou-realestate.com
ADMIN_PASSWORD=$(openssl rand -base64 16 | tr -d "=+/" | cut -c1-16)

# JWT
ADMIN_JWT_SECRET=$(openssl rand -base64 32)

# Server
PORT=4000
NODE_ENV=production

# Cloudinary (за потреби)
CLOUDINARY_CLOUD_NAME=dgv0rxd60
CLOUDINARY_API_KEY=GgziMAcVfQvOGD44Yj0OlNqitPg
CLOUDINARY_API_SECRET=
EOF
    echo "✅ Створено admin-panel-backend/.env"
    echo ""
    echo "📧 Дані для входу:"
    grep "ADMIN_EMAIL\|ADMIN_PASSWORD" ${PROJECT_DIR}/admin-panel-backend/.env
else
    # Перевіряємо чи правильний DATABASE_URL
    echo "📝 Перевірка DATABASE_URL..."
    DB_PASSWORD=$(grep "DB_PASSWORD" ${PROJECT_DIR}/.env 2>/dev/null | cut -d '=' -f2 || echo "admin123")
    CURRENT_DB_URL=$(grep "DATABASE_URL" ${PROJECT_DIR}/admin-panel-backend/.env 2>/dev/null | cut -d '=' -f2- || echo "")
    
    EXPECTED_DB_URL="postgresql://admin:${DB_PASSWORD}@admin-panel-db:5432/admin_panel"
    
    if [ "$CURRENT_DB_URL" != "$EXPECTED_DB_URL" ]; then
        echo "⚠️  DATABASE_URL неправильний, оновлюємо..."
        sed -i "s|DATABASE_URL=.*|DATABASE_URL=${EXPECTED_DB_URL}|" ${PROJECT_DIR}/admin-panel-backend/.env
        echo "✅ DATABASE_URL оновлено"
    else
        echo "✅ DATABASE_URL правильний"
    fi
fi

echo ""

# 3. Перевірка статусу контейнерів
echo "📦 Перезапуск контейнерів..."
docker-compose -f docker-compose.prod.yml down
docker-compose -f docker-compose.prod.yml up -d

echo ""
echo "⏳ Очікуємо запуск БД..."
sleep 5

# 4. Перевірка підключення до БД
echo "🗄️  Перевірка підключення до БД..."
DB_CONTAINER="for-you-admin-panel-postgres-prod"
MAX_RETRIES=10
RETRY=0

while [ $RETRY -lt $MAX_RETRIES ]; do
    if docker exec ${DB_CONTAINER} pg_isready -U admin > /dev/null 2>&1; then
        echo "✅ БД готова"
        break
    fi
    RETRY=$((RETRY + 1))
    echo "⏳ Очікуємо... ($RETRY/$MAX_RETRIES)"
    sleep 2
done

if [ $RETRY -eq $MAX_RETRIES ]; then
    echo "❌ БД не запустилась!"
    exit 1
fi

# 5. Перевірка таблиць
echo ""
echo "📊 Перевірка таблиць в БД:"
TABLE_COUNT=$(docker exec ${DB_CONTAINER} psql -U admin -d admin_panel -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';" | tr -d ' ' || echo "0")
echo "Знайдено таблиць: ${TABLE_COUNT}"

if [ "$TABLE_COUNT" = "0" ] || [ -z "$TABLE_COUNT" ]; then
    echo "⚠️  Таблиць не знайдено! Можливо потрібно відновити БД з дампу."
fi

echo ""

# 6. Перевірка логів backend
echo "📋 Останні 10 рядків логів backend (через 5 секунд):"
sleep 5
docker logs --tail 10 for-you-admin-panel-backend-prod 2>&1 | tail -10

echo ""
echo "✅ Перевірка завершена!"
echo ""
echo "🌐 URL: https://admin.foryou-realestate.com"
echo "📧 Для отримання даних для входу: ./deploy/show-credentials.sh"

