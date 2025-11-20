import 'reflect-metadata';
import { AppDataSource } from '../config/database';

async function createChatTables() {
  try {
    console.log('🔄 Connecting to database...');
    await AppDataSource.initialize();
    console.log('✅ Database connected\n');

    const queryRunner = AppDataSource.createQueryRunner();
    await queryRunner.connect();

    try {
      // Створюємо enum типи, якщо вони не існують
      console.log('📋 Creating enum types...');
      await queryRunner.query(`
        DO $$ BEGIN
          CREATE TYPE chat_session_status AS ENUM ('active', 'closed', 'archived');
        EXCEPTION
          WHEN duplicate_object THEN null;
        END $$;
      `);

      await queryRunner.query(`
        DO $$ BEGIN
          CREATE TYPE chat_message_sender AS ENUM ('user', 'manager');
        EXCEPTION
          WHEN duplicate_object THEN null;
        END $$;
      `);

      // Створюємо таблицю chat_sessions
      console.log('📋 Creating chat_sessions table...');
      await queryRunner.query(`
        CREATE TABLE IF NOT EXISTS chat_sessions (
          id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
          userName VARCHAR,
          userPhone VARCHAR,
          status chat_session_status NOT NULL DEFAULT 'active',
          "managerId" UUID,
          "userSessionId" VARCHAR,
          "createdAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
          "updatedAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
        );
      `);

      // Створюємо таблицю chat_messages
      console.log('📋 Creating chat_messages table...');
      await queryRunner.query(`
        CREATE TABLE IF NOT EXISTS chat_messages (
          id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
          "sessionId" UUID NOT NULL REFERENCES chat_sessions(id) ON DELETE CASCADE,
          sender chat_message_sender NOT NULL,
          "messageText" TEXT NOT NULL,
          "managerId" UUID,
          "createdAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
        );
      `);

      // Створюємо індекси для кращої продуктивності
      console.log('📋 Creating indexes...');
      await queryRunner.query(`
        CREATE INDEX IF NOT EXISTS idx_chat_sessions_status ON chat_sessions(status);
        CREATE INDEX IF NOT EXISTS idx_chat_sessions_user_session_id ON chat_sessions("userSessionId");
        CREATE INDEX IF NOT EXISTS idx_chat_sessions_user_phone ON chat_sessions("userPhone");
        CREATE INDEX IF NOT EXISTS idx_chat_sessions_updated_at ON chat_sessions("updatedAt" DESC);
        CREATE INDEX IF NOT EXISTS idx_chat_messages_session_id ON chat_messages("sessionId");
        CREATE INDEX IF NOT EXISTS idx_chat_messages_created_at ON chat_messages("createdAt" DESC);
        CREATE INDEX IF NOT EXISTS idx_chat_messages_sender ON chat_messages(sender);
      `);

      console.log('\n✅ Chat tables created successfully!');
    } finally {
      await queryRunner.release();
    }

    await AppDataSource.destroy();
    console.log('\n✅ Done!');
  } catch (error: any) {
    console.error('❌ Error:', error.message);
    if (error.stack) {
      console.error(error.stack);
    }
    if (AppDataSource.isInitialized) {
      await AppDataSource.destroy();
    }
    process.exit(1);
  }
}

createChatTables();

