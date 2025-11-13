#!/bin/bash

# Скрипт для виправлення помилки 502 Bad Gateway

set -e

SERVER_IP="135.181.201.185"
SERVER_USER="root"
DOMAIN="system.pro-part.online"

echo "🔧 Виправлення помилки 502 Bad Gateway..."
echo ""

read -sp "Введіть пароль для root@${SERVER_IP}: " SERVER_PASSWORD
echo ""

sshpass -p "${SERVER_PASSWORD}" ssh -o StrictHostKeyChecking=no ${SERVER_USER}@${SERVER_IP} << 'ENDSSH'
set -e

DOMAIN="system.pro-part.online"

echo "🔍 Перевірка поточного стану..."

# 1. Перевіряємо чи бекенд відповідає
echo ""
echo "1️⃣ Перевірка бекенду:"
if curl -s http://localhost:4001/health > /dev/null 2>&1; then
    echo "   ✅ Бекенд працює на localhost:4001"
    curl -s http://localhost:4001/health
else
    echo "   ❌ Бекенд НЕ відповідає на localhost:4001"
    exit 1
fi
echo ""

# 2. Перевіряємо nginx конфігурацію
echo "2️⃣ Перевірка nginx конфігурації:"
if [ -f "/etc/nginx/sites-available/${DOMAIN}" ]; then
    echo "   ✅ Конфігурація існує"
    
    # Перевіряємо чи правильно налаштований proxy_pass
    if grep -q "proxy_pass http://localhost:4001" "/etc/nginx/sites-available/${DOMAIN}"; then
        echo "   ✅ proxy_pass налаштовано правильно"
    else
        echo "   ⚠️  proxy_pass може бути неправильно налаштований"
    fi
else
    echo "   ❌ Конфігурація не знайдена"
    exit 1
fi
echo ""

# 3. Тестуємо nginx конфігурацію
echo "3️⃣ Тестування nginx конфігурації:"
if nginx -t 2>&1; then
    echo "   ✅ Конфігурація валідна"
else
    echo "   ❌ Помилка в конфігурації!"
    nginx -t 2>&1
    exit 1
fi
echo ""

# 4. Перезавантажуємо nginx
echo "4️⃣ Перезавантаження nginx:"
systemctl reload nginx
echo "   ✅ Nginx перезавантажено"
echo ""

# 5. Перевіряємо чи nginx може досягти бекенду
echo "5️⃣ Тестування з'єднання через nginx:"
sleep 2
if curl -s http://localhost/api/health > /dev/null 2>&1; then
    echo "   ✅ Nginx може досягти бекенду"
    curl -s http://localhost/api/health
else
    echo "   ⚠️  Nginx не може досягти бекенду через /api/health"
    echo "   💡 Перевірте логи nginx: tail -f /var/log/nginx/error.log"
fi
echo ""

# 6. Перевіряємо логи nginx на помилки
echo "6️⃣ Останні помилки nginx:"
tail -20 /var/log/nginx/error.log 2>/dev/null | grep -E "502|Bad Gateway|upstream" || echo "   ✅ Помилок не знайдено"
echo ""

# 7. Перевіряємо доступність через зовнішній URL
echo "7️⃣ Тестування через зовнішній URL:"
if curl -s -k https://${DOMAIN}/api/health > /dev/null 2>&1; then
    echo "   ✅ API доступний через HTTPS"
    curl -s -k https://${DOMAIN}/api/health | head -3
else
    echo "   ⚠️  API не доступний через HTTPS (можливо потрібен SSL)"
    if curl -s http://${DOMAIN}/api/health > /dev/null 2>&1; then
        echo "   ✅ API доступний через HTTP"
        curl -s http://${DOMAIN}/api/health | head -3
    else
        echo "   ❌ API не доступний"
    fi
fi
echo ""

echo "✅ Перевірка завершена"

ENDSSH

echo ""
echo "✅ Готово!"

