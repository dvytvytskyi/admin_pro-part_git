# Інструкції для ручного оновлення на production

## Проблема з автоматичним деплоєм
Якщо автоматичний скрипт не працює через проблеми з SSH, виконайте оновлення вручну.

## Крок 1: Підключення до сервера

```bash
ssh root@135.181.201.185
# Пароль: FNrtVkfCRwgW
```

## Крок 2: Оновлення коду

```bash
cd /opt/admin-pro-part

# Видалити конфліктний файл (якщо є)
rm -f data_export_20251113_032400.sql

# Оновити код
git pull origin main
```

## Крок 3: Перезапуск бекенду

```bash
# Перезапустити бекенд (основне!)
docker-compose -f docker-compose.prod.yml restart admin-pro-part-backend

# Перевірити статус
docker ps | grep admin-pro-part-backend
docker logs admin-pro-part-backend --tail=30
```

## Крок 4: Перевірка API

```bash
# Перевірити, чи API працює
curl -s http://localhost:4001/api/health

# Перевірити areas endpoint (потрібні API ключі)
curl -s http://localhost:4001/api/public/areas \
  -H "X-Api-Key: ваш-ключ" \
  -H "X-Api-Secret: ваш-секрет" \
  | jq '.data[0] | {nameEn, imagesCount: (.images | length)}'
```

## Що оновлюється:

### Бекенд API (admin-panel-backend):
- ✅ `src/routes/public.routes.ts` - виправлено parseArray та подвійну обробку
- ✅ `package.json` - додано нові скрипти

### Результат:
- API `/api/public/areas` тепер повертає `images: []` або `images: ["url1", "url2"]` замість `images: null`
- Всі URL виправлено (без зайвих дужок)

## Якщо помилки:

1. **Git pull не працює:**
   ```bash
   git fetch origin main
   git reset --hard origin/main
   ```

2. **Контейнер не перезапускається:**
   ```bash
   docker-compose -f docker-compose.prod.yml stop admin-pro-part-backend
   docker-compose -f docker-compose.prod.yml up -d admin-pro-part-backend
   ```

3. **Перевірити логи:**
   ```bash
   docker logs admin-pro-part-backend --tail=50
   ```

