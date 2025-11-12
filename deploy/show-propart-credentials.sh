#!/bin/bash

# Показати credentials для admin_pro-part

PROJECT_DIR="/opt/admin-pro-part"

if [ ! -f "${PROJECT_DIR}/admin-panel-backend/.env" ]; then
    echo "❌ .env файл не знайдено в ${PROJECT_DIR}/admin-panel-backend/.env"
    echo ""
    echo "Створіть .env файл або запустіть deploy скрипт"
    exit 1
fi

echo "🔑 Дані для входу в admin_pro-part:"
echo ""
echo "Email: $(grep ADMIN_EMAIL ${PROJECT_DIR}/admin-panel-backend/.env | cut -d '=' -f2)"
echo "Password: $(grep ADMIN_PASSWORD ${PROJECT_DIR}/admin-panel-backend/.env | cut -d '=' -f2)"
echo ""
echo "🌐 URL: http://system.pro-part.online"

