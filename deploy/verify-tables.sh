#!/bin/bash

# Перевірка створених таблиць та статусу бекенду

set -e

echo "🔍 Перевірка таблиць та статусу..."
echo ""

cd /opt/admin-pro-part

# 1. Знайти контейнер БД
DB_CONTAINER=$(docker ps | grep postgres | grep pro-part | awk '{print $1}')

# 2. Перевірити таблиці
echo "📊 Список таблиць в БД:"
docker exec $DB_CONTAINER psql -U admin -d admin_panel_propart -c "\dt" | head -40

# 3. Перевірити кількість таблиць
TABLE_COUNT=$(docker exec $DB_CONTAINER psql -U admin -d admin_panel_propart -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';" | tr -d ' ')
echo ""
echo "✅ Кількість таблиць: $TABLE_COUNT"

# 4. Перевірити логи бекенду
echo ""
echo "📋 Останні логи бекенду:"
docker logs --tail=20 admin-pro-part-backend

# 5. Перевірити health endpoint
echo ""
echo "🏥 Health check:"
curl -s http://localhost:4001/health | jq . 2>/dev/null || curl -s http://localhost:4001/health

# 6. Перевірити stats endpoint
echo ""
echo "📊 Stats endpoint:"
curl -s http://localhost:4001/api/properties/stats -H "Authorization: Bearer $(docker exec admin-pro-part-backend cat /app/.env 2>/dev/null | grep ADMIN_PASSWORD | cut -d '=' -f2 | head -c 20)" 2>&1 | head -5 || echo "   Потрібна авторизація"

echo ""
echo "✅ Перевірка завершена"

