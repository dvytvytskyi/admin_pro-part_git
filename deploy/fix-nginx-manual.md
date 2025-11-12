# Виправлення Nginx для system.pro-part.online (вручну)

## Підключіться до сервера:

```bash
ssh root@135.181.201.185
# Пароль: FNrtVkfCRwgW
```

## Виконайте ці команди на сервері:

### 1. Видаліть старі конфігурації:

```bash
rm -f /etc/nginx/sites-available/system.pro-part.online
rm -f /etc/nginx/sites-enabled/system.pro-part.online
```

### 2. Створіть нову правильну конфігурацію:

```bash
cat > /etc/nginx/sites-available/system.pro-part.online << 'EOF'
server {
    listen 80;
    server_name system.pro-part.online;

    location / {
        proxy_pass http://localhost:3002;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /api {
        proxy_pass http://localhost:4001;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF
```

### 3. Активуйте конфігурацію:

```bash
ln -s /etc/nginx/sites-available/system.pro-part.online /etc/nginx/sites-enabled/
```

### 4. Перевірте конфігурацію:

```bash
nginx -t
```

Якщо все ОК, ви побачите:
```
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

### 5. Перезавантажте Nginx:

```bash
systemctl reload nginx
```

### 6. Перевірте статус:

```bash
systemctl status nginx
```

### 7. Перевірте чи працюють контейнери:

```bash
docker ps | grep admin-pro-part
```

Якщо контейнери не запущені:
```bash
cd /opt/admin-pro-part
docker-compose -f docker-compose.prod.yml up -d
```

## Після виконання:

Перевірте: http://system.pro-part.online

Якщо все працює, потім можна додати SSL:
```bash
certbot --nginx -d system.pro-part.online --non-interactive --agree-tos --email admin@pro-part.online
```

