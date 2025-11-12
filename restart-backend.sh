#!/bin/bash

# Скрипт для перезапуску admin-panel-backend

echo "🔄 Перезапуск admin-panel-backend..."

# Перейдемо в директорію backend
cd "$(dirname "$0")/admin-panel-backend" || exit 1

# Знайдемо процес, який запущений на порту 4000 або процес node з server.ts
echo "🔍 Шукаємо запущений процес backend..."

# Зупиняємо процес на порту 4000 (якщо він запущений)
if lsof -ti:4000 > /dev/null 2>&1; then
    echo "⏹️  Зупиняємо процес на порту 4000..."
    lsof -ti:4000 | xargs kill -9 2>/dev/null
    sleep 2
fi

# Або знайти процес ts-node-dev з server.ts
if pgrep -f "ts-node-dev.*server.ts" > /dev/null; then
    echo "⏹️  Зупиняємо ts-node-dev процес..."
    pkill -f "ts-node-dev.*server.ts"
    sleep 2
fi

# Або знайти процес node з dist/server.js
if pgrep -f "node.*dist/server.js" > /dev/null; then
    echo "⏹️  Зупиняємо node процес..."
    pkill -f "node.*dist/server.js"
    sleep 2
fi

# Перевіряємо, чи потрібно збудувати проект
if [ ! -d "dist" ] || [ "src/server.ts" -nt "dist/server.js" ]; then
    echo "📦 Збираємо проект..."
    npm run build
fi

# Запускаємо сервер
echo "🚀 Запускаємо backend сервер..."
echo ""
echo "Виберіть режим запуску:"
echo "1. Development (npm run dev) - з автоматичним перезапуском"
echo "2. Production (npm start) - зі зібраного коду"
echo ""
read -p "Введіть номер (1 або 2, за замовчуванням 1): " mode

if [ "$mode" = "2" ]; then
    echo "▶️  Запускаємо в production режимі..."
    npm start
else
    echo "▶️  Запускаємо в development режимі..."
    npm run dev
fi

