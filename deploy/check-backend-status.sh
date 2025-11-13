#!/bin/bash

# Скрипт для перевірки статусу бекенду на сервері

set -e

SERVER_IP="135.181.201.185"
SERVER_USER="root"
DOMAIN="system.pro-part.online"

echo "🔍 Перевірка статусу бекенду на сервері..."
echo ""

read -sp "Введіть пароль для root@${SERVER_IP}: " SERVER_PASSWORD
echo ""

sshpass -p "${SERVER_PASSWORD}" ssh -o StrictHostKeyChecking=no ${SERVER_USER}@${SERVER_IP} << 'ENDSSH'
set -e

echo "🐳 Перевірка Docker контейнерів:"
echo ""
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "backend|admin-pro-part|NAMES" || echo "   ⚠️  Контейнери не знайдено"
echo ""

echo "🔍 Перевірка бекенду на порту 4001:"
echo ""
if curl -s http://localhost:4001/health > /dev/null 2>&1; then
    echo "   ✅ Бекенд відповідає на порту 4001"
    curl -s http://localhost:4001/health | head -5
else
    echo "   ❌ Бекенд НЕ відповідає на порту 4001"
fi
echo ""

echo "🔍 Перевірка nginx конфігурації для /api:"
echo ""
if [ -f "/etc/nginx/sites-available/system.pro-part.online" ]; then
    echo "   Конфігурація /api:"
    grep -A 10 "location /api" /etc/nginx/sites-available/system.pro-part.online || echo "   ⚠️  location /api не знайдено"
else
    echo "   ❌ Конфігурація nginx не знайдена"
fi
echo ""

echo "🔍 Перевірка процесів Node.js:"
echo ""
ps aux | grep -E "node|npm|ts-node" | grep -v grep || echo "   ⚠️  Node.js процеси не знайдено"
echo ""

echo "📋 Перевірка docker-compose:"
echo ""
if [ -d "/opt/admin-pro-part" ]; then
    cd /opt/admin-pro-part
    if [ -f "docker-compose.prod.yml" ] || [ -f "docker-compose.yml" ]; then
        echo "   ✅ docker-compose файл знайдено"
        docker-compose ps 2>/dev/null || echo "   ⚠️  Не вдалося перевірити статус"
    else
        echo "   ⚠️  docker-compose файл не знайдено"
    fi
else
    echo "   ⚠️  Директорія /opt/admin-pro-part не знайдена"
fi
echo ""

echo "✅ Перевірка завершена"

ENDSSH

echo ""
echo "✅ Готово!"

