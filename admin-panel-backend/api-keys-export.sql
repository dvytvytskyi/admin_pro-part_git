-- API Keys Export
-- Generated: 2025-11-06T09:43:28.191Z
-- Total keys: 1

-- Увага: Цей скрипт використовує ON CONFLICT для оновлення існуючих ключів
-- Якщо ключ з таким api_key вже існує, він буде оновлено

-- Key 1: Test API Key
INSERT INTO api_keys (id, api_key, api_secret, name, is_active, created_at, updated_at, last_used_at)
VALUES (
  '2ea96c29-fffb-4b03-93c7-acf265d032a4'::uuid,
  'ak_aa4d19418b385c370939b45365d0c687ddbdef7cbe9a72548748ef67f5e469e1',
  'as_623caef2632983630ce11293e544504c834a9ab1015fa2c75a7c2583d6f28d7c',
  'Test API Key',
  true,
  '2025-11-05T21:06:36.362Z',
  '2025-11-05T21:06:36.362Z',
  NULL
)
ON CONFLICT (api_key) DO UPDATE SET
  api_secret = EXCLUDED.api_secret,
  name = EXCLUDED.name,
  is_active = EXCLUDED.is_active,
  updated_at = EXCLUDED.updated_at,
  last_used_at = COALESCE(EXCLUDED.last_used_at, api_keys.last_used_at);

