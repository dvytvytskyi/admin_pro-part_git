#!/bin/bash

# Скрипт для перевірки розташування for-you проекту на сервері

SERVER_IP="135.181.201.185"
SERVER_USER="root"
SERVER_PASSWORD="FNrtVkfCRwgW"

echo "🔍 Пошук for-you проекту на сервері..."
echo ""

# Функція для виконання команд на сервері
ssh_exec() {
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no "$SERVER_USER@$SERVER_IP" "$1"
}

echo "1️⃣ Перевірка Docker контейнерів for-you:"
ssh_exec "docker ps -a | grep -i 'for-you' || echo '   Контейнери не знайдені'"

echo ""
echo "2️⃣ Перевірка директорій в /opt/:"
ssh_exec "ls -la /opt/ | grep -i 'for-you\|admin' || echo '   Директорії не знайдені'"

echo ""
echo "3️⃣ Перевірка директорій в /home/:"
ssh_exec "ls -la /home/ | grep -i 'for-you\|admin' || echo '   Директорії не знайдені'"

echo ""
echo "4️⃣ Перевірка директорій в /var/www/:"
ssh_exec "ls -la /var/www/ 2>/dev/null | grep -i 'for-you\|admin' || echo '   Директорії не знайдені'"

echo ""
echo "5️⃣ Перевірка Docker volumes for-you:"
ssh_exec "docker volume ls | grep -i 'for-you' || echo '   Volumes не знайдені'"

echo ""
echo "6️⃣ Перевірка Nginx конфігурацій for-you:"
ssh_exec "ls -la /etc/nginx/sites-enabled/ 2>/dev/null | grep -i 'for-you' || echo '   Конфігурації не знайдені'"
ssh_exec "ls -la /etc/nginx/sites-available/ 2>/dev/null | grep -i 'for-you' || echo '   Конфігурації не знайдені'"

echo ""
echo "7️⃣ Перевірка systemd сервісів for-you:"
ssh_exec "systemctl list-units --all | grep -i 'for-you' || echo '   Сервіси не знайдені'"

echo ""
echo "✅ Перевірка завершена!"

