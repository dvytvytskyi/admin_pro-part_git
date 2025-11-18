#!/bin/bash

# Скрипт для повної міграції на новий сервер
# 1. Експортує дані зі старого сервера
# 2. Деплоїть на новий сервер
# 3. Імпортує дані на новий сервер

set -e

OLD_SERVER_IP="135.181.201.185"
OLD_SERVER_USER="root"
OLD_SERVER_PASSWORD="FNrtVkfCRwgW"

NEW_SERVER_IP="88.99.38.25"
NEW_SERVER_USER="root"
NEW_SERVER_PASSWORD="VandiPCEXeep"

PROJECT_DIR="/opt/admin-pro-part"
BACKUP_DIR="/opt/admin-pro-part/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="migration_backup_${TIMESTAMP}.sql"

echo "🚀 Міграція на новий сервер..."
echo "📡 Старий сервер: ${OLD_SERVER_IP}"
echo "📡 Новий сервер: ${NEW_SERVER_IP}"
echo ""

# Перевірка чи є sshpass
if ! command -v sshpass &> /dev/null; then
    echo "❌ sshpass не встановлено. Встановіть: brew install hudochenkov/sshpass/sshpass"
    exit 1
fi

echo "📦 Крок 1: Експорт даних зі старого сервера..."
echo ""

# Експорт даних зі старого сервера
sshpass -p "${OLD_SERVER_PASSWORD}" ssh -o StrictHostKeyChecking=no ${OLD_SERVER_USER}@${OLD_SERVER_IP} << ENDSSH
set -e

PROJECT_DIR="${PROJECT_DIR}"
BACKUP_DIR="${BACKUP_DIR}"
BACKUP_FILE="${BACKUP_FILE}"

echo "📁 Створення директорії для бекапів..."
mkdir -p \${BACKUP_DIR}

echo "📦 Експорт бази даних..."
DB_CONTAINER=\$(docker ps | grep postgres | grep pro-part | awk '{print \$1}')

if [ -z "\${DB_CONTAINER}" ]; then
    echo "❌ Контейнер БД не знайдено на старому сервері!"
    exit 1
fi

echo "✅ Контейнер БД: \${DB_CONTAINER}"

# Експорт даних (тільки дані, без структури)
docker exec \${DB_CONTAINER} pg_dump -U admin -d admin_panel_propart \
  --data-only \
  --no-owner \
  --no-privileges \
  --disable-triggers \
  > \${BACKUP_DIR}/\${BACKUP_FILE}

# Експорт структури окремо (для безпеки)
docker exec \${DB_CONTAINER} pg_dump -U admin -d admin_panel_propart \
  --schema-only \
  --no-owner \
  --no-privileges \
  > \${BACKUP_DIR}/schema_\${BACKUP_FILE}

echo "✅ Дані експортовані: \${BACKUP_DIR}/\${BACKUP_FILE}"
echo "✅ Структура експортована: \${BACKUP_DIR}/schema_\${BACKUP_FILE}"

# Перевірка розміру
echo ""
echo "📊 Розміри файлів:"
ls -lh \${BACKUP_DIR}/\${BACKUP_FILE} \${BACKUP_DIR}/schema_\${BACKUP_FILE}

# Підрахунок записів
echo ""
echo "📊 Кількість записів:"
echo "Properties:"
docker exec \${DB_CONTAINER} psql -U admin -d admin_panel_propart -t -c "SELECT COUNT(*) FROM properties;" || echo "0"
echo "Areas:"
docker exec \${DB_CONTAINER} psql -U admin -d admin_panel_propart -t -c "SELECT COUNT(*) FROM areas;" || echo "0"
echo "Developers:"
docker exec \${DB_CONTAINER} psql -U admin -d admin_panel_propart -t -c "SELECT COUNT(*) FROM developers;" || echo "0"

ENDSSH

echo ""
echo "✅ Крок 1 завершено!"
echo ""

echo "📦 Крок 2: Деплой на новий сервер..."
echo ""

# Запускаємо деплой на новий сервер
./deploy/deploy-new-server.sh

echo ""
echo "✅ Крок 2 завершено!"
echo ""

echo "📦 Крок 3: Копіювання даних на новий сервер..."
echo ""

# Копіюємо бекап на новий сервер
sshpass -p "${OLD_SERVER_PASSWORD}" ssh -o StrictHostKeyChecking=no ${OLD_SERVER_USER}@${OLD_SERVER_IP} \
  "cat ${BACKUP_DIR}/${BACKUP_FILE}" | \
sshpass -p "${NEW_SERVER_PASSWORD}" ssh -o StrictHostKeyChecking=no ${NEW_SERVER_USER}@${NEW_SERVER_IP} \
  "mkdir -p ${PROJECT_DIR}/backups && cat > ${PROJECT_DIR}/backups/${BACKUP_FILE}"

echo "✅ Дані скопійовано на новий сервер"
echo ""

echo "📦 Крок 4: Імпорт даних на новий сервер..."
echo ""

# Імпорт даних на новий сервер
sshpass -p "${NEW_SERVER_PASSWORD}" ssh -o StrictHostKeyChecking=no ${NEW_SERVER_USER}@${NEW_SERVER_IP} << ENDSSH
set -e

PROJECT_DIR="${PROJECT_DIR}"
BACKUP_FILE="${BACKUP_FILE}"

cd \${PROJECT_DIR}

echo "⏳ Очікування запуску БД (15 секунд)..."
sleep 15

# Знайти контейнер БД
DB_CONTAINER=\$(docker ps | grep postgres | grep pro-part | awk '{print \$1}')

if [ -z "\${DB_CONTAINER}" ]; then
    echo "❌ Контейнер БД не знайдено на новому сервері!"
    exit 1
fi

echo "✅ Контейнер БД: \${DB_CONTAINER}"

# Перевірка, чи БД готова
echo "🔍 Перевірка готовності БД..."
for i in {1..30}; do
    if docker exec \${DB_CONTAINER} pg_isready -U admin > /dev/null 2>&1; then
        echo "✅ БД готова"
        break
    fi
    if [ \$i -eq 30 ]; then
        echo "❌ БД не готова після 30 спроб"
        exit 1
    fi
    echo "   Спробa \$i/30..."
    sleep 2
done

# Перевірка наявності файлу
if [ ! -f "\${PROJECT_DIR}/backups/\${BACKUP_FILE}" ]; then
    echo "❌ Файл бекапу не знайдено: \${PROJECT_DIR}/backups/\${BACKUP_FILE}"
    exit 1
fi

echo "📊 Розмір файлу:"
ls -lh \${PROJECT_DIR}/backups/\${BACKUP_FILE}

echo ""
echo "⚠️  УВАГА: Це перезапише всі дані в БД на новому сервері!"
echo "📥 Починаю імпорт даних..."

# Імпорт даних
docker exec -i \${DB_CONTAINER} psql -U admin -d admin_panel_propart < \${PROJECT_DIR}/backups/\${BACKUP_FILE}

echo ""
echo "✅ Дані імпортовані!"
echo ""

# Перевірка кількості записів
echo "🔍 Перевірка імпортованих даних:"
echo ""
echo "Properties:"
docker exec \${DB_CONTAINER} psql -U admin -d admin_panel_propart -t -c "SELECT COUNT(*) FROM properties;" || echo "0"
echo "Areas:"
docker exec \${DB_CONTAINER} psql -U admin -d admin_panel_propart -t -c "SELECT COUNT(*) FROM areas;" || echo "0"
echo "Developers:"
docker exec \${DB_CONTAINER} psql -U admin -d admin_panel_propart -t -c "SELECT COUNT(*) FROM developers;" || echo "0"
echo "Facilities:"
docker exec \${DB_CONTAINER} psql -U admin -d admin_panel_propart -t -c "SELECT COUNT(*) FROM facilities;" || echo "0"

echo ""
echo "🔄 Перезапуск бекенду для застосування змін..."
docker-compose -f \${PROJECT_DIR}/docker-compose.prod.yml restart admin-pro-part-backend

echo ""
echo "⏳ Очікування запуску бекенду (10 секунд)..."
sleep 10

echo ""
echo "🧪 Перевірка роботи бекенду..."
if curl -s --max-time 5 http://localhost:4001/health > /dev/null 2>&1; then
    echo "✅ Бекенд працює"
else
    echo "⚠️  Бекенд може потребувати більше часу"
fi

ENDSSH

echo ""
echo "✅ Міграція завершена!"
echo ""
echo "📋 Підсумок:"
echo "   ✅ Дані експортовані зі старого сервера (${OLD_SERVER_IP})"
echo "   ✅ Проект розгорнуто на новому сервері (${NEW_SERVER_IP})"
echo "   ✅ Дані імпортовані на новий сервер"
echo ""
echo "🌐 Новий сервер: http://${NEW_SERVER_IP}:3002"
echo "🌐 Домен: http://system.pro-part.online (якщо DNS налаштовано)"
echo ""
echo "📝 Наступні кроки:"
echo "   1. Оновіть DNS для system.pro-part.online на ${NEW_SERVER_IP}"
echo "   2. Перевірте роботу сайту"
echo "   3. Налаштуйте SSL: certbot --nginx -d system.pro-part.online"
echo "   4. Перевірте логи: docker logs admin-pro-part-backend -f"

