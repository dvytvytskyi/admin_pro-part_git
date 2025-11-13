#!/bin/bash

# Експорт структури таблиць з локальної БД та імпорт на production

set -e

echo "📦 Експорт та імпорт структури таблиць..."
echo ""

# Локальна БД
LOCAL_DB="admin_panel_propart"
LOCAL_USER="vytvytskyi"
LOCAL_HOST="localhost"
LOCAL_PORT="5432"

# Production БД (на сервері)
PROD_DB="admin_panel_propart"
PROD_USER="admin"
PROD_CONTAINER="admin-pro-part-db"

echo "1️⃣ Експорт структури таблиць з локальної БД..."
pg_dump -h $LOCAL_HOST -p $LOCAL_PORT -U $LOCAL_USER -d $LOCAL_DB \
  --schema-only \
  --no-owner \
  --no-privileges \
  -f /tmp/schema.sql

echo "✅ Структура експортована в /tmp/schema.sql"
echo ""

echo "2️⃣ Перевірка файлу..."
head -20 /tmp/schema.sql

echo ""
echo "3️⃣ Наступні кроки:"
echo "   - Скопіюйте /tmp/schema.sql на сервер"
echo "   - Або виконайте на сервері:"
echo ""
echo "   docker exec -i $PROD_CONTAINER psql -U $PROD_USER -d $PROD_DB < schema.sql"
echo ""

