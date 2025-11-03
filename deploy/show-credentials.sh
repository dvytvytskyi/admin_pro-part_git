#!/bin/bash

PROJECT_DIR="/opt/admin-panel"

echo "🔐 Дані для входу в адмін панель:"
echo ""

if [ -f "$PROJECT_DIR/admin-panel-backend/.env" ]; then
    echo "📧 Email:"
    grep "ADMIN_EMAIL" $PROJECT_DIR/admin-panel-backend/.env | cut -d '=' -f2
    echo ""
    echo "🔑 Password:"
    grep "ADMIN_PASSWORD" $PROJECT_DIR/admin-panel-backend/.env | cut -d '=' -f2
    echo ""
    echo "🌐 URL: https://admin.foryou-realestate.com"
else
    echo "❌ Не знайдено .env файл в $PROJECT_DIR/admin-panel-backend/.env"
    echo ""
    echo "Перевірте вручну:"
    echo "   cat $PROJECT_DIR/admin-panel-backend/.env | grep ADMIN"
fi

