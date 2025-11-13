#!/bin/bash

# Створення таблиць в базі даних

set -e

echo "🗄️  Створення таблиць в базі даних..."
echo ""

cd /opt/admin-pro-part

# Варіант 1: Тимчасово увімкнути synchronize
echo "📝 Оновлення database.ts для автоматичного створення таблиць..."

# Створюємо тимчасовий файл з synchronize: true
cat > admin-panel-backend/src/config/database.temp.ts << 'EOF'
import { DataSource } from 'typeorm';
import { entities } from '../entities';
import { migrations } from '../migrations';

export const AppDataSource = new DataSource({
  type: 'postgres',
  url: process.env.DATABASE_URL,
  synchronize: true, // ТИМЧАСОВО для створення таблиць
  logging: process.env.NODE_ENV === 'development',
  entities: entities,
  migrations: migrations,
});
EOF

# Копіюємо тимчасовий файл
cp admin-panel-backend/src/config/database.temp.ts admin-panel-backend/src/config/database.ts

# Перебудовуємо бекенд
echo "🔨 Перебудова бекенду..."
docker-compose -f docker-compose.prod.yml build admin-pro-part-backend

# Перезапускаємо бекенд (він автоматично створить таблиці)
echo "🔄 Перезапуск бекенду..."
docker-compose -f docker-compose.prod.yml up -d admin-pro-part-backend

# Чекаємо поки бекенд запуститься
echo "⏳ Очікування запуску бекенду (10 секунд)..."
sleep 10

# Перевіряємо логи
echo ""
echo "📋 Останні логи бекенду:"
docker logs --tail=20 admin-pro-part-backend

# Перевіряємо чи таблиці створені
echo ""
echo "🔍 Перевірка таблиць в БД..."
docker exec admin-pro-part-db psql -U admin -d admin_panel_propart -c "\dt" 2>/dev/null || \
docker exec admin-pro-part-db psql -U admin -d admin_panel_propart -c "\dt" || \
echo "   Не вдалося перевірити таблиці"

# Тепер вимикаємо synchronize назад
echo ""
echo "🔒 Вимкнення synchronize (повернення до безпечного режиму)..."
cat > admin-panel-backend/src/config/database.ts << 'EOF'
import { DataSource } from 'typeorm';
import { entities } from '../entities';
import { migrations } from '../migrations';

export const AppDataSource = new DataSource({
  type: 'postgres',
  url: process.env.DATABASE_URL,
  synchronize: false, // Вимикаємо після створення таблиць
  logging: process.env.NODE_ENV === 'development',
  entities: entities,
  migrations: migrations,
});
EOF

# Перебудовуємо знову
echo "🔨 Фінальна перебудова бекенду..."
docker-compose -f docker-compose.prod.yml build admin-pro-part-backend
docker-compose -f docker-compose.prod.yml up -d admin-pro-part-backend

echo ""
echo "✅ Готово! Таблиці мають бути створені"
echo ""
echo "📋 Перевірте логи:"
echo "   docker logs --tail=30 admin-pro-part-backend"

