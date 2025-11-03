import { DataSource } from 'typeorm';
import dotenv from 'dotenv';

dotenv.config();

// Використовуємо різні шляхи для development та production
const isProduction = process.env.NODE_ENV === 'production';
const entitiesPath = isProduction ? ['dist/entities/**/*.js'] : ['src/entities/**/*.ts'];
const migrationsPath = isProduction ? ['dist/migrations/**/*.js'] : ['src/migrations/**/*.ts'];

export const AppDataSource = new DataSource({
  type: 'postgres',
  url: process.env.DATABASE_URL,
  synchronize: false, // Вимикаємо синхронізацію, щоб уникнути конфліктів
  logging: process.env.NODE_ENV === 'development',
  entities: entitiesPath,
  migrations: migrationsPath,
});

