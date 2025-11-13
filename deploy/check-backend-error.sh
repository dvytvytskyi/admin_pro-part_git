#!/bin/bash

# Перевірка помилки бекенду

echo "🔍 Діагностика помилки бекенду..."
echo ""

# Перевірка контейнерів
echo "1️⃣ Статус контейнерів:"
docker-compose -f docker-compose.prod.yml ps 2>/dev/null || docker ps | grep pro-part
echo ""

# Перевірка логів бекенду
echo "2️⃣ Останні логи бекенду (останні 50 рядків):"
docker-compose -f docker-compose.prod.yml logs --tail=50 admin-pro-part-backend 2>/dev/null || \
docker logs --tail=50 admin-pro-part-backend 2>/dev/null || \
docker logs --tail=50 $(docker ps | grep backend | grep pro-part | awk '{print $1}') 2>/dev/null || \
echo "   Не вдалося знайти логи"
echo ""

# Перевірка health endpoint
echo "3️⃣ Перевірка health endpoint:"
curl -s http://localhost:4001/health | jq . 2>/dev/null || curl -s http://localhost:4001/health
echo ""

# Перевірка .env файлу
echo "4️⃣ Перевірка .env файлу:"
if [ -f "admin-panel-backend/.env" ]; then
    echo "   ✅ .env файл існує"
    echo "   ADMIN_EMAIL: $(grep ADMIN_EMAIL admin-panel-backend/.env | cut -d '=' -f2)"
    echo "   DATABASE_URL встановлено: $(grep -q DATABASE_URL admin-panel-backend/.env && echo 'Так' || echo 'Ні')"
else
    echo "   ❌ .env файл не знайдено!"
fi
echo ""

# Тестовий запит до login
echo "5️⃣ Тестовий запит до /api/auth/login:"
curl -X POST http://localhost:4001/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test","password":"test"}' \
  -v 2>&1 | grep -A 10 "< HTTP" || echo "   Помилка запиту"
echo ""

echo "✅ Діагностика завершена"

