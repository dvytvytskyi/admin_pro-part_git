#!/bin/bash

# Скрипт для діагностики та виправлення проблем з підключенням до БД
# ВИКОРИСТОВУЙТЕ ЦЕЙ СКРИПТ НА СЕРВЕРІ!

set -e

PROJECT_DIR="/opt/admin-panel"

if [ ! -d "${PROJECT_DIR}" ]; then
    echo "❌ Помилка: Цей скрипт має виконуватися на сервері!"
    echo "📝 Підключіться до сервера через SSH:"
    echo "   ssh root@135.181.201.185"
    exit 1
fi

cd ${PROJECT_DIR}

echo "🔍 Діагностика підключення до БД..."
echo ""

# 1. Перевірка статусу контейнерів
echo "📦 Статус контейнерів:"
docker-compose -f docker-compose.prod.yml ps
echo ""

# 2. Перевірка чи працює БД
echo "🗄️  Перевірка БД контейнера:"
DB_CONTAINER="for-you-admin-panel-postgres-prod"
if docker ps | grep -q "${DB_CONTAINER}"; then
    echo "✅ БД контейнер запущено"
    docker exec ${DB_CONTAINER} pg_isready -U admin
else
    echo "❌ БД контейнер не запущено!"
    exit 1
fi
echo ""

# 3. Перевірка DATABASE_URL в .env
echo "📝 Перевірка DATABASE_URL:"
if [ -f "${PROJECT_DIR}/admin-panel-backend/.env" ]; then
    DB_URL=$(grep "DATABASE_URL" ${PROJECT_DIR}/admin-panel-backend/.env | cut -d '=' -f2- || echo "")
    if [ -z "$DB_URL" ]; then
        echo "❌ DATABASE_URL не знайдено в .env"
    else
        echo "✅ DATABASE_URL: ${DB_URL:0:50}..."
    fi
else
    echo "❌ Файл .env не знайдено!"
fi
echo ""

# 4. Перевірка чи правильний пароль БД
echo "🔐 Перевірка підключення до БД:"
DB_PASSWORD=$(grep "DB_PASSWORD" ${PROJECT_DIR}/.env 2>/dev/null | cut -d '=' -f2 || echo "admin123")
echo "Використовується пароль: ${DB_PASSWORD:0:5}..."

# Тестуємо підключення
if docker exec ${DB_CONTAINER} psql -U admin -d admin_panel -c "SELECT 1;" > /dev/null 2>&1; then
    echo "✅ Підключення до БД працює"
else
    echo "❌ Не вдалося підключитися до БД!"
fi
echo ""

# 5. Перевірка кількості таблиць
echo "📊 Перевірка таблиць в БД:"
TABLE_COUNT=$(docker exec ${DB_CONTAINER} psql -U admin -d admin_panel -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';" | tr -d ' ')
echo "Знайдено таблиць: ${TABLE_COUNT}"
echo ""

# 6. Перевірка логів backend
echo "📋 Останні 20 рядків логів backend:"
docker logs --tail 20 for-you-admin-panel-backend-prod 2>&1 | tail -20
echo ""

# 7. Перевірка entities в конфігурації
echo "🔧 Перевірка конфігурації entities:"
if grep -q "dist/entities" ${PROJECT_DIR}/admin-panel-backend/src/config/database.ts; then
    echo "✅ Використовуються dist/entities"
elif grep -q "src/entities" ${PROJECT_DIR}/admin-panel-backend/src/config/database.ts; then
    echo "⚠️  Використовуються src/entities (може не працювати в production)"
    echo "💡 Потрібно змінити на dist/entities в production"
fi
echo ""

# 8. Перевірка API
echo "🌐 Перевірка API:"
if curl -s http://localhost:4000/health > /dev/null 2>&1; then
    echo "✅ API health endpoint працює"
    curl -s http://localhost:4000/health | head -1
else
    echo "❌ API не відповідає"
fi
echo ""

echo "✅ Діагностика завершена!"

