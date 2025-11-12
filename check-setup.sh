#!/bin/bash

# Скрипт для перевірки налаштування проекту після міграції

set -e

echo "🔍 Перевірка налаштування проекту..."
echo ""

# Кольори для виводу
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Функція для перевірки файлу
check_file() {
    if [ -f "$1" ]; then
        echo -e "${GREEN}✅ $2${NC}"
        return 0
    else
        echo -e "${RED}❌ $2 не знайдено${NC}"
        return 1
    fi
}

# Функція для перевірки директорії
check_dir() {
    if [ -d "$1" ]; then
        echo -e "${GREEN}✅ $2${NC}"
        return 0
    else
        echo -e "${RED}❌ $2 не знайдено${NC}"
        return 1
    fi
}

# Функція для перевірки змінної в .env файлі
check_env_var() {
    if [ -f "$1" ] && grep -q "$2" "$1"; then
        echo -e "${GREEN}✅ $3 знайдено в $1${NC}"
        return 0
    else
        echo -e "${YELLOW}⚠️  $3 не знайдено в $1${NC}"
        return 1
    fi
}

echo "1️⃣ Перевірка структури проекту..."
check_dir "admin-panel" "admin-panel директорія"
check_dir "admin-panel-backend" "admin-panel-backend директорія"
check_file "admin-panel/next.config.js" "next.config.js"
check_file "admin-panel-backend/docker-compose.yml" "docker-compose.yml"
check_file "admin-panel-backend/src/server.ts" "server.ts"
echo ""

echo "2️⃣ Перевірка залежностей..."
if [ -d "admin-panel/node_modules" ]; then
    echo -e "${GREEN}✅ admin-panel залежності встановлені${NC}"
else
    echo -e "${YELLOW}⚠️  admin-panel залежності не встановлені (запустіть: cd admin-panel && npm install)${NC}"
fi

if [ -d "admin-panel-backend/node_modules" ]; then
    echo -e "${GREEN}✅ admin-panel-backend залежності встановлені${NC}"
else
    echo -e "${YELLOW}⚠️  admin-panel-backend залежності не встановлені (запустіть: cd admin-panel-backend && npm install)${NC}"
fi
echo ""

echo "3️⃣ Перевірка .env файлів..."
if [ -f "admin-panel-backend/.env" ]; then
    echo -e "${GREEN}✅ admin-panel-backend/.env файл існує${NC}"
    check_env_var "admin-panel-backend/.env" "DATABASE_URL" "DATABASE_URL"
    check_env_var "admin-panel-backend/.env" "PORT" "PORT"
    check_env_var "admin-panel-backend/.env" "ADMIN_JWT_SECRET" "ADMIN_JWT_SECRET"
else
    echo -e "${YELLOW}⚠️  admin-panel-backend/.env файл не знайдено (створіть з .env.example)${NC}"
fi

if [ -f "admin-panel/.env.local" ]; then
    echo -e "${GREEN}✅ admin-panel/.env.local файл існує${NC}"
    check_env_var "admin-panel/.env.local" "NEXT_PUBLIC_API_URL" "NEXT_PUBLIC_API_URL"
else
    echo -e "${YELLOW}⚠️  admin-panel/.env.local файл не знайдено (опціонально для локальної розробки)${NC}"
fi
echo ""

echo "4️⃣ Перевірка бази даних..."
if docker ps | grep -q "admin-panel-db"; then
    echo -e "${GREEN}✅ База даних запущена${NC}"
else
    echo -e "${YELLOW}⚠️  База даних не запущена (запустіть: cd admin-panel-backend && docker-compose up -d admin-panel-db)${NC}"
fi
echo ""

echo "5️⃣ Перевірка конфігурації..."
# Перевірка next.config.js
if grep -q "localhost:4000" "admin-panel/next.config.js"; then
    echo -e "${GREEN}✅ next.config.js налаштовано для локальної розробки${NC}"
else
    echo -e "${YELLOW}⚠️  next.config.js може потребувати налаштування${NC}"
fi

# Перевірка api.ts
if grep -q "localhost:4000" "admin-panel/src/lib/api.ts"; then
    echo -e "${GREEN}✅ api.ts налаштовано для локальної розробки${NC}"
else
    echo -e "${YELLOW}⚠️  api.ts може потребувати налаштування${NC}"
fi
echo ""

echo "📋 Підсумок:"
echo "Якщо всі перевірки пройшли успішно, ви можете запустити проекти:"
echo ""
echo "  # Бекенд"
echo "  cd admin-panel-backend && npm run dev"
echo ""
echo "  # Фронтенд (в іншому терміналі)"
echo "  cd admin-panel && npm run dev"
echo ""
echo "Детальний чеклист: ./SETUP_CHECKLIST.md"
echo "Швидкий старт: ./QUICK_START.md"

