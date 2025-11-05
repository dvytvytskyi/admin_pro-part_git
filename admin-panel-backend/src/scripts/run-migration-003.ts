import { AppDataSource } from '../config/database';
import * as fs from 'fs';
import * as path from 'path';

async function runMigration003() {
  try {
    await AppDataSource.initialize();
    console.log('✅ Database connected');

    const migrationPath = path.join(__dirname, '../migrations/003-update-areas-structure.sql');
    const migrationSQL = fs.readFileSync(migrationPath, 'utf-8');

    console.log('🔄 Running migration 003...');
    await AppDataSource.query(migrationSQL);
    console.log('✅ Migration 003 completed successfully');

    await AppDataSource.destroy();
    console.log('✅ Database connection closed');
  } catch (error: any) {
    console.error('❌ Error running migration 003:', error);
    process.exit(1);
  }
}

runMigration003();

