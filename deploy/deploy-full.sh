#!/bin/bash

# Повний деплой з усіма міграціями та налаштуваннями

set -e

SERVER_IP="88.99.38.25"
SERVER_USER="root"
PROJECT_DIR="/opt/admin-pro-part"

echo "🚀 Повний деплой на production..."
echo "📡 Сервер: ${SERVER_IP}"
echo ""

read -sp "Введіть пароль для root@${SERVER_IP}: " SERVER_PASSWORD
echo ""

sshpass -p "${SERVER_PASSWORD}" ssh -o StrictHostKeyChecking=no ${SERVER_USER}@${SERVER_IP} << 'ENDSSH'
set -e

PROJECT_DIR="/opt/admin-pro-part"

echo "📂 Перехід до директорії проекту..."
cd ${PROJECT_DIR} || { echo "❌ Директорія ${PROJECT_DIR} не знайдена"; exit 1; }

echo ""
echo "📥 Оновлення коду з git..."
git fetch origin main

# Видаляємо конфліктні untracked файли
if [ -f "data_export_20251113_032400.sql" ]; then
    echo "   🗑️  Видаляю конфліктний файл..."
    rm -f data_export_20251113_032400.sql
fi

# Оновлюємо код
git pull origin main || { 
    echo "   ⚠️  Спробую через reset..."
    git reset --hard origin/main || { echo "❌ Помилка при git pull"; exit 1; }
}
echo "   ✅ Код оновлено"

echo ""
echo "🐳 Перезапуск контейнерів..."

if [ -f "docker-compose.prod.yml" ]; then
    echo "   🔄 Перезапуск frontend..."
    docker-compose -f docker-compose.prod.yml up -d --build admin-pro-part-frontend
    echo "   ✅ Frontend перезапущено"
    
    echo "   🔄 Перезапуск backend..."
    docker-compose -f docker-compose.prod.yml restart admin-pro-part-backend
    echo "   ✅ Backend перезапущено"
else
    echo "   ❌ docker-compose.prod.yml не знайдено"
    exit 1
fi

echo ""
echo "⏳ Очікування запуску контейнерів (15 секунд)..."
sleep 15

echo ""
echo "🗄️  Створення таблиць чату..."
docker-compose -f docker-compose.prod.yml exec -T admin-pro-part-backend npm run create:chat-tables 2>&1 | tail -5 || echo "   ⚠️  Помилка (можливо вже існують)"

echo ""
echo "📰 Імпорт новин..."
docker-compose -f docker-compose.prod.yml exec -T admin-pro-part-backend npm run import:news-txt 2>&1 | tail -10 || echo "   ⚠️  Помилка (можливо вже імпортовані)"

echo ""
echo "👤 Створення користувача anna@propart.ae..."
docker-compose -f docker-compose.prod.yml exec -T admin-pro-part-backend npm run create:user 2>&1 | tail -10 || echo "   ⚠️  Помилка (можливо вже існує)"

echo ""
echo "🔍 Перевірка статусу контейнерів:"
docker ps --format "table {{.Names}}\t{{.Status}}" | grep -E "admin-pro-part|NAMES" || true

echo ""
echo "🌐 Перевірка доступності:"
echo "   Frontend:"
curl -s -o /dev/null -w "   HTTP %{http_code}\n" http://localhost:3002 || echo "   ⚠️  Frontend не відповідає"
echo "   Backend:"
curl -s -o /dev/null -w "   HTTP %{http_code}\n" http://localhost:4001/api/health || echo "   ⚠️  Backend не відповідає"

echo ""
echo "✅ Повний деплой завершено!"

ENDSSH

echo ""
echo "✅ Деплой завершено!"

