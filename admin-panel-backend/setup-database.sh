#!/bin/bash

echo "🚀 Налаштування бази даних для admin_pro-part"
echo ""

cd "$(dirname "$0")"

# Перевірка .env
if [ ! -f .env ]; then
    echo "❌ .env файл не знайдено!"
    echo "Створіть .env файл з правильним DATABASE_URL"
    exit 1
fi

DATABASE_URL=$(grep DATABASE_URL .env | cut -d '=' -f2)
echo "📋 DATABASE_URL: $DATABASE_URL"
echo ""

# Перевірка підключення
echo "🔍 Перевірка підключення до БД..."
if curl -s http://localhost:4000/health 2>/dev/null | grep -q "connected"; then
    echo "✅ База даних підключена"
else
    echo "⚠️  База даних не підключена"
    echo "   Переконайтеся, що бекенд запущений: npm run dev"
    echo ""
fi

echo ""
echo "📊 Наступні кроки:"
echo "   1. Запустіть seed для створення базових даних:"
echo "      npm run seed"
echo ""
echo "   2. Якщо є дані для імпорту, використайте:"
echo "      npm run import:all-properties"
echo "      або"
echo "      npm run import:offplan"
echo "      npm run import:secondary"
echo ""

