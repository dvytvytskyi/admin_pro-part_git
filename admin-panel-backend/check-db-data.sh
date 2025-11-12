#!/bin/bash
echo "🔍 Перевірка даних в базі..."
docker exec admin-panel-db psql -U admin -d admin_panel_propart -c "SELECT COUNT(*) as properties_count FROM properties;" 2>/dev/null || echo "Не вдалося підключитися до БД"
docker exec admin-panel-db psql -U admin -d admin_panel_propart -c "SELECT COUNT(*) as users_count FROM users;" 2>/dev/null || echo "Не вдалося підключитися до БД"
docker exec admin-panel-db psql -U admin -d admin_panel_propart -c "\dt" 2>/dev/null | head -20 || echo "Не вдалося підключитися до БД"
