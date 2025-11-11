#!/bin/bash

# Скрипт для оновлення ТІЛЬКИ off-plan properties на продакшн
# Secondary properties НЕ чіпаємо!
# Використання: ./deploy/update-offplan-production.sh

set -e

SERVER_IP="135.181.201.185"
SERVER_USER="root"
SERVER_PASSWORD="FNrtVkfCRwgW"
PROJECT_DIR="/opt/admin-panel"
BACKEND_DIR="$PROJECT_DIR/admin-panel-backend"

echo "🚀 Оновлення off-plan properties на продакшн..."
echo "⚠️  УВАГА: Secondary properties НЕ будуть змінені!"
echo ""

# Перевірка чи встановлено sshpass
if ! command -v sshpass &> /dev/null; then
    echo "⚠️  sshpass не встановлено. Встановлюємо..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if ! command -v brew &> /dev/null; then
            echo "❌ Homebrew не встановлено. Встановіть sshpass вручну"
            exit 1
        fi
        brew install hudochenkov/sshpass/sshpass 2>/dev/null || true
    fi
fi

# Крок 1: Завантажити all_properties.json на сервер
echo "📤 Крок 1: Завантаження all_properties.json на сервер..."
if [ -f "all_properties.json" ]; then
    sshpass -p "${SERVER_PASSWORD}" scp -o StrictHostKeyChecking=no all_properties.json ${SERVER_USER}@${SERVER_IP}:${PROJECT_DIR}/all_properties.json
    echo "✅ all_properties.json завантажено"
else
    echo "❌ Файл all_properties.json не знайдено локально!"
    exit 1
fi

# Створюємо скрипт для виконання на сервері
cat > /tmp/update_offplan_remote.sh << 'REMOTE_SCRIPT'
#!/bin/bash
set -e

PROJECT_DIR="/opt/admin-panel"
BACKEND_DIR="${PROJECT_DIR}/admin-panel-backend"
cd ${PROJECT_DIR}

echo ""
echo "📥 Крок 2: Оновлення коду з Git..."
git pull origin main || {
    echo "⚠️  Не вдалося оновити код з Git. Продовжуємо..."
}

echo ""
echo "🔨 Крок 3: Перебудова бекенду (з компіляцією TypeScript)..."
docker-compose -f docker-compose.prod.yml build admin-panel-backend || {
    echo "❌ Помилка перебудови бекенду"
    exit 1
}

echo ""
echo "📦 Перевірка компіляції TypeScript..."
docker exec for-you-admin-panel-backend-prod npm run build 2>&1 || {
    echo "⚠️  Компіляція не вдалася, але продовжуємо (можливо вже скомпільовано)"
}

echo ""
echo "🛑 Крок 4: Зупинка старого контейнера..."
docker-compose -f docker-compose.prod.yml stop admin-panel-backend 2>/dev/null || true
docker rm -f for-you-admin-panel-backend-prod 2>/dev/null || true

echo ""
echo "🔄 Крок 5: Запуск нового контейнера..."
docker-compose -f docker-compose.prod.yml up -d --force-recreate --no-deps admin-panel-backend || {
    echo "❌ Помилка запуску бекенду"
    exit 1
}

echo ""
echo "⏳ Очікування запуску контейнера (15 секунд)..."
sleep 15

echo ""
echo "📊 Крок 6: Перевірка статистики БД ДО оновлення..."
# Спробуємо виконати через node dist/... (production)
docker exec for-you-admin-panel-backend-prod node dist/scripts/count-properties.js 2>&1 | tail -10 || {
    echo "⚠️  Скрипт не знайдено в dist/, перевіряємо чи скомпільовано..."
    # Перевіряємо чи є dist директорія
    docker exec for-you-admin-panel-backend-prod test -d dist || {
        echo "   ❌ Директорія dist не існує. TypeScript не скомпільований."
        echo "   Перебудовуємо контейнер..."
        exit 1
    }
    echo "   ✅ Директорія dist існує, але скрипт не знайдено"
}

echo ""
echo "🧹 Крок 7: Очищення СТАРИХ off-plan properties..."
echo "⚠️  УВАГА: Видаляємо ТІЛЬКИ off-plan properties!"
echo "   Secondary properties НЕ будуть зачіплені!"
# Спочатку пробуємо через скрипт
docker exec for-you-admin-panel-backend-prod node dist/scripts/clear-offplan-properties.js 2>&1 || {
    echo "⚠️  Скрипт clear-offplan-properties.js не знайдено, використовую SQL напряму..."
    echo "   Виконую SQL: DELETE FROM properties WHERE propertyType = 'off-plan'"
    docker exec for-you-admin-panel-postgres-prod psql -U admin -d admin_panel -c "DELETE FROM properties WHERE \"propertyType\" = 'off-plan';" || {
        echo "❌ Помилка очищення off-plan properties"
        exit 1
    }
    echo "   ✅ Off-plan properties видалено через SQL"
}

echo ""
echo "📥 Крок 8: Імпорт НОВИХ off-plan properties з all_properties.json..."
echo "   Це може зайняти 5-10 хвилин..."
docker exec for-you-admin-panel-backend-prod node dist/scripts/import-all-properties.js 2>&1 || {
    echo "❌ Помилка імпорту properties"
    echo "Перевіряємо логи..."
    docker logs for-you-admin-panel-backend-prod --tail 50
    echo ""
    echo "⚠️  Можливі причини:"
    echo "   1. Файл all_properties.json не знайдено"
    echo "   2. Помилка компіляції TypeScript"
    echo "   3. Помилка підключення до БД"
    exit 1
}

echo ""
echo "📊 Крок 9: Перевірка статистики БД ПІСЛЯ оновлення..."
docker exec for-you-admin-panel-backend-prod node dist/scripts/count-properties.js 2>&1 | tail -10 || true

echo ""
echo "🔄 Крок 10: Перезапуск бекенду для застосування змін..."
docker-compose -f docker-compose.prod.yml restart admin-panel-backend

echo ""
echo "⏳ Очікування перезапуску (10 секунд)..."
sleep 10

echo ""
echo "📋 Останні 20 рядків логів бекенду:"
docker-compose -f docker-compose.prod.yml logs --tail 20 admin-panel-backend

echo ""
echo "✅ Оновлення off-plan properties завершено!"
echo ""
echo "📊 Підсумок:"
echo "   - Код оновлено з Git"
echo "   - Бекенд перебудовано"
echo "   - Старі off-plan properties видалено"
echo "   - Нові off-plan properties імпортовано"
echo "   - Secondary properties НЕ змінені"
REMOTE_SCRIPT

chmod +x /tmp/update_offplan_remote.sh

echo ""
echo "📤 Завантаження скрипту на сервер..."
sshpass -p "${SERVER_PASSWORD}" scp -o StrictHostKeyChecking=no /tmp/update_offplan_remote.sh ${SERVER_USER}@${SERVER_IP}:/tmp/update_offplan_remote.sh

echo ""
echo "▶️  Виконання скрипту на сервері..."
echo "⚠️  Це може зайняти 5-10 хвилин..."
sshpass -p "${SERVER_PASSWORD}" ssh -o StrictHostKeyChecking=no ${SERVER_USER}@${SERVER_IP} 'bash /tmp/update_offplan_remote.sh'

echo ""
echo "🎉 Готово! Off-plan properties оновлено на продакшн."
echo ""
echo "📝 Наступні кроки:"
echo "   1. Перевірте адмін панель: https://admin.foryou-realestate.com"
echo "   2. Перевірте, що off-plan properties відображаються правильно"
echo "   3. Перевірте, що secondary properties не змінені"

