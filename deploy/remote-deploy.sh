#!/bin/bash

# Скрипт для автоматичного деплою на сервер
# Використання через SSH

set -e

SERVER_IP="135.181.201.185"
SERVER_USER="root"
SERVER_PASSWORD="FNrtVkfCRwgW"
PROJECT_DIR="/opt/admin-panel"
REPO_URL="https://github.com/dvytvytskyi/for-you-admin.git"

echo "🚀 Початок автоматичного деплою..."

# Генеруємо безпечні паролі та ключі
DB_PASSWORD=$(openssl rand -base64 24 | tr -d "=+/" | cut -c1-24)
ADMIN_PASSWORD=$(openssl rand -base64 16 | tr -d "=+/" | cut -c1-16)
JWT_SECRET=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-32)

echo "📝 Згенеровані безпечні паролі:"
echo "   DB_PASSWORD: ${DB_PASSWORD}"
echo "   ADMIN_PASSWORD: ${ADMIN_PASSWORD}"
echo "   JWT_SECRET: ${JWT_SECRET:0:8}..."

# Створюємо скрипт для виконання на сервері
cat > /tmp/remote_deploy_script.sh << EOF
#!/bin/bash
set -e

echo "📦 Оновлення системи..."
apt update -qq

echo "📦 Встановлення базових пакетів..."
DEBIAN_FRONTEND=noninteractive apt install -y curl git docker.io docker-compose nginx certbot python3-certbot-nginx > /dev/null 2>&1

echo "🐳 Налаштування Docker..."
systemctl enable docker > /dev/null 2>&1
systemctl start docker > /dev/null 2>&1

echo "📁 Створення директорії проекту..."
mkdir -p ${PROJECT_DIR}
mkdir -p ${PROJECT_DIR}/backups
cd ${PROJECT_DIR}

echo "📥 Клонування репозиторію..."
if [ -d "${PROJECT_DIR}/.git" ]; then
    git pull origin main
else
    git clone ${REPO_URL} .
fi

echo "📝 Створення .env файлів..."

# Корінь проекту .env
cat > ${PROJECT_DIR}/.env << ENVEOF
DB_PASSWORD=${DB_PASSWORD}
ENVEOF

# Backend .env
cat > ${PROJECT_DIR}/admin-panel-backend/.env << ENVEOF
DATABASE_URL=postgresql://admin:${DB_PASSWORD}@admin-panel-db:5432/admin_panel
ADMIN_EMAIL=admin@foryou-realestate.com
ADMIN_PASSWORD=${ADMIN_PASSWORD}
ADMIN_JWT_SECRET=${JWT_SECRET}
NODE_ENV=production
PORT=4000
CLOUDINARY_CLOUD_NAME=dgv0rxd60
CLOUDINARY_API_KEY=GgziMAcVfQvOGD44Yj0OlNqitPg
CLOUDINARY_API_SECRET=your-cloudinary-api-secret
ENVEOF

# Frontend .env.production
cat > ${PROJECT_DIR}/admin-panel/.env.production << ENVEOF
NEXT_PUBLIC_API_URL=https://admin.foryou-realestate.com/api
ENVEOF

echo "🐳 Зупинка старих контейнерів..."
docker-compose -f ${PROJECT_DIR}/docker-compose.prod.yml down 2>/dev/null || true

echo "🔨 Будівництво образів..."
cd ${PROJECT_DIR}
docker-compose -f docker-compose.prod.yml build --no-cache

echo "🚀 Запуск контейнерів..."
docker-compose -f docker-compose.prod.yml up -d

echo "⏳ Очікування запуску сервісів..."
sleep 15

echo "🌐 Налаштування Nginx..."
cp ${PROJECT_DIR}/deploy/nginx.conf /etc/nginx/sites-available/admin.foryou-realestate.com
ln -sf /etc/nginx/sites-available/admin.foryou-realestate.com /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Тестування конфігурації
nginx -t

# Перезапуск Nginx
systemctl restart nginx
systemctl enable nginx

echo "🔒 Отримання SSL сертифікату..."
# Спробуємо отримати сертифікат, але якщо не вийде - продовжимо
certbot --nginx -d admin.foryou-realestate.com --non-interactive --agree-tos --email admin@foryou-realestate.com --redirect 2>/dev/null || {
    echo "⚠️  SSL сертифікат не встановлено. Можна встановити вручну пізніше."
}

systemctl restart nginx

echo "✅ Деплой завершено!"
echo ""
echo "📊 Статус контейнерів:"
docker-compose -f ${PROJECT_DIR}/docker-compose.prod.yml ps

echo ""
echo "🌐 Сайт доступний: https://admin.foryou-realestate.com"
echo "📧 Дані для входу:"
echo "   Email: admin@foryou-realestate.com"
echo "   Password: ${ADMIN_PASSWORD}"
EOF

chmod +x /tmp/remote_deploy_script.sh

echo "📤 Завантаження скрипту на сервер..."
# Використовуємо sshpass для автоматичного введення пароля
if command -v sshpass &> /dev/null; then
    sshpass -p "${SERVER_PASSWORD}" scp -o StrictHostKeyChecking=no /tmp/remote_deploy_script.sh ${SERVER_USER}@${SERVER_IP}:/tmp/remote_deploy_script.sh
    sshpass -p "${SERVER_PASSWORD}" ssh -o StrictHostKeyChecking=no ${SERVER_USER}@${SERVER_IP} 'bash /tmp/remote_deploy_script.sh'
else
    echo "⚠️  sshpass не встановлено. Встановлюємо..."
    # Спробуємо встановити sshpass
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install hudochenkov/sshpass/sshpass 2>/dev/null || echo "Встановіть sshpass вручну: brew install hudochenkov/sshpass/sshpass"
    else
        sudo apt-get install -y sshpass 2>/dev/null || echo "Встановіть sshpass вручну"
    fi
    
    if command -v sshpass &> /dev/null; then
        sshpass -p "${SERVER_PASSWORD}" scp -o StrictHostKeyChecking=no /tmp/remote_deploy_script.sh ${SERVER_USER}@${SERVER_IP}:/tmp/remote_deploy_script.sh
        sshpass -p "${SERVER_PASSWORD}" ssh -o StrictHostKeyChecking=no ${SERVER_USER}@${SERVER_IP} 'bash /tmp/remote_deploy_script.sh'
    else
        echo "❌ Не вдалося встановити sshpass. Виконайте вручну:"
        echo "   1. scp /tmp/remote_deploy_script.sh root@${SERVER_IP}:/tmp/"
        echo "   2. ssh root@${SERVER_IP}"
        echo "   3. bash /tmp/remote_deploy_script.sh"
    fi
fi

echo ""
echo "✅ Деплой завершено!"
echo "📧 Дані для входу в адмін панель:"
echo "   Email: admin@foryou-realestate.com"
echo "   Password: ${ADMIN_PASSWORD}"
echo ""
echo "🌐 Відкрийте в браузері: https://admin.foryou-realestate.com"

