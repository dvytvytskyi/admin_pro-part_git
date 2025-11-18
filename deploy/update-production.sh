#!/bin/bash

# Скрипт для оновлення коду на production
# Просто робить git pull та перезапускає контейнери

set -e

SERVER_IP="88.99.38.25"
SERVER_USER="root"
PROJECT_DIR="/opt/admin-pro-part"

echo "🔄 Оновлення коду на production..."
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

# Зберігаємо зміни та оновлюємо код
git fetch origin main

# Перевіряємо, чи є конфліктні файли
CONFLICT_FILES=$(git diff --name-only origin/main 2>/dev/null || true)
if [ -n "$CONFLICT_FILES" ]; then
    echo "   ⚠️  Виявлено локальні зміни, зберігаю..."
    git stash || true
fi

# Видаляємо конфліктні untracked файли (якщо потрібно)
if [ -f "data_export_20251113_032400.sql" ]; then
    echo "   🗑️  Видаляю конфліктний файл data_export_20251113_032400.sql..."
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

# Перезапуск frontend (Next.js потребує rebuild після змін в next.config.js)
if [ -f "docker-compose.prod.yml" ]; then
    echo "   🔄 Перезапуск frontend..."
    docker-compose -f docker-compose.prod.yml up -d --build admin-pro-part-frontend
    echo "   ✅ Frontend перезапущено"
    
    echo "   🔄 Перезапуск backend..."
    docker-compose -f docker-compose.prod.yml restart admin-pro-part-backend
    echo "   ✅ Backend перезапущено"
else
    echo "   ⚠️  docker-compose.prod.yml не знайдено"
fi

echo ""
echo "⏳ Очікування запуску контейнерів (10 секунд)..."
sleep 10

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
echo "✅ Оновлення завершено!"

ENDSSH

echo ""
echo "✅ Деплой завершено!"

