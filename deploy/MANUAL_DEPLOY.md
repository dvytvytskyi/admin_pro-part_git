# Ручні інструкції для деплою

## Підключення до сервера

```bash
ssh root@135.181.201.185
# Пароль: FNrtVkfCRwgW
```

## Крок 1: Оновлення системи та встановлення залежностей

```bash
apt update && apt upgrade -y
apt install -y curl git docker.io docker-compose nginx certbot python3-certbot-nginx

systemctl enable docker
systemctl start docker
```

## Крок 2: Клонування/оновлення проекту

```bash
mkdir -p /opt/admin-panel
cd /opt/admin-panel

# Якщо проект ще не клонований
git clone https://github.com/dvytvytskyi/for-you-admin.git .

# Якщо проект вже є - оновлюємо
git pull origin main
```

## Крок 3: Створення .env файлів

### Корінь проекту (.env)
```bash
nano /opt/admin-panel/.env
```

```env
DB_PASSWORD=ВАШ_БЕЗПЕЧНИЙ_ПАРОЛЬ_БД
```

### Backend (.env)
```bash
nano /opt/admin-panel/admin-panel-backend/.env
```

```env
DATABASE_URL=postgresql://admin:ВАШ_ПАРОЛЬ_БД@admin-panel-db:5432/admin_panel
ADMIN_EMAIL=admin@foryou-realestate.com
ADMIN_PASSWORD=ВАШ_БЕЗПЕЧНИЙ_ПАРОЛЬ
ADMIN_JWT_SECRET=$(openssl rand -base64 32)
NODE_ENV=production
PORT=4000
CLOUDINARY_CLOUD_NAME=dgv0rxd60
CLOUDINARY_API_KEY=GgziMAcVfQvOGD44Yj0OlNqitPg
CLOUDINARY_API_SECRET=ваш-cloudinary-secret
```

### Frontend (.env.production)
```bash
nano /opt/admin-panel/admin-panel/.env.production
```

```env
NEXT_PUBLIC_API_URL=https://admin.foryou-realestate.com/api
```

## Крок 4: Будівництво та запуск

```bash
cd /opt/admin-panel

# Зупинити старі контейнери (якщо є)
docker-compose -f docker-compose.prod.yml down

# Побудувати образи
docker-compose -f docker-compose.prod.yml build --no-cache

# Запустити контейнери
docker-compose -f docker-compose.prod.yml up -d

# Перевірити статус
docker-compose -f docker-compose.prod.yml ps
```

## Крок 5: Налаштування Nginx

```bash
# Копіювати конфігурацію
cp /opt/admin-panel/deploy/nginx.conf /etc/nginx/sites-available/admin.foryou-realestate.com

# Створити симлінк
ln -sf /etc/nginx/sites-available/admin.foryou-realestate.com /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Перевірити конфігурацію
nginx -t

# Перезапустити Nginx
systemctl restart nginx
systemctl enable nginx
```

## Крок 6: SSL сертифікат (Let's Encrypt)

```bash
certbot --nginx -d admin.foryou-realestate.com --non-interactive --agree-tos --email admin@foryou-realestate.com --redirect
```

## Перевірка

```bash
# Статус контейнерів
docker-compose -f /opt/admin-panel/docker-compose.prod.yml ps

# Логи
docker-compose -f /opt/admin-panel/docker-compose.prod.yml logs -f
```

## Якщо щось пішло не так

```bash
# Переглянути логи
docker-compose -f /opt/admin-panel/docker-compose.prod.yml logs backend
docker-compose -f /opt/admin-panel/docker-compose.prod.yml logs frontend

# Перезапустити
docker-compose -f /opt/admin-panel/docker-compose.prod.yml restart
```

