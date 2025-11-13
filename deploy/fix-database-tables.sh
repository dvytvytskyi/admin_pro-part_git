#!/bin/bash

# Виправлення: створення таблиць в БД

set -e

echo "🗄️  Створення таблиць в базі даних..."
echo ""

cd /opt/admin-pro-part

# Тимчасово увімкнути synchronize для створення таблиць
echo "📝 Тимчасово увімкнення synchronize для створення таблиць..."

# Зберігаємо оригінальний файл
cp admin-panel-backend/src/config/database.ts admin-panel-backend/src/config/database.ts.backup

# Створюємо новий файл з synchronize: true
cat > admin-panel-backend/src/config/database.ts << 'EOF'
import { DataSource } from 'typeorm';
import dotenv from 'dotenv';
import { entities } from '../entities';

dotenv.config();

const isProduction = process.env.NODE_ENV === 'production';
const migrationsPath = isProduction ? ['dist/migrations/**/*.js'] : ['src/migrations/**/*.ts'];

export const AppDataSource = new DataSource({
  type: 'postgres',
  url: process.env.DATABASE_URL,
  synchronize: true, // ТИМЧАСОВО для створення таблиць
  logging: process.env.NODE_ENV === 'development',
  entities: entities,
  migrations: migrationsPath,
});
EOF

echo "🔨 Перебудова бекенду..."
docker-compose -f docker-compose.prod.yml build admin-pro-part-backend

echo "🔄 Перезапуск бекенду (він створить таблиці)..."
docker-compose -f docker-compose.prod.yml up -d admin-pro-part-backend

echo "⏳ Очікування створення таблиць (15 секунд)..."
sleep 15

echo ""
echo "📋 Перевірка логів:"
docker logs --tail=30 admin-pro-part-backend | grep -E "Table|created|synchronize|error" || docker logs --tail=30 admin-pro-part-backend

# Перевірка чи таблиця users існує
echo ""
echo "🔍 Перевірка таблиці users:"
docker exec admin-pro-part-db psql -U admin -d admin_panel_propart -c "\d users" 2>&1 | head -10 || echo "   Таблиця ще не створена"

# Відновлюємо synchronize: false
echo ""
echo "🔒 Вимкнення synchronize (повернення до безпечного режиму)..."
cp admin-panel-backend/src/config/database.ts.backup admin-panel-backend/src/config/database.ts

echo "🔨 Фінальна перебудова бекенду..."
docker-compose -f docker-compose.prod.yml build admin-pro-part-backend
docker-compose -f docker-compose.prod.yml up -d admin-pro-part-backend

echo ""
echo "✅ Готово!"
echo ""
echo "📋 Перевірте чи таблиці створені:"
echo "   docker exec admin-pro-part-db psql -U admin -d admin_panel_propart -c '\\dt'"
echo ""
echo "🧪 Спробуйте залогінитися знову"

