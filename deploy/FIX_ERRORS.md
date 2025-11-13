# Виправлення помилок for-you та pro-part

## Виявлені проблеми

### 1. FOR-YOU: 404 помилки
- `GET /images/shape/grid-01.svg 404`
- `GET /reset-password 404`

**Причини:**
- Відсутні статичні файли
- Неправильна конфігурація Nginx для статичних файлів
- Контейнери не запущені або не працюють правильно

### 2. PRO-PART: 401 Unauthorized при логіні
- `POST /api/auth/login 401`

**Причини:**
- Backend не працює
- Неправильні credentials
- Проблеми з JWT токенами
- Backend контейнер не запущений

## Швидке виправлення

### Варіант 1: Автоматичний скрипт
```bash
cd /Users/vytvytskyi/admin_pro-part
./deploy/fix-both-projects.sh
```

### Варіант 2: Вручну на сервері

```bash
ssh root@135.181.201.185
# Пароль: FNrtVkfCRwgW
```

#### Виправлення FOR-YOU (404 помилки):

```bash
# 1. Перезапустити контейнери for-you
docker ps -a | grep -i 'for-you' | awk '{print $1}' | xargs -r docker restart

# 2. Перевірити, чи працюють
docker ps | grep -i 'for-you'

# 3. Перевірити статичні файли в контейнері
docker ps | grep -i 'for-you' | awk '{print $1}' | head -1 | xargs -I {} docker exec {} ls -la /app/public/images 2>/dev/null || \
docker ps | grep -i 'for-you' | awk '{print $1}' | head -1 | xargs -I {} docker exec {} ls -la /app/static/images 2>/dev/null

# 4. Перевірити Nginx конфігурацію
cat /etc/nginx/sites-enabled/*for-you* | grep -A 10 "location.*images\|location.*static"

# 5. Перезавантажити Nginx
nginx -t && systemctl reload nginx
```

#### Виправлення PRO-PART (401 помилки):

```bash
# 1. Перевірити, чи є контейнери pro-part
docker ps -a | grep -i 'pro-part'

# 2. Якщо контейнери є, перезапустити їх
docker ps -a | grep -i 'pro-part' | awk '{print $1}' | xargs -r docker restart

# 3. Перевірити backend
curl -s http://localhost:4000/api/auth/login -X POST -H 'Content-Type: application/json' -d '{"email":"test","password":"test"}' | head -c 200

# 4. Перевірити логи backend
docker ps | grep -i 'pro-part.*backend' | awk '{print $1}' | xargs -r docker logs --tail=50

# 5. Перевірити .env файл (якщо контейнери є)
docker ps | grep -i 'pro-part.*backend' | awk '{print $1}' | xargs -r docker exec {} cat /app/.env 2>/dev/null | grep -E "ADMIN_EMAIL|ADMIN_PASSWORD|JWT" || echo "Файл не знайдено"
```

## Детальна діагностика

### Перевірка всіх контейнерів:
```bash
docker ps -a
```

### Перевірка Nginx конфігурацій:
```bash
ls -la /etc/nginx/sites-enabled/
cat /etc/nginx/sites-enabled/*for-you*
cat /etc/nginx/sites-enabled/*pro-part* 2>/dev/null || echo "pro-part конфігурація не знайдена"
```

### Перевірка логів:
```bash
# Nginx логи
tail -50 /var/log/nginx/error.log
tail -50 /var/log/nginx/access.log

# Docker логи
docker ps | grep -i 'for-you' | awk '{print $1}' | xargs -r docker logs --tail=50
docker ps | grep -i 'pro-part' | awk '{print $1}' | xargs -r docker logs --tail=50
```

### Перевірка портів:
```bash
netstat -tulpn | grep -E '3000|3001|4000|5000|8000'
```

## Якщо не допомогло

### Для FOR-YOU:
1. Перевірте, чи правильно налаштовані статичні файли в Next.js
2. Перевірте, чи правильно працює build
3. Можливо потрібно перебудувати контейнери

### Для PRO-PART:
1. Перевірте, чи backend контейнер запущений
2. Перевірте credentials в .env файлі
3. Можливо потрібно перебудувати контейнери
4. Перевірте, чи правильно налаштований JWT_SECRET



