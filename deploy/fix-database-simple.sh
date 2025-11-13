#!/bin/bash

# Простий спосіб створення таблиць - через прямі docker команди

set -e

echo "🗄️  Створення таблиць в базі даних..."
echo ""

cd /opt/admin-pro-part

# 1. Тимчасово увімкнути synchronize
echo "📝 Увімкнення synchronize для створення таблиць..."
sed -i 's/synchronize: false/synchronize: true/' admin-panel-backend/src/config/database.ts

# 2. Зупинити старий контейнер
echo "🛑 Зупинка старого контейнера..."
docker stop admin-pro-part-backend 2>/dev/null || true
docker rm admin-pro-part-backend 2>/dev/null || true

# 3. Перебудувати образ
echo "🔨 Перебудова образу бекенду..."
cd admin-panel-backend
docker build -t admin-pro-part-backend:latest .

# 4. Запустити контейнер
echo "🚀 Запуск нового контейнера..."
cd ..
docker run -d \
  --name admin-pro-part-backend \
  --network admin-pro-part_admin-network \
  -p 4001:4000 \
  --env-file admin-panel-backend/.env \
  -e NODE_ENV=production \
  -e DATABASE_URL=$(grep DATABASE_URL admin-panel-backend/.env | cut -d '=' -f2) \
  admin-pro-part-backend:latest

# 5. Чекаємо поки таблиці створяться
echo "⏳ Очікування створення таблиць (20 секунд)..."
sleep 20

# 6. Перевірка логів
echo ""
echo "📋 Останні логи:"
docker logs --tail=30 admin-pro-part-backend

# 7. Перевірка таблиці users
echo ""
echo "🔍 Перевірка таблиці users:"
docker exec admin-pro-part-db psql -U admin -d admin_panel_propart -c "\d users" 2>&1 | head -15 || echo "   Перевірка не вдалася"

# 8. Вимкнути synchronize
echo ""
echo "🔒 Вимкнення synchronize..."
sed -i 's/synchronize: true/synchronize: false/' admin-panel-backend/src/config/database.ts

# 9. Перебудувати та перезапустити знову
echo "🔨 Фінальна перебудова..."
docker stop admin-pro-part-backend
docker rm admin-pro-part-backend
cd admin-panel-backend
docker build -t admin-pro-part-backend:latest .
cd ..
docker run -d \
  --name admin-pro-part-backend \
  --network admin-pro-part_admin-network \
  -p 4001:4000 \
  --env-file admin-panel-backend/.env \
  -e NODE_ENV=production \
  -e DATABASE_URL=$(grep DATABASE_URL admin-panel-backend/.env | cut -d '=' -f2) \
  admin-pro-part-backend:latest

echo ""
echo "✅ Готово! Таблиці мають бути створені"
echo ""
echo "🧪 Спробуйте залогінитися:"
echo "   Email: admin@pro-part.online"
echo "   Password: $(grep ADMIN_PASSWORD admin-panel-backend/.env | cut -d '=' -f2)"

