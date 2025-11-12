#!/bin/bash

# Тест production середовища

echo "🧪 Тестування production середовища..."
echo ""

echo "1️⃣ Перевірка Docker контейнерів:"
docker-compose -f docker-compose.prod.yml ps
echo ""

echo "2️⃣ Перевірка backend health:"
curl -s http://localhost:4001/health | jq . || curl -s http://localhost:4001/health
echo ""

echo "3️⃣ Перевірка frontend:"
curl -I http://localhost:3002 2>&1 | head -5
echo ""

echo "4️⃣ Перевірка через Nginx:"
curl -I http://system.pro-part.online 2>&1 | head -5
echo ""

echo "5️⃣ Перевірка API через Nginx:"
curl -I http://system.pro-part.online/api/health 2>&1 | head -5
echo ""

echo "✅ Тестування завершено"
echo ""
echo "🌐 Відкрийте в браузері: http://system.pro-part.online"

