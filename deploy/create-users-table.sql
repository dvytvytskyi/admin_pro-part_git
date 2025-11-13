-- Створення таблиці users
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL DEFAULT 'CLIENT' CHECK (role IN ('CLIENT', 'BROKER', 'INVESTOR', 'ADMIN')),
    status VARCHAR(50) NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('PENDING', 'ACTIVE', 'BLOCKED', 'REJECTED')),
    license_number VARCHAR(255),
    google_id VARCHAR(255),
    apple_id VARCHAR(255),
    avatar VARCHAR(255),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Створення індексу для email
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

-- Створення індексу для phone
CREATE INDEX IF NOT EXISTS idx_users_phone ON users(phone);

