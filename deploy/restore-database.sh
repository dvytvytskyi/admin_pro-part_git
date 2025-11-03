#!/bin/bash

# Відновлення БД з дампу main_database.sql
# ВИКОРИСТОВУЙТЕ ЦЕЙ СКРИПТ НА СЕРВЕРІ!

set -e

PROJECT_DIR="/opt/admin-panel"
DB_CONTAINER="for-you-admin-panel-postgres-prod"
DUMP_FILE="${PROJECT_DIR}/main_database.sql"

if [ ! -d "${PROJECT_DIR}" ]; then
    echo "❌ Помилка: Цей скрипт має виконуватися на сервері!"
    exit 1
fi

cd ${PROJECT_DIR}

echo "🗄️  Відновлення БД з дампу..."
echo ""

# Перевірка чи існує дамп
if [ ! -f "${DUMP_FILE}" ]; then
    echo "❌ Файл дампу не знайдено: ${DUMP_FILE}"
    echo ""
    echo "💡 Скопіюйте файл main_database.sql на сервер:"
    echo "   scp main_database.sql root@135.181.201.185:/opt/admin-panel/"
    echo ""
    exit 1
fi

echo "✅ Дамп знайдено: ${DUMP_FILE}"
echo "   Розмір: $(du -h ${DUMP_FILE} | cut -f1)"
echo ""

# Перевірка чи запущена БД
if ! docker ps --format "{{.Names}}" | grep -q "^${DB_CONTAINER}$"; then
    echo "❌ БД контейнер не запущений!"
    echo "Запускаємо БД..."
    docker start ${DB_CONTAINER}
    sleep 5
fi

echo "✅ БД контейнер запущений"
echo ""

# Попередження
echo "⚠️  УВАГА: Це повністю замінить поточну БД!"
echo "   Поточна БД буде видалена і замінена даними з дампу"
echo ""
read -p "Продовжити? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Скасовано"
    exit 0
fi

echo ""
echo "🗑️  Очищення поточної БД..."

# Видаляємо всі таблиці
docker exec ${DB_CONTAINER} psql -U admin -d admin_panel -c "
DO \$\$ 
DECLARE 
    r RECORD;
BEGIN
    FOR r IN (SELECT tablename FROM pg_tables WHERE schemaname = 'public') 
    LOOP
        EXECUTE 'DROP TABLE IF EXISTS public.' || quote_ident(r.tablename) || ' CASCADE';
    END LOOP;
END \$\$;
" 2>&1 || echo "Таблиці вже видалені або їх немає"

echo "✅ Поточна БД очищена"
echo ""

echo "📥 Відновлення БД з дампу..."
echo "Це може зайняти кілька хвилин..."

# Відновлюємо БД
docker exec -i ${DB_CONTAINER} psql -U admin -d admin_panel < ${DUMP_FILE} 2>&1 | grep -v "already exists" || true

echo ""
echo "✅ БД відновлено!"
echo ""

echo "📊 Перевірка даних:"
echo "Properties:"
docker exec ${DB_CONTAINER} psql -U admin -d admin_panel -t -c "SELECT COUNT(*) FROM properties;" 2>&1 | tr -d ' '
echo ""
echo "Users:"
docker exec ${DB_CONTAINER} psql -U admin -d admin_panel -t -c "SELECT COUNT(*) FROM users;" 2>&1 | tr -d ' '
echo ""
echo "Developers:"
docker exec ${DB_CONTAINER} psql -U admin -d admin_panel -t -c "SELECT COUNT(*) FROM developers;" 2>&1 | tr -d ' '
echo ""

echo "✅ Готово!"
echo ""
echo "🌐 Тепер перевірте адмін панель: https://admin.foryou-realestate.com/properties"

