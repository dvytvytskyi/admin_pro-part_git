#!/bin/bash

# Імпорт даних на production

set -e

echo "📥 Імпорт даних на production..."
echo ""

cd /opt/admin-pro-part

# Знайти файл з даними
DATA_FILE=$(ls -t data_export_*.sql 2>/dev/null | head -1)

if [ -z "$DATA_FILE" ]; then
    echo "❌ Файл з даними не знайдено!"
    echo ""
    echo "📋 Доступні файли:"
    ls -la *.sql 2>/dev/null || echo "   Немає .sql файлів"
    echo ""
    echo "💡 Скопіюйте файл з локальної машини:"
    echo "   scp data_export_*.sql root@135.181.201.185:/opt/admin-pro-part/"
    exit 1
fi

echo "✅ Знайдено файл: $DATA_FILE"
echo ""

# Знайти контейнер БД
DB_CONTAINER=$(docker ps | grep postgres | grep pro-part | awk '{print $1}')

if [ -z "$DB_CONTAINER" ]; then
    echo "❌ Контейнер БД не знайдено!"
    exit 1
fi

echo "✅ Контейнер БД: $DB_CONTAINER"
echo ""

# Перевірити розмір файлу
FILE_SIZE=$(du -h $DATA_FILE | awk '{print $1}')
echo "📊 Розмір файлу: $FILE_SIZE"
echo ""

# Підтвердження
read -p "⚠️  Це перезапише всі дані в БД. Продовжити? (yes/no): " confirm
if [ "$confirm" != "yes" ]; then
    echo "❌ Скасовано"
    exit 1
fi

# Імпорт даних
echo ""
echo "📥 Імпорт даних..."
docker exec -i $DB_CONTAINER psql -U admin -d admin_panel_propart < $DATA_FILE

echo ""
echo "✅ Дані імпортовані!"
echo ""

# Перевірка кількості записів
echo "🔍 Перевірка даних:"
echo ""
echo "Properties:"
docker exec $DB_CONTAINER psql -U admin -d admin_panel_propart -t -c "SELECT COUNT(*) FROM properties;"
echo ""
echo "Developers:"
docker exec $DB_CONTAINER psql -U admin -d admin_panel_propart -t -c "SELECT COUNT(*) FROM developers;"
echo ""
echo "Areas:"
docker exec $DB_CONTAINER psql -U admin -d admin_panel_propart -t -c "SELECT COUNT(*) FROM areas;"
echo ""
echo "Facilities:"
docker exec $DB_CONTAINER psql -U admin -d admin_panel_propart -t -c "SELECT COUNT(*) FROM facilities;"

echo ""
echo "✅ Готово! Перевірте дашборд"

