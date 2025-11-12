# Інструкції для повного видалення проекту з сервера

## ⚠️ УВАГА
Ця операція видалить **ВСЕ** з сервера:
- Всі файли проекту
- Docker контейнери
- Docker volumes (включаючи базу даних!)
- Docker images
- Nginx конфігурації
- Логи

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

Потім виконайте наступні команди:

```bash
# 1. Зупинити та видалити Docker контейнери
cd /opt/admin-panel 2>/dev/null && docker-compose -f docker-compose.prod.yml down -v 2>/dev/null || true
cd /opt/admin-pro-part 2>/dev/null && docker-compose -f docker-compose.prod.yml down -v 2>/dev/null || true

# Видалити контейнери вручну
docker ps -a | grep -E 'admin|for-you' | awk '{print $1}' | xargs -r docker rm -f 2>/dev/null || true

# 2. Видалити Docker volumes (включаючи БД!)
docker volume ls | grep -E 'admin|for-you' | awk '{print $2}' | xargs -r docker volume rm 2>/dev/null || true

# 3. Видалити Docker images
docker images | grep -E 'admin|for-you' | awk '{print $3}' | xargs -r docker rmi -f 2>/dev/null || true

# 4. Видалити директорії проекту
rm -rf /opt/admin-panel 2>/dev/null || true
rm -rf /opt/admin-pro-part 2>/dev/null || true

# 5. Видалити Nginx конфігурації
rm -f /etc/nginx/sites-enabled/admin-panel* 2>/dev/null || true
rm -f /etc/nginx/sites-enabled/admin-pro-part* 2>/dev/null || true
rm -f /etc/nginx/sites-available/admin-panel* 2>/dev/null || true
rm -f /etc/nginx/sites-available/admin-pro-part* 2>/dev/null || true

# Перезавантажити Nginx
nginx -t && systemctl reload nginx 2>/dev/null || true

# 6. Видалити логи
rm -rf /var/log/admin-panel* 2>/dev/null || true
rm -rf /var/log/admin-pro-part* 2>/dev/null || true

# 7. Видалити systemd сервіси (якщо є)
systemctl stop admin-panel* 2>/dev/null || true
systemctl disable admin-panel* 2>/dev/null || true
rm -f /etc/systemd/system/admin-panel* 2>/dev/null || true
systemctl daemon-reload 2>/dev/null || true

# Перевірка
ls -la /opt/ | grep -E 'admin|pro-part' || echo "✅ Директорії видалені"
docker ps -a | grep -E 'admin|for-you' || echo "✅ Контейнери видалені"
docker volume ls | grep -E 'admin|for-you' || echo "✅ Volumes видалені"
```

## Після видалення

Після виконання всіх команд проект буде повністю видалено з сервера.

Якщо потрібно відновити проект, виконайте деплой заново.

