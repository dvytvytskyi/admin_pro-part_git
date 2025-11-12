# Інструкція з імпорту off-plan даних

## ✅ Що вже зроблено:

1. **Експорт даних зі старої БД** - виконано
   - Файли знаходяться в: `/Users/vytvytskyi/admin_pro-part/exported-offplan-data/`
   - Експортовано:
     - 2 Countries
     - 2 Cities
     - 324 Areas
     - 739 Developers
     - 4631 Facilities
     - 1455 Off-plan Properties
     - 4822 PropertyUnits
     - 10957 Property-Facility зв'язків

2. **Скрипт імпорту створено** - `admin-panel-backend/src/scripts/import-exported-offplan-data.ts`
3. **Команда додана в package.json** - `npm run import:exported-offplan`

## 📋 Покрокова інструкція імпорту:

### Крок 1: Запустити базу даних

```bash
cd /Users/vytvytskyi/admin_pro-part
docker-compose up -d admin-panel-db
```

Перевірити, що БД запущена:
```bash
docker ps | grep admin-pro-part-postgres
```

Контейнер працює на порту **5436** (не 5435!)

### Крок 2: Запустити міграції (якщо ще не запускали)

```bash
cd admin-panel-backend
npm install
npm run migration:run
```

### Крок 3: Перевірити наявність експортованих даних

```bash
ls -la exported-offplan-data/
```

Мають бути файли:
- `countries.json`
- `cities.json`
- `areas.json`
- `developers.json`
- `facilities.json`
- `properties-offplan.json`
- `property-units-offplan.json`
- `properties-facilities-offplan.json`

### Крок 4: Запустити імпорт

```bash
cd admin-panel-backend
npm run import:exported-offplan
```

Скрипт автоматично:
1. Підключиться до БД
2. Імпортує дані в правильному порядку (Countries → Cities → Areas → Developers → Facilities → Properties → Units → Links)
3. Покаже статистику імпорту
4. Перевірить кількість записів в БД

### Крок 5: Перевірка результатів

Після імпорту перевірте:

```bash
# Підключитися до БД
docker exec -it admin-pro-part-postgres psql -U admin -d admin_panel

# Перевірити кількість записів
SELECT 
  'Countries' as table_name, COUNT(*) as count FROM countries
UNION ALL
SELECT 'Cities', COUNT(*) FROM cities
UNION ALL
SELECT 'Areas', COUNT(*) FROM areas
UNION ALL
SELECT 'Developers', COUNT(*) FROM developers
UNION ALL
SELECT 'Facilities', COUNT(*) FROM facilities
UNION ALL
SELECT 'Properties (off-plan)', COUNT(*) FROM properties WHERE "propertyType" = 'off-plan'
UNION ALL
SELECT 'PropertyUnits', COUNT(*) FROM property_units;
```

## ⚠️ Важливо:

1. **Порядок імпорту важливий** - скрипт автоматично імпортує в правильному порядку
2. **Secondary properties** - якщо після імпорту знайдено secondary properties, їх можна видалити:
   ```sql
   DELETE FROM property_units WHERE "propertyId" IN (SELECT id FROM properties WHERE "propertyType" = 'secondary');
   DELETE FROM properties WHERE "propertyType" = 'secondary';
   ```
3. **Конфлікти UUID** - якщо UUID вже існують, TypeORM автоматично оновить записи
4. **Зв'язки Property-Facility** - скрипт автоматично знайде правильну назву таблиці

## 🔧 Налаштування:

### DATABASE_URL

Переконайтеся, що в `.env` файлі правильний `DATABASE_URL`:

```env
DATABASE_URL=postgresql://admin:admin123@localhost:5436/admin_panel
```

**Важливо:** Порт **5436** (не 5435)!

### Змінна середовища для імпорту

Якщо дані знаходяться в іншій директорії, можна встановити змінну середовища:

```bash
export IMPORT_DATA_DIR=/path/to/exported-offplan-data
npm run import:exported-offplan
```

## 📊 Очікувані результати:

Після успішного імпорту в БД має бути:
- ✅ 2 Countries
- ✅ 2 Cities
- ✅ 324 Areas
- ✅ 739 Developers
- ✅ 4631 Facilities
- ✅ 1455 Off-plan Properties
- ✅ 4822 PropertyUnits
- ✅ 10957 Property-Facility зв'язків

## ❌ Якщо щось пішло не так:

1. Перевірте логи скрипта - він покаже детальну інформацію про помилки
2. Перевірте підключення до БД в `.env` файлі
3. Переконайтеся, що міграції виконані
4. Перевірте, що всі JSON файли валідні (можна перевірити через `jq`)

## 🎯 Наступні кроки:

Після успішного імпорту:
1. Перевірте API endpoints
2. Перевірте frontend
3. Видаліть secondary properties (якщо потрібно)
4. Налаштуйте production конфігурацію

