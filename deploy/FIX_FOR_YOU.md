# Виправлення for-you проекту після видалення pro-part

## Проблема
Після видалення pro-part проекту, for-you проект показує помилку **502 Bad Gateway**.

## Швидке виправлення

### Варіант 1: Автоматичний скрипт
```bash
cd /Users/vytvytskyi/admin_pro-part
./deploy/fix-for-you.sh
```

### Варіант 2: Вручну на сервері

Підключіться до сервера:
```bash
ssh root@135.181.201.185
# Пароль: FNrtVkfCRwgW
```

Потім виконайте:

```bash
# 1. Перевірити стан контейнерів for-you
docker ps -a | grep -i 'for-you'

# 2. Перезапустити всі контейнери for-you
docker ps -a | grep -i 'for-you' | awk '{print $1}' | xargs -r docker restart

# 3. Перевірити, чи запустилися
docker ps | grep -i 'for-you'

# 4. Перевірити Nginx конфігурацію
nginx -t

# 5. Перезавантажити Nginx
systemctl reload nginx

# 6. Перевірити логи, якщо все ще не працює
docker ps -a | grep -i 'for-you' | awk '{print $1}' | head -1 | xargs docker logs --tail=50
tail -50 /var/log/nginx/error.log
```

## Можливі причини

1. **Контейнери зупинилися** - потрібно перезапустити
2. **Nginx конфігурація зламана** - потрібно перевірити та виправити
3. **Порт зайнятий** - можливо pro-part використовував той самий порт
4. **Docker network проблеми** - можливо спільна мережа була видалена

## Детальна діагностика

```bash
# Перевірити всі контейнери
docker ps -a

# Перевірити Docker networks
docker network ls

# Перевірити порти
netstat -tulpn | grep -E '3000|3001|4000|5000|8000'

# Перевірити Nginx конфігурації
ls -la /etc/nginx/sites-enabled/
cat /etc/nginx/sites-enabled/*for-you* 2>/dev/null

# Перевірити логи
docker logs $(docker ps -a | grep -i 'for-you' | awk '{print $1}' | head -1) --tail=100
```

## Якщо не допомогло

1. Перевірте, чи є docker-compose файл для for-you
2. Перезапустіть всі сервіси:
   ```bash
   systemctl restart docker
   # Потім перезапустіть контейнери for-you
   ```
3. Перевірте, чи не були видалені спільні volumes або networks

