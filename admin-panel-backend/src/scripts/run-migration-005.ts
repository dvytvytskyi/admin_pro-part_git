import { AppDataSource } from '../config/database';
import * as fs from 'fs';
import * as path from 'path';

async function runMigration() {
  try {
    await AppDataSource.initialize();
    console.log('✅ Database connected');

    const migrationFile = path.join(__dirname, '../migrations/005-create-course-progress.sql');
    const sql = fs.readFileSync(migrationFile, 'utf-8');

    console.log('📄 Running migration 005: create-course-progress...');
    
    await AppDataSource.query(sql);
    
    console.log('✅ Migration 005 completed successfully');
  } catch (error: any) {
    console.error('❌ Migration failed:', error);
    process.exit(1);
  } finally {
    if (AppDataSource.isInitialized) {
      await AppDataSource.destroy();
    }
  }
}

runMigration();

