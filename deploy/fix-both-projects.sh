#!/bin/bash

# Скрипт для виправлення обох проектів (for-you та pro-part)
# ВИКОРИСТАННЯ: ./deploy/fix-both-projects.sh

set -e

SERVER_IP="135.181.201.185"
SERVER_USER="root"
SERVER_PASSWORD="FNrtVkfCRwgW"

echo "🔧 Діагностика та виправлення for-you та pro-part..."
echo ""

# Функція для виконання команд на сервері
ssh_exec() {
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no "$SERVER_USER@$SERVER_IP" "$1"
}

echo "=== FOR-YOU ПРОЕКТ ==="
echo ""

echo "1️⃣ Перевірка контейнерів for-you:"
ssh_exec "docker ps -a | grep -i 'for-you' || echo '   ⚠️  Контейнери не знайдені'"

echo ""
echo "2️⃣ Перезапуск контейнерів for-you:"
ssh_exec "docker ps -a | grep -i 'for-you' | awk '{print \$1}' | xargs -r docker restart 2>/dev/null || echo '   ⚠️  Не вдалося перезапустити'"

echo ""
echo "3️⃣ Перевірка статичних файлів for-you:"
ssh_exec "docker ps | grep -i 'for-you' | awk '{print \$1}' | head -1 | while read container; do docker exec \$container ls -la /app/public/images 2>/dev/null || docker exec \$container ls -la /app/static/images 2>/dev/null || echo '   ⚠️  Директорія images не знайдена'; done"

echo ""
echo "4️⃣ Перевірка Nginx конфігурації for-you:"
ssh_exec "cat /etc/nginx/sites-enabled/*for-you* 2>/dev/null | head -30 || echo '   ⚠️  Конфігурація не знайдена'"

echo ""
echo "=== PRO-PART ПРОЕКТ ==="
echo ""

echo "5️⃣ Перевірка контейнерів pro-part:"
ssh_exec "docker ps -a | grep -i 'pro-part' || echo '   ⚠️  Контейнери не знайдені (можливо видалені)'"

echo ""
echo "6️⃣ Перевірка Nginx конфігурації pro-part:"
ssh_exec "cat /etc/nginx/sites-enabled/*pro-part* 2>/dev/null | head -30 || echo '   ⚠️  Конфігурація не знайдена'"

echo ""
echo "7️⃣ Перевірка backend для pro-part:"
ssh_exec "curl -s http://localhost:4000/api/auth/login -X POST -H 'Content-Type: application/json' -d '{}' | head -c 200 || echo '   ⚠️  Backend не відповідає'"

echo ""
echo "=== ЗАГАЛЬНІ ДІЇ ==="
echo ""

echo "8️⃣ Перезавантаження Nginx:"
ssh_exec "nginx -t && systemctl reload nginx || echo '   ⚠️  Помилка Nginx'"

echo ""
echo "9️⃣ Перевірка логів:"
ssh_exec "tail -20 /var/log/nginx/error.log 2>/dev/null || echo '   Логи не знайдені'"

echo ""
echo "✅ Діагностика завершена!"





