# Деплой admin_pro-part на app.pro-part.online

## Серверні дані
- **IP**: 135.181.201.185
- **Домен**: app.pro-part.online
- **Root Password**: FNrtVkfCRwgW
- **Проект**: admin_pro-part
- **Репозиторій**: https://github.com/dvytvytskyi/admin_pro-part_git.git

---

## Швидкий деплой (автоматичний)

### Варіант 1: Через скрипт (рекомендовано)

```bash
cd /Users/vytvytskyi/admin_pro-part
./deploy/deploy-pro-part.sh
```

Скрипт автоматично:
- Підключиться до сервера
- Клонує/оновить репозиторій
- Створить .env файли
- Налаштує Docker Compose
- Налаштує Nginx
- Отримає SSL сертифікат
- Запустить контейнери

---

## Ручний деплой

### Крок 1: Підключення до сервера

```bash
ssh root@135.181.201.185
# Пароль: FNrtVkfCRwgW
```

### Крок 2: Клонування/оновлення проекту

```bash
mkdir -p /opt/admin-pro-part
cd /opt/admin-pro-part

# Якщо проект ще не клонований
git clone https://github.com/dvytvytskyi/admin_pro-part_git.git .

# Якщо проект вже є - оновлюємо
git pull origin main
```

### Крок 3: Створення .env файлів

#### Корінь проекту (.env)

```bash
nano /opt/admin-pro-part/.env
```

```env
DB_PASSWORD=ВАШ_БЕЗПЕЧНИЙ_ПАРОЛЬ_БД
```

#### Backend (.env)

```bash
nano /opt/admin-pro-part/admin-panel-backend/.env
```

```env
DATABASE_URL=postgresql://admin:ВАШ_ПАРОЛЬ_БД@admin-pro-part-db:5432/admin_panel_propart
ADMIN_EMAIL=admin@pro-part.online
ADMIN_PASSWORD=ВАШ_БЕЗПЕЧНИЙ_ПАРОЛЬ
ADMIN_JWT_SECRET=$(openssl rand -base64 32)
NODE_ENV=production
PORT=4000
CLOUDINARY_CLOUD_NAME=dgv0rxd60
CLOUDINARY_API_KEY=141613625537469
CLOUDINARY_API_SECRET=GgziMAcVfQvOGD44Yj0OlNqitPg
```

#### Frontend (.env.production)

```bash
nano /opt/admin-pro-part/admin-panel/.env.production
```

```env
NEXT_PUBLIC_API_URL=https://app.pro-part.online/api
```

### Крок 4: Створення docker-compose.prod.yml

```bash
cd /opt/admin-pro-part
nano docker-compose.prod.yml
```

```yaml
version: '3.8'

services:
  admin-pro-part-db:
    image: postgres:15-alpine
    container_name: admin-pro-part-db
    restart: unless-stopped
    environment:
      POSTGRES_USER: admin
      POSTGRES_PASSWORD: ${DB_PASSWORD}
      POSTGRES_DB: admin_panel_propart
    volumes:
      - admin-pro-part-db-data:/var/lib/postgresql/data
    networks:
      - admin-pro-part-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U admin"]
      interval: 10s
      timeout: 5s
      retries: 5

  admin-pro-part-backend:
    build:
      context: ./admin-panel-backend
      dockerfile: Dockerfile
    container_name: admin-pro-part-backend
    restart: unless-stopped
    env_file:
      - ./admin-panel-backend/.env
    ports:
      - "4001:4000"
    depends_on:
      admin-pro-part-db:
        condition: service_healthy
    networks:
      - admin-pro-part-network

  admin-pro-part-frontend:
    build:
      context: ./admin-panel
      dockerfile: Dockerfile
    container_name: admin-pro-part-frontend
    restart: unless-stopped
    env_file:
      - ./admin-panel/.env.production
    ports:
      - "3002:3000"
    depends_on:
      - admin-pro-part-backend
    networks:
      - admin-pro-part-network

networks:
  admin-pro-part-network:
    driver: bridge

volumes:
  admin-pro-part-db-data:
```

### Крок 5: Налаштування Nginx

```bash
nano /etc/nginx/sites-available/app.pro-part.online
```

```nginx
server {
    listen 80;
    server_name app.pro-part.online;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name app.pro-part.online;

    ssl_certificate /etc/letsencrypt/live/app.pro-part.online/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/app.pro-part.online/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    # Frontend
    location / {
        proxy_pass http://localhost:3002;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }

    # Backend API
    location /api {
        proxy_pass http://localhost:4001;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

Активуйте конфігурацію:

```bash
ln -s /etc/nginx/sites-available/app.pro-part.online /etc/nginx/sites-enabled/
nginx -t
systemctl reload nginx
```

### Крок 6: SSL сертифікат

```bash
certbot --nginx -d app.pro-part.online --non-interactive --agree-tos --email admin@pro-part.online
```

### Крок 7: Запуск контейнерів

```bash
cd /opt/admin-pro-part

# Будівництво образів
docker-compose -f docker-compose.prod.yml build --no-cache

# Запуск контейнерів
docker-compose -f docker-compose.prod.yml up -d

# Перевірка статусу
docker-compose -f docker-compose.prod.yml ps
```

### Крок 8: Міграції та seed

```bash
# Міграції
docker exec admin-pro-part-backend npm run migration:run

# Seed (базові дані)
docker exec admin-pro-part-backend npm run seed

# Імпорт даних (якщо потрібно)
docker exec admin-pro-part-backend npm run import:all
docker exec admin-pro-part-backend npm run import:districts
```

---

## Важливі порти

- **Frontend**: 3002 (внутрішній, доступ через Nginx)
- **Backend**: 4001 (внутрішній, доступ через Nginx)
- **Database**: 5432 (тільки в Docker network)
- **HTTP/HTTPS**: 80/443 (публічні, Nginx)

**Примітка**: Порты 3002 та 4001 використовуються, щоб не конфліктувати з for-you проектом (3001 та 4000).

---

## Команди для управління

### Перезапуск
```bash
cd /opt/admin-pro-part
docker-compose -f docker-compose.prod.yml restart
```

### Логи
```bash
docker-compose -f docker-compose.prod.yml logs -f
docker logs admin-pro-part-backend -f
docker logs admin-pro-part-frontend -f
```

### Оновлення
```bash
cd /opt/admin-pro-part
git pull origin main
docker-compose -f docker-compose.prod.yml build
docker-compose -f docker-compose.prod.yml up -d
```

### Backup БД
```bash
docker exec admin-pro-part-db pg_dump -U admin admin_panel_propart > /opt/admin-pro-part/backups/backup_$(date +%Y%m%d).sql
```

---

## DNS налаштування

Переконайтеся, що DNS для `app.pro-part.online` вказує на `135.181.201.185`:

```
A запис: app.pro-part.online -> 135.181.201.185
```

---

## Перевірка після деплою

1. ✅ Перевірте доступність: https://app.pro-part.online
2. ✅ Перевірте API: https://app.pro-part.online/api/health
3. ✅ Перевірте логін: https://app.pro-part.online/login
4. ✅ Перевірте логи: `docker-compose -f docker-compose.prod.yml logs`

---

## Troubleshooting

### Контейнери не запускаються
```bash
docker-compose -f docker-compose.prod.yml logs
docker ps -a
```

### Nginx помилки
```bash
nginx -t
tail -50 /var/log/nginx/error.log
```

### Проблеми з БД
```bash
docker exec -it admin-pro-part-db psql -U admin -d admin_panel_propart
```

### Проблеми з SSL
```bash
certbot certificates
certbot renew --dry-run
```

