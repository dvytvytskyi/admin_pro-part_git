#!/bin/bash

# Скрипт для повного видалення проекту з сервера
# ВИКОРИСТАННЯ: ./deploy/delete-project-from-server.sh

set -e

SERVER_IP="135.181.201.185"
SERVER_USER="root"
SERVER_PASSWORD="FNrtVkfCRwgW"

echo "⚠️  УВАГА: Цей скрипт видалить ВСЕ файли проекту PRO-PART з сервера!"
echo "   Це включає:"
echo "   - Всі файли проекту pro-part"
echo "   - Docker контейнери pro-part"
echo "   - Docker volumes pro-part"
echo "   - Docker images pro-part"
echo "   - Nginx конфігурації pro-part"
echo ""
echo "   ⚠️  НЕ чіпаємо for-you проекти!"
echo ""
read -p "Ви впевнені? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "❌ Операцію скасовано"
    exit 1
fi

echo ""
echo "🗑️  Початок видалення проекту з сервера..."
echo ""

# Функція для виконання команд на сервері
ssh_exec() {
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no "$SERVER_USER@$SERVER_IP" "$1"
}

# Функція для копіювання файлів на сервер
scp_exec() {
    sshpass -p "$SERVER_PASSWORD" scp -o StrictHostKeyChecking=no "$1" "$SERVER_USER@$SERVER_IP:$2"
}

echo "1️⃣ Зупинка та видалення Docker контейнерів..."

# Зупинити та видалити контейнери ТІЛЬКИ pro-part
ssh_exec "cd /opt/admin-pro-part 2>/dev/null && docker-compose -f docker-compose.prod.yml down -v 2>/dev/null || true"

# Видалити контейнери pro-part вручну (якщо залишилися)
# Шукаємо тільки pro-part, НЕ for-you
ssh_exec "docker ps -a | grep -i 'pro-part' | awk '{print \$1}' | xargs -r docker rm -f 2>/dev/null || true"

echo "2️⃣ Видалення Docker volumes..."

# Видалити volumes ТІЛЬКИ pro-part
ssh_exec "docker volume ls | grep -i 'pro-part' | awk '{print \$2}' | xargs -r docker volume rm 2>/dev/null || true"

echo "3️⃣ Видалення Docker images..."

# Видалити images ТІЛЬКИ pro-part
ssh_exec "docker images | grep -i 'pro-part' | awk '{print \$3}' | xargs -r docker rmi -f 2>/dev/null || true"

echo "4️⃣ Видалення директорій проекту..."

# Видалити директорії проекту ТІЛЬКИ pro-part
ssh_exec "rm -rf /opt/admin-pro-part 2>/dev/null || true"

echo "5️⃣ Видалення Nginx конфігурацій..."

# Видалити Nginx конфігурації ТІЛЬКИ pro-part
ssh_exec "rm -f /etc/nginx/sites-enabled/*pro-part* 2>/dev/null || true"
ssh_exec "rm -f /etc/nginx/sites-available/*pro-part* 2>/dev/null || true"

# Перезавантажити Nginx
ssh_exec "nginx -t 2>/dev/null && systemctl reload nginx 2>/dev/null || true"

echo "6️⃣ Видалення логів..."

# Видалити логи ТІЛЬКИ pro-part
ssh_exec "rm -rf /var/log/*pro-part* 2>/dev/null || true"

echo "7️⃣ Очищення системних файлів..."

# Видалити systemd сервіси ТІЛЬКИ pro-part (якщо є)
ssh_exec "systemctl stop *pro-part* 2>/dev/null || true"
ssh_exec "systemctl disable *pro-part* 2>/dev/null || true"
ssh_exec "rm -f /etc/systemd/system/*pro-part* 2>/dev/null || true"
ssh_exec "systemctl daemon-reload 2>/dev/null || true"

echo ""
echo "✅ Видалення завершено!"
echo ""
echo "Перевірка:"
ssh_exec "ls -la /opt/ | grep -i 'pro-part' || echo '   ✅ Директорії pro-part видалені'"
ssh_exec "docker ps -a | grep -i 'pro-part' || echo '   ✅ Docker контейнери pro-part видалені'"
ssh_exec "docker volume ls | grep -i 'pro-part' || echo '   ✅ Docker volumes pro-part видалені'"
echo ""
echo "Перевірка, що for-you НЕ чіпали:"
ssh_exec "docker ps -a | grep -i 'for-you' && echo '   ✅ for-you контейнери на місці' || echo '   ℹ️  for-you контейнери не знайдені'"

echo ""
echo "🎉 Проект повністю видалено з сервера!"

