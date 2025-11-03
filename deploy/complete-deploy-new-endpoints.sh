#!/bin/bash

# Повний деплой нових endpoints з міграцією
# ВИКОРИСТОВУЙТЕ ЦЕЙ СКРИПТ НА СЕРВЕРІ!

set -e

PROJECT_DIR="/opt/admin-panel"
DB_CONTAINER="for-you-admin-panel-postgres-prod"
BACKEND_CONTAINER="for-you-admin-panel-backend-prod"
NETWORK="for-you-network"

if [ ! -d "${PROJECT_DIR}" ]; then
    echo "❌ Помилка: Цей скрипт має виконуватися на сервері!"
    exit 1
fi

cd ${PROJECT_DIR}

echo "🚀 Повний деплой нових endpoints..."
echo ""

echo "📦 Використовувані контейнери:"
echo "   БД: ${DB_CONTAINER}"
echo "   Backend: ${BACKEND_CONTAINER}"
echo ""

# 1. Оновлення коду
echo "🔄 Оновлення коду з Git..."
git pull origin main

# 2. Видалення старого backend
echo ""
echo "🛑 Видалення старого backend контейнера..."
docker stop ${BACKEND_CONTAINER} 2>/dev/null || true
docker rm -f ${BACKEND_CONTAINER} 2>/dev/null || true
docker-compose -f docker-compose.prod.yml rm -f admin-panel-backend 2>/dev/null || true

# 3. Застосування міграції
echo ""
echo "🗄️  Застосування міграції БД..."
MIGRATION_FILE="${PROJECT_DIR}/admin-panel-backend/src/migrations/002-create-collections-favorites-investments.sql"
if [ -f "${MIGRATION_FILE}" ]; then
    docker exec -i ${DB_CONTAINER} psql -U admin -d admin_panel < ${MIGRATION_FILE} 2>&1 | grep -v "already exists" || true
    echo "✅ Міграція застосована"
else
    echo "⚠️  Файл міграції не знайдено, пропускаємо"
fi

# 4. Перебудова backend
echo ""
echo "🏗️  Перебудова backend (без кешу)..."
docker-compose -f docker-compose.prod.yml build --no-cache admin-panel-backend

# 5. Створення та запуск
echo ""
echo "🚀 Створення та запуск backend..."
docker-compose -f docker-compose.prod.yml create admin-panel-backend
docker-compose -f docker-compose.prod.yml start admin-panel-backend

# 6. Очікування запуску
echo ""
echo "⏳ Очікуємо запуск backend (25 секунд)..."
sleep 25

# 7. Перевірка логів
echo ""
echo "📋 Останні 40 рядків логів backend:"
echo "=========================================="
docker logs --tail 40 ${BACKEND_CONTAINER} 2>&1
echo "=========================================="
echo ""

# 8. Перевірка health
echo "🔍 Перевірка health:"
curl -s http://localhost:4000/health 2>&1 | head -5
echo ""
echo ""

# 9. Перевірка таблиць
echo "📊 Перевірка нових таблиць:"
docker exec ${DB_CONTAINER} psql -U admin -d admin_panel -t -c "\dt" | grep -E "(collections|favorites|investments)" || echo "⚠️  Нові таблиці не знайдено"
echo ""

# 10. Перевірка полів
echo "📊 Перевірка нових полів:"
echo "Areas:"
docker exec ${DB_CONTAINER} psql -U admin -d admin_panel -c "\d areas" | grep -E "(description|images)" || echo "⚠️  Нові поля не знайдено"
echo "Developers:"
docker exec ${DB_CONTAINER} psql -U admin -d admin_panel -c "\d developers" | grep -E "(images)" || echo "⚠️  Нові поля не знайдено"
echo ""

# 11. Перевірка users
echo "👤 Перевірка користувачів:"
docker exec ${DB_CONTAINER} psql -U admin -d admin_panel -c "SELECT email, role, status FROM users LIMIT 5;"
echo ""

echo "✅ Деплой завершено!"
echo ""
echo "🌐 URL: https://admin.foryou-realestate.com"
echo ""
echo "🧪 Для тестування використайте API документацію:"
echo "   https://admin.foryou-realestate.com/integrations/docs"

