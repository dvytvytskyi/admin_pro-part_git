#!/bin/bash

# Експорт даних з локальної БД

set -e

LOCAL_DB="admin_panel_propart"
LOCAL_USER="vytvytskyi"
LOCAL_HOST="localhost"
LOCAL_PORT="5432"
OUTPUT_FILE="data_export_$(date +%Y%m%d_%H%M%S).sql"

echo "📦 Експорт даних з локальної БД..."
echo ""

# Експорт даних (без структури, тільки дані)
pg_dump -h $LOCAL_HOST -p $LOCAL_PORT -U $LOCAL_USER -d $LOCAL_DB \
  --data-only \
  --no-owner \
  --no-privileges \
  --disable-triggers \
  -f $OUTPUT_FILE

echo "✅ Дані експортовані в: $OUTPUT_FILE"
echo ""
echo "📊 Розмір файлу:"
ls -lh $OUTPUT_FILE

echo ""
echo "📋 Наступні кроки:"
echo "   1. Скопіюйте файл на сервер:"
echo "      scp $OUTPUT_FILE root@135.181.201.185:/opt/admin-pro-part/"
echo ""
echo "   2. На сервері виконайте:"
echo "      docker exec -i admin-pro-part-db psql -U admin -d admin_panel_propart < $OUTPUT_FILE"

