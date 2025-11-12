#!/bin/bash

# Скрипт для діагностики та виправлення for-you проекту
# ВИКОРИСТАННЯ: ./deploy/fix-for-you.sh

set -e

SERVER_IP="135.181.201.185"
SERVER_USER="root"
SERVER_PASSWORD="FNrtVkfCRwgW"

echo "🔧 Діагностика та виправлення for-you проекту..."
echo ""

# Функція для виконання команд на сервері
ssh_exec() {
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no "$SERVER_USER@$SERVER_IP" "$1"
}

echo "1️⃣ Перевірка Docker контейнерів for-you:"
ssh_exec "docker ps -a | grep -i 'for-you' || echo '   ❌ Контейнери не знайдені'"

echo ""
echo "2️⃣ Перевірка стану контейнерів:"
ssh_exec "docker ps | grep -i 'for-you' || echo '   ⚠️  Контейнери не запущені'"

echo ""
echo "3️⃣ Перевірка Nginx конфігурації:"
ssh_exec "nginx -t 2>&1"

echo ""
echo "4️⃣ Перевірка Nginx конфігурацій for-you:"
ssh_exec "ls -la /etc/nginx/sites-enabled/ | grep -i 'for-you' || echo '   ⚠️  Конфігурації не знайдені'"
ssh_exec "ls -la /etc/nginx/sites-available/ | grep -i 'for-you' || echo '   ⚠️  Конфігурації не знайдені'"

echo ""
echo "5️⃣ Перевірка логів Nginx:"
ssh_exec "tail -20 /var/log/nginx/error.log 2>/dev/null || echo '   Логи не знайдені'"

echo ""
echo "6️⃣ Спроба перезапуску контейнерів for-you:"
ssh_exec "docker ps -a | grep -i 'for-you' | awk '{print \$1}' | while read container; do echo \"Перезапуск контейнера: \$container\"; docker restart \$container 2>/dev/null || true; done"

echo ""
echo "7️⃣ Перевірка після перезапуску:"
sleep 3
ssh_exec "docker ps | grep -i 'for-you' || echo '   ⚠️  Контейнери все ще не запущені'"

echo ""
echo "8️⃣ Перезавантаження Nginx:"
ssh_exec "systemctl reload nginx 2>/dev/null || systemctl restart nginx 2>/dev/null || true"

echo ""
echo "9️⃣ Перевірка логів контейнерів for-you:"
ssh_exec "docker ps -a | grep -i 'for-you' | awk '{print \$1}' | head -1 | while read container; do echo \"Логи контейнера \$container:\"; docker logs --tail=20 \$container 2>&1; done"

echo ""
echo "✅ Діагностика завершена!"

