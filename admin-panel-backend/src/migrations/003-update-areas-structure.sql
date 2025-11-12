-- Міграція для оновлення структури таблиці areas
-- Додавання JSONB полів для description та infrastructure

-- 1. Перетворення description TEXT на JSONB
-- Якщо description вже існує як TEXT, конвертуємо його
DO $$ 
BEGIN
    -- Перевіряємо чи є колонка description як TEXT
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'areas' 
        AND column_name = 'description' 
        AND data_type = 'text'
    ) THEN
        -- Створюємо тимчасову колонку для нового формату
        ALTER TABLE areas ADD COLUMN IF NOT EXISTS description_new JSONB;
        
        -- Копіюємо дані зі старого формату в новий (якщо є)
        UPDATE areas 
        SET description_new = jsonb_build_object('description', description)
        WHERE description IS NOT NULL AND description != '';
        
        -- Видаляємо стару колонку
        ALTER TABLE areas DROP COLUMN IF EXISTS description;
        
        -- Перейменовуємо нову колонку
        ALTER TABLE areas RENAME COLUMN description_new TO description;
    END IF;
    
    -- Якщо description не існує, просто створюємо JSONB колонку
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'areas' 
        AND column_name = 'description'
    ) THEN
        ALTER TABLE areas ADD COLUMN description JSONB;
    END IF;
END $$;

-- 2. Додавання колонки infrastructure як JSONB
ALTER TABLE areas ADD COLUMN IF NOT EXISTS infrastructure JSONB;

-- 3. Перевірка що images існує (вже має бути з міграції 002)
ALTER TABLE areas ADD COLUMN IF NOT EXISTS images TEXT[];

-- 4. Створення індексів для JSONB полів (опціонально, для пошуку)
CREATE INDEX IF NOT EXISTS idx_areas_description ON areas USING gin(description);
CREATE INDEX IF NOT EXISTS idx_areas_infrastructure ON areas USING gin(infrastructure);

