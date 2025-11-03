#!/bin/bash

# Локальний скрипт для завантаження дампу на сервер та відновлення БД
# ВИКОРИСТОВУЙТЕ ЦЕЙ СКРИПТ ЛОКАЛЬНО!

set -e

SERVER="root@135.181.201.185"
PROJECT_DIR="/opt/admin-panel"
DUMP_FILE="main_database.sql"

if [ ! -f "${DUMP_FILE}" ]; then
    echo "❌ Файл дампу не знайдено: ${DUMP_FILE}"
    exit 1
fi

echo "📤 Завантаження дампу на сервер..."
echo ""

# Завантажуємо файл на сервер
scp ${DUMP_FILE} ${SERVER}:${PROJECT_DIR}/

echo "✅ Файл завантажено"
echo ""

echo "🗄️  Відновлення БД на сервері..."
echo ""

# Виконуємо відновлення на сервері
ssh ${SERVER} "cd ${PROJECT_DIR} && chmod +x deploy/restore-database.sh && echo 'yes' | ./deploy/restore-database.sh"

echo ""
echo "✅ Готово!"
echo ""
echo "🌐 Перевірте адмін панель: https://admin.foryou-realestate.com/properties"

