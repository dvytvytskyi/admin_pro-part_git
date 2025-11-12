#!/bin/bash

# Скрипт для перевірки підключення до БД без використання Docker команд

echo "🔍 Перевірка підключення до бази даних..."
echo ""

# Перевірка .env файлу
if [ -f .env ]; then
    echo "✅ .env файл існує"
    DATABASE_URL=$(grep DATABASE_URL .env | cut -d '=' -f2)
    echo "📋 DATABASE_URL: $DATABASE_URL"
else
    echo "❌ .env файл не знайдено!"
    exit 1
fi

# Витягуємо дані з DATABASE_URL
# Формат: postgresql://user:password@host:port/database
DB_HOST=$(echo $DATABASE_URL | sed -n 's/.*@\([^:]*\):.*/\1/p')
DB_PORT=$(echo $DATABASE_URL | sed -n 's/.*:\([0-9]*\)\/.*/\1/p')
DB_NAME=$(echo $DATABASE_URL | sed -n 's/.*\/\([^?]*\).*/\1/p')
DB_USER=$(echo $DATABASE_URL | sed -n 's/.*:\/\/\([^:]*\):.*/\1/p')
DB_PASS=$(echo $DATABASE_URL | sed -n 's/.*:\/\/[^:]*:\([^@]*\)@.*/\1/p')

echo ""
echo "📊 Параметри підключення:"
echo "   Host: $DB_HOST"
echo "   Port: $DB_PORT"
echo "   Database: $DB_NAME"
echo "   User: $DB_USER"
echo ""

# Перевірка, чи порт відкритий
echo "🔌 Перевірка порту $DB_PORT..."
if command -v nc &> /dev/null; then
    if nc -z localhost $DB_PORT 2>/dev/null; then
        echo "✅ Порт $DB_PORT відкритий"
    else
        echo "❌ Порт $DB_PORT закритий або не доступний"
        echo ""
        echo "💡 Можливі рішення:"
        echo "   1. Перевірте, чи запущений Docker Desktop"
        echo "   2. Запустіть базу даних: docker-compose up -d admin-panel-db"
        echo "   3. Перевірте логи: docker logs admin-panel-db"
    fi
else
    echo "⚠️  nc (netcat) не встановлено, пропускаємо перевірку порту"
fi

echo ""
echo "📝 Наступні кроки:"
echo "   1. Переконайтеся, що Docker Desktop запущений"
echo "   2. Запустіть базу даних: cd admin-panel-backend && docker-compose up -d admin-panel-db"
echo "   3. Запустіть бекенд: npm run dev"
echo "   4. Перевірте логи бекенду на наявність помилок підключення"

