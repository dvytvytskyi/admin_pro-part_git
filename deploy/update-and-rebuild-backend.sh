#!/bin/bash

# Скрипт для оновлення коду та перебудови бекенду на продакшені
# Використання: ./deploy/update-and-rebuild-backend.sh

set -e

SERVER_IP="135.181.201.185"
SERVER_USER="root"
SERVER_PASSWORD="FNrtVkfCRwgW"
PROJECT_DIR="/opt/admin-panel"

echo "🚀 Оновлення коду та перебудова бекенду..."
echo ""

# Перевірка чи встановлено sshpass
if ! command -v sshpass &> /dev/null; then
    echo "⚠️  sshpass не встановлено. Встановлюємо..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if ! command -v brew &> /dev/null; then
            echo "❌ Homebrew не встановлено. Встановіть sshpass вручну:"
            echo "   brew install hudochenkov/sshpass/sshpass"
            exit 1
        fi
        brew install hudochenkov/sshpass/sshpass 2>/dev/null || {
            echo "❌ Не вдалося встановити sshpass автоматично"
            echo "   Встановіть вручну: brew install hudochenkov/sshpass/sshpass"
            exit 1
        }
    else
        sudo apt-get update -qq
        sudo apt-get install -y sshpass 2>/dev/null || {
            echo "❌ Не вдалося встановити sshpass"
            exit 1
        }
    fi
fi

# Створюємо скрипт для виконання на сервері
cat > /tmp/update_backend_remote.sh << 'REMOTE_SCRIPT'
#!/bin/bash
set -e

PROJECT_DIR="/opt/admin-panel"
cd ${PROJECT_DIR} || {
    echo "❌ Проект не знайдено в ${PROJECT_DIR}"
    exit 1
}

echo "📥 Оновлення коду з Git..."
git pull origin main || {
    echo "⚠️  Не вдалося оновити код з Git"
    echo "   Перевірте чи є зміни для коміту"
}

echo ""
echo "🔨 Перебудова бекенду..."
docker-compose -f docker-compose.prod.yml build --no-cache admin-panel-backend || {
    echo "❌ Помилка перебудови бекенду"
    exit 1
}

echo ""
echo "🛑 Зупинка та видалення старого контейнера..."
# Використовуємо docker-compose down для повного видалення, щоб уникнути помилки ContainerConfig
docker-compose -f docker-compose.prod.yml stop admin-panel-backend 2>/dev/null || true
docker rm -f for-you-admin-panel-backend-prod 2>/dev/null || true
# Видаляємо всі контейнери з таким ім'ям
docker ps -a | grep for-you-admin-panel-backend-prod | awk '{print $1}' | xargs -r docker rm -f 2>/dev/null || true

echo ""
echo "🔄 Запуск нового контейнера..."
# Використовуємо --force-recreate щоб гарантувати створення нового контейнера
docker-compose -f docker-compose.prod.yml up -d --force-recreate --no-deps admin-panel-backend || {
    echo "❌ Помилка запуску бекенду через docker-compose"
    echo "   Спробуємо через прямий docker run..."
    
    # Fallback: використовуємо прямий docker run
    DB_PASSWORD=$(grep "DB_PASSWORD" .env 2>/dev/null | cut -d '=' -f2 || echo "admin123")
    NETWORK="admin-panel_admin-network"
    IMAGE_NAME="admin-panel_admin-panel-backend:latest"
    
    docker run -d \
      --name for-you-admin-panel-backend-prod \
      --restart unless-stopped \
      -p 127.0.0.1:4000:4000 \
      --network ${NETWORK} \
      -e NODE_ENV=production \
      -e DATABASE_URL="postgresql://admin:${DB_PASSWORD}@for-you-admin-panel-postgres-prod:5432/admin_panel" \
      -v ${PROJECT_DIR}/admin-panel-backend/uploads:/app/uploads \
      --env-file ${PROJECT_DIR}/admin-panel-backend/.env \
      ${IMAGE_NAME} || {
        echo "❌ Помилка запуску через docker run"
        exit 1
      }
}

echo ""
echo "⏳ Очікування запуску (10 секунд)..."
sleep 10

echo ""
echo "📊 Статус контейнерів:"
docker-compose -f docker-compose.prod.yml ps admin-panel-backend

echo ""
echo "📋 Останні 30 рядків логів бекенду:"
docker-compose -f docker-compose.prod.yml logs --tail 30 admin-panel-backend

echo ""
echo "✅ Готово!"
REMOTE_SCRIPT

chmod +x /tmp/update_backend_remote.sh

echo "📤 Завантаження скрипту на сервер..."
sshpass -p "${SERVER_PASSWORD}" scp -o StrictHostKeyChecking=no /tmp/update_backend_remote.sh ${SERVER_USER}@${SERVER_IP}:/tmp/update_backend_remote.sh

echo ""
echo "▶️  Виконання скрипту на сервері..."
sshpass -p "${SERVER_PASSWORD}" ssh -o StrictHostKeyChecking=no ${SERVER_USER}@${SERVER_IP} 'bash /tmp/update_backend_remote.sh'

echo ""
echo "✅ Оновлення завершено!"

