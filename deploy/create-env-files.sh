#!/bin/bash

# Генеруємо пароль для БД
DB_PASSWORD=$(openssl rand -base64 16 | tr -d '=+/' | head -c 20)

# Конфігурація
SERVER_IP="88.99.38.25"
SERVER_USER="root"
SERVER_PASSWORD="VandiPCEXeep"
PROJECT_DIR="/opt/admin-pro-part"

# Функція для виконання команд на сервері
ssh_exec() {
    sshpass -p "${SERVER_PASSWORD}" ssh -o StrictHostKeyChecking=no ${SERVER_USER}@${SERVER_IP} "$1"
}

# Функція для створення файлу на сервері
create_remote_file() {
    local filepath="$1"
    local content="$2"
    ssh_exec "cat > ${filepath} << 'ENVEOF'
${content}
ENVEOF
"
}

echo "🔐 Створення .env файлів на сервері..."

# Основний .env файл
MAIN_ENV="DATABASE_URL=postgresql://admin:${DB_PASSWORD}@admin-panel-db:5432/admin_panel
ADMIN_JWT_SECRET=KlhjEGxmB735mZhCRZ9JhmtVEoLQylLf89FrOl6zojM=
ADMIN_EMAIL=admin@pro-part.online
ADMIN_PASSWORD=iMwBwWMkjXAYOuGO7kr9EQ==
CLOUDINARY_CLOUD_NAME=dgv0rxd60
CLOUDINARY_API_KEY=141613625537469
CLOUDINARY_API_SECRET=GgziMAcVfQvOGD44Yj0OlNqitPg
NODE_ENV=production
PORT=4000
DB_PASSWORD=${DB_PASSWORD}"

# Backend .env файл (такий самий)
BACKEND_ENV="${MAIN_ENV}"

# Створюємо файли
echo "  → Створення ${PROJECT_DIR}/.env"
create_remote_file "${PROJECT_DIR}/.env" "${MAIN_ENV}"

echo "  → Створення ${PROJECT_DIR}/admin-panel-backend/.env"
ssh_exec "mkdir -p ${PROJECT_DIR}/admin-panel-backend"
create_remote_file "${PROJECT_DIR}/admin-panel-backend/.env" "${BACKEND_ENV}"

echo "✅ .env файли створено!"
echo ""
echo "📋 Згенеровані значення:"
echo "  DB_PASSWORD: ${DB_PASSWORD}"
echo "  ADMIN_JWT_SECRET: KlhjEGxmB735mZhCRZ9JhmtVEoLQylLf89FrOl6zojM="
echo "  ADMIN_PASSWORD: iMwBwWMkjXAYOuGO7kr9EQ=="

