# Деплой Admin Panel на admin.pro-part.online

## Інформація про сервер

- **IP адреса**: 88.99.38.25
- **Домен**: admin.pro-part.online
- **Користувач**: root
- **Пароль**: VandiPCEXeEP

## Передумови

1. Встановіть `sshpass` (для автоматичного введення пароля):
   ```bash
   # macOS
   brew install hudochenkov/sshpass/sshpass
   
   # Linux
   sudo apt-get install sshpass
   ```

2. Переконайтеся, що у вас є `.env` файли:
   - `admin_pro-part/.env` (основний)
   - `admin_pro-part/admin-panel-backend/.env` (для backend)

## Швидкий деплой

Запустіть скрипт деплою:

```bash
cd /Users/vytvytskyi/admin_pro-part
./deploy/deploy-pro-part.sh
```

## Ручний деплой

Якщо автоматичний скрипт не працює, виконайте кроки вручну:

### 1. Підключення до сервера

```bash
ssh root@88.99.38.25
# Пароль: VandiPCEXeEP
```

### 2. Встановлення необхідних пакетів

```bash
apt update
apt install -y curl git docker.io docker-compose nginx certbot python3-certbot-nginx
systemctl enable docker
systemctl start docker
```

### 3. Створення директорії проекту

```bash
mkdir -p /opt/admin-pro-part
mkdir -p /opt/admin-pro-part/admin-panel-backend/uploads
cd /opt/admin-pro-part
```

### 4. Копіювання файлів

З локальної машини:

```bash
# З вашого локального комп'ютера
cd /Users/vytvytskyi/admin_pro-part

# Копіювання файлів через scp
scp docker-compose.prod.yml root@88.99.38.25:/opt/admin-pro-part/
scp -r admin-panel root@88.99.38.25:/opt/admin-pro-part/
scp -r admin-panel-backend root@88.99.38.25:/opt/admin-pro-part/
scp deploy/nginx-pro-part.conf root@88.99.38.25:/opt/admin-pro-part/
```

### 5. Створення .env файлів на сервері

```bash
# На сервері
cd /opt/admin-pro-part
nano .env
nano admin-panel-backend/.env
```

### 6. Запуск Docker контейнерів

```bash
cd /opt/admin-pro-part
docker-compose -f docker-compose.prod.yml down
docker-compose -f docker-compose.prod.yml build --no-cache
docker-compose -f docker-compose.prod.yml up -d
```

### 7. Налаштування Nginx

```bash
cp /opt/admin-pro-part/nginx-pro-part.conf /etc/nginx/sites-available/admin.pro-part.online
ln -sf /etc/nginx/sites-available/admin.pro-part.online /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
nginx -t
systemctl restart nginx
systemctl enable nginx
```

### 8. Отримання SSL сертифікату

```bash
certbot --nginx -d admin.pro-part.online --non-interactive --agree-tos --email admin@pro-part.online
systemctl reload nginx
```

### 9. Перевірка статусу

```bash
cd /opt/admin-pro-part
docker-compose -f docker-compose.prod.yml ps
docker-compose -f docker-compose.prod.yml logs -f
```

## Перевірка роботи

1. Відкрийте в браузері: https://admin.pro-part.online
2. Перевірте API: https://admin.pro-part.online/api
3. Перевірте логи:
   ```bash
   ssh root@88.99.38.25
   cd /opt/admin-pro-part
   docker-compose -f docker-compose.prod.yml logs -f
   ```

## Оновлення після змін

```bash
# З локальної машини
cd /Users/vytvytskyi/admin_pro-part
./deploy/deploy-pro-part.sh
```

Або вручну:

```bash
# На сервері
cd /opt/admin-pro-part
docker-compose -f docker-compose.prod.yml down
# Оновіть файли
docker-compose -f docker-compose.prod.yml build --no-cache
docker-compose -f docker-compose.prod.yml up -d
```

## Розв'язання проблем

### Проблеми з підключенням

```bash
# Перевірте підключення
ping 88.99.38.25
ssh root@88.99.38.25
```

### Проблеми з Docker

```bash
# Перевірте статус Docker
systemctl status docker
docker ps -a
```

### Проблеми з Nginx

```bash
# Перевірте конфігурацію
nginx -t
# Перевірте логи
tail -f /var/log/nginx/admin-pro-part-error.log
```

### Проблеми з SSL

```bash
# Перевірте сертифікат
certbot certificates
# Оновіть сертифікат
certbot renew
```

## Структура проекту на сервері

```
/opt/admin-pro-part/
├── docker-compose.prod.yml
├── .env
├── admin-panel/
│   └── .env.production
├── admin-panel-backend/
│   ├── .env
│   └── uploads/
└── nginx-pro-part.conf
```

## Порты

- Frontend: 3001 (внутрішній, через nginx)
- Backend: 4000 (внутрішній, через nginx)
- Database: 5435 (тільки localhost)
- Nginx: 80, 443 (публічні)

