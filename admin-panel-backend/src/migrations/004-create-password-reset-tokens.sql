-- Migration to create password_reset_tokens table
-- First, ensure users table has a primary key (if not exists)

DO $$
BEGIN
    -- Check if primary key exists, if not, add it
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints
        WHERE table_name = 'users' AND constraint_type = 'PRIMARY KEY'
    ) THEN
        -- Add primary key constraint to users table
        ALTER TABLE users ADD CONSTRAINT users_pkey PRIMARY KEY (id);
    END IF;
END $$;

CREATE TABLE IF NOT EXISTS password_reset_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    code VARCHAR(6) NOT NULL,
    reset_token TEXT NOT NULL,
    used BOOLEAN DEFAULT FALSE,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_password_reset_tokens_user_id ON password_reset_tokens(user_id);
CREATE INDEX idx_password_reset_tokens_code ON password_reset_tokens(code);
CREATE INDEX idx_password_reset_tokens_reset_token ON password_reset_tokens(reset_token);
CREATE INDEX idx_password_reset_tokens_used ON password_reset_tokens(used);
CREATE INDEX idx_password_reset_tokens_expires_at ON password_reset_tokens(expires_at);

