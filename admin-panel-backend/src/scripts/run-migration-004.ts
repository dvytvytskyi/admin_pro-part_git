import 'reflect-metadata';
import { AppDataSource } from '../config/database';
import * as fs from 'fs';
import * as path from 'path';

async function runMigration004() {
  try {
    await AppDataSource.initialize();
    console.log('✅ Database connected');

    const migrationPath = path.join(__dirname, '../migrations/004-create-password-reset-tokens.sql');
    const migrationSQL = fs.readFileSync(migrationPath, 'utf-8');

    console.log('🔄 Running migration 004...');
    await AppDataSource.query(migrationSQL);
    console.log('✅ Migration 004 completed successfully');

    await AppDataSource.destroy();
    console.log('✅ Database connection closed');
  } catch (error: any) {
    console.error('❌ Error running migration 004:', error);
    process.exit(1);
  }
}

runMigration004();

