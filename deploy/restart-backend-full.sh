#!/bin/bash

# Повний перезапуск бекенду

set -e

SERVER_IP="135.181.201.185"
SERVER_USER="root"
DOMAIN="system.pro-part.online"

echo "🔄 Повний перезапуск бекенду..."
echo ""

read -sp "Введіть пароль для root@${SERVER_IP}: " SERVER_PASSWORD
echo ""

sshpass -p "${SERVER_PASSWORD}" ssh -o StrictHostKeyChecking=no ${SERVER_USER}@${SERVER_IP} << 'ENDSSH'
set -e

echo "1️⃣  Зупинка бекенду контейнера..."
if docker ps | grep -q admin-panel-backend; then
    docker stop admin-panel-backend
    echo "   ✅ Контейнер зупинено"
else
    echo "   ℹ️  Контейнер вже зупинений"
fi
echo ""

echo "2️⃣  Видалення старого контейнера..."
if docker ps -a | grep -q admin-panel-backend; then
    docker rm admin-panel-backend || echo "   ⚠️  Не вдалося видалити (можливо вже видалено)"
    echo "   ✅ Старий контейнер видалено"
else
    echo "   ℹ️  Контейнер не знайдено"
fi
echo ""

echo "3️⃣  Пошук docker-compose файлу..."
BACKEND_DIR=""
if [ -d "/root/admin_pro-part/admin-panel-backend" ]; then
    BACKEND_DIR="/root/admin_pro-part/admin-panel-backend"
    echo "   ✅ Знайдено: $BACKEND_DIR"
elif [ -d "/root/admin-panel-backend" ]; then
    BACKEND_DIR="/root/admin-panel-backend"
    echo "   ✅ Знайдено: $BACKEND_DIR"
else
    echo "   ⚠️  Директорію бекенду не знайдено"
    echo "   🔍 Шукаємо..."
    find /root -type d -name "admin-panel-backend" 2>/dev/null | head -1
    FOUND_DIR=$(find /root -type d -name "admin-panel-backend" 2>/dev/null | head -1)
    if [ -n "$FOUND_DIR" ]; then
        BACKEND_DIR="$FOUND_DIR"
        echo "   ✅ Знайдено: $BACKEND_DIR"
    fi
fi
echo ""

if [ -n "$BACKEND_DIR" ] && [ -f "$BACKEND_DIR/docker-compose.yml" ]; then
    echo "4️⃣  Запуск бекенду через docker-compose..."
    cd "$BACKEND_DIR"
    docker-compose up -d
    echo "   ✅ Docker Compose запущено"
    echo ""
    
    echo "5️⃣  Чекаємо 10 секунд для ініціалізації..."
    sleep 10
    echo ""
    
    echo "6️⃣  Перевірка статусу..."
    if docker ps | grep -q admin-panel-backend; then
        echo "   ✅ Бекенд контейнер запущений"
        echo ""
        echo "   📋 Статус контейнера:"
        docker ps | grep admin-panel-backend
        echo ""
        echo "   📋 Останні логи:"
        docker logs admin-panel-backend --tail 20 2>&1
        echo ""
        echo "   🧪 Тест /health:"
        sleep 3
        if curl -s --max-time 5 http://localhost:4001/health > /dev/null 2>&1; then
            curl -s http://localhost:4001/health
            echo ""
            echo "   ✅ Бекенд працює!"
        else
            echo "   ❌ Бекенд не відповідає"
            echo ""
            echo "   📋 Детальні логи:"
            docker logs admin-panel-backend --tail 50 2>&1
        fi
    else
        echo "   ❌ Бекенд контейнер не запустився"
        echo ""
        echo "   📋 Логи docker-compose:"
        docker-compose logs --tail 30 2>&1
    fi
else
    echo "   ❌ Docker Compose файл не знайдено"
    echo ""
    echo "   🔍 Альтернатива: перевірка, чи бекенд запущений через PM2 або systemd..."
    echo ""
    
    # Перевірка PM2
    if command -v pm2 > /dev/null 2>&1; then
        echo "   📋 PM2 процеси:"
        pm2 list || echo "   ⚠️  PM2 не працює"
    fi
    
    # Перевірка systemd
    if systemctl list-units | grep -q admin-panel-backend; then
        echo "   📋 Systemd сервіс:"
        systemctl status admin-panel-backend || true
    fi
fi

echo ""
echo "✅ Перезапуск завершено"

ENDSSH

echo ""
echo "✅ Готово!"

