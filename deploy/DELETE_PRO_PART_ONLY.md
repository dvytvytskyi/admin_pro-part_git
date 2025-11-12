# Інструкції для видалення ТІЛЬКИ pro-part проекту з сервера

## ⚠️ УВАГА
Ця операція видалить **ТІЛЬКИ pro-part** проект:
- Всі файли проекту pro-part
- Docker контейнери pro-part
- Docker volumes pro-part (включаючи базу даних pro-part!)
- Docker images pro-part
- Nginx конфігурації pro-part
- Логи pro-part

**НЕ чіпаємо for-you проекти!**

## Виконання

### Варіант 1: Автоматичний скрипт (локально)

```bash
cd /Users/vytvytskyi/admin_pro-part
./deploy/delete-project-from-server.sh
```

### Варіант 2: Вручну на сервері

Підключіться до сервера:
```bash
ssh root@135.181.201.185
# Пароль: FNrtVkfCRwgW
```

Потім виконайте наступні команди (ТІЛЬКИ pro-part):

```bash
# 1. Зупинити та видалити Docker контейнери ТІЛЬКИ pro-part
cd /opt/admin-pro-part 2>/dev/null && docker-compose -f docker-compose.prod.yml down -v 2>/dev/null || true

# Видалити контейнери pro-part вручну (якщо залишилися)
docker ps -a | grep -i 'pro-part' | awk '{print $1}' | xargs -r docker rm -f 2>/dev/null || true

# 2. Видалити Docker volumes ТІЛЬКИ pro-part (включаючи БД pro-part!)
docker volume ls | grep -i 'pro-part' | awk '{print $2}' | xargs -r docker volume rm 2>/dev/null || true

# 3. Видалити Docker images ТІЛЬКИ pro-part
docker images | grep -i 'pro-part' | awk '{print $3}' | xargs -r docker rmi -f 2>/dev/null || true

# 4. Видалити директорії проекту ТІЛЬКИ pro-part
rm -rf /opt/admin-pro-part

# 5. Видалити Nginx конфігурації ТІЛЬКИ pro-part
rm -f /etc/nginx/sites-enabled/*pro-part* 2>/dev/null || true
rm -f /etc/nginx/sites-available/*pro-part* 2>/dev/null || true
nginx -t && systemctl reload nginx 2>/dev/null || true

# 6. Видалити логи ТІЛЬКИ pro-part
rm -rf /var/log/*pro-part* 2>/dev/null || true

# 7. Видалити systemd сервіси ТІЛЬКИ pro-part (якщо є)
systemctl stop *pro-part* 2>/dev/null || true
systemctl disable *pro-part* 2>/dev/null || true
rm -f /etc/systemd/system/*pro-part* 2>/dev/null || true
systemctl daemon-reload 2>/dev/null || true

# Перевірка видалення pro-part
echo "=== Перевірка видалення pro-part ==="
ls -la /opt/ | grep -i 'pro-part' || echo "✅ Директорії pro-part видалені"
docker ps -a | grep -i 'pro-part' || echo "✅ Контейнери pro-part видалені"
docker volume ls | grep -i 'pro-part' || echo "✅ Volumes pro-part видалені"

# Перевірка, що for-you НЕ чіпали
echo ""
echo "=== Перевірка, що for-you на місці ==="
docker ps -a | grep -i 'for-you' && echo "✅ for-you контейнери на місці" || echo "ℹ️  for-you контейнери не знайдені"
ls -la /opt/ | grep -i 'for-you' && echo "✅ for-you директорії на місці" || echo "ℹ️  for-you директорії не знайдені"
```

## Після видалення

Після виконання всіх команд проект pro-part буде повністю видалено з сервера, але for-you залишиться недоторканим.

Якщо потрібно відновити pro-part проект, виконайте деплой заново.

