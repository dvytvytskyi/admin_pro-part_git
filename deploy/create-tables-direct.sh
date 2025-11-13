#!/bin/bash

# Створення таблиць напряму в БД

set -e

echo "🗄️  Створення таблиці users в БД..."
echo ""

cd /opt/admin-pro-part

# 1. Знайти контейнер БД
DB_CONTAINER=$(docker ps | grep postgres | grep pro-part | awk '{print $1}' | head -1)

if [ -z "$DB_CONTAINER" ]; then
    echo "❌ Контейнер БД не знайдено!"
    exit 1
fi

echo "✅ Контейнер БД: $DB_CONTAINER"

# 2. Створити таблицю users
echo ""
echo "📝 Створення таблиці users..."
docker exec -i $DB_CONTAINER psql -U admin -d admin_panel_propart << 'SQL'
-- Створення таблиці users
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL DEFAULT 'CLIENT' CHECK (role IN ('CLIENT', 'BROKER', 'INVESTOR', 'ADMIN')),
    status VARCHAR(50) NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('PENDING', 'ACTIVE', 'BLOCKED', 'REJECTED')),
    license_number VARCHAR(255),
    google_id VARCHAR(255),
    apple_id VARCHAR(255),
    avatar VARCHAR(255),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Створення індексів
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_phone ON users(phone);
SQL

# 3. Перевірка
echo ""
echo "✅ Таблиця users створена!"
echo ""
echo "🔍 Перевірка:"
docker exec $DB_CONTAINER psql -U admin -d admin_panel_propart -c "\d users"

echo ""
echo "✅ Готово! Тепер можна логінитися"

