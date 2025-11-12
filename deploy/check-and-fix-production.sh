#!/bin/bash

# Скрипт для перевірки та виправлення production

SERVER_IP="135.181.201.185"
SERVER_USER="root"

echo "🔍 Перевірка production..."
echo ""

read -sp "Введіть пароль для root@${SERVER_IP}: " SERVER_PASSWORD
echo ""

sshpass -p "${SERVER_PASSWORD}" ssh -o StrictHostKeyChecking=no ${SERVER_USER}@${SERVER_IP} << 'ENDSSH'
cd /opt/admin-pro-part

echo "🐳 Статус контейнерів:"
docker-compose -f docker-compose.prod.yml ps
echo ""

echo "📋 Логи backend (останні 20 рядків):"
docker logs admin-pro-part-backend --tail=20
echo ""

echo "📋 Логи frontend (останні 20 рядків):"
docker logs admin-pro-part-frontend --tail=20
echo ""

echo "🔍 Перевірка підключення до БД:"
docker exec admin-pro-part-backend node -e "
const { AppDataSource } = require('./dist/config/database');
AppDataSource.initialize()
  .then(() => {
    console.log('✅ БД підключена');
    return AppDataSource.query('SELECT COUNT(*) as count FROM properties');
  })
  .then((result) => {
    console.log('📊 Properties:', result[0].count);
    process.exit(0);
  })
  .catch((err) => {
    console.error('❌ Помилка:', err.message);
    process.exit(1);
  });
" || echo "⚠️  Не вдалося перевірити БД"
echo ""

echo "🌐 Перевірка доступності:"
curl -s http://localhost:3002 | head -5 || echo "   Frontend не відповідає"
curl -s http://localhost:4001/api/health || echo "   Backend не відповідає"
echo ""

ENDSSH

echo ""
echo "✅ Перевірка завершена!"

