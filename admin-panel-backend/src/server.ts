import 'reflect-metadata';
import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { AppDataSource } from './config/database';
import { entities } from './entities';

// Routes
import authRoutes from './routes/auth.routes';
import propertiesRoutes from './routes/properties.routes';
import settingsRoutes from './routes/settings.routes';
import coursesRoutes from './routes/courses.routes';
import newsRoutes from './routes/news.routes';
import supportRoutes from './routes/support.routes';
import usersRoutes from './routes/users.routes';
import uploadRoutes from './routes/upload.routes';
import apiKeysRoutes from './routes/api-keys.routes';
import publicRoutes from './routes/public.routes';
import collectionsRoutes from './routes/collections.routes';
import favoritesRoutes from './routes/favorites.routes';
import investmentsRoutes from './routes/investments.routes';
import courseProgressRoutes from './routes/course-progress.routes';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 4000;

// Middleware
// CORS налаштування
const allowedOrigins = process.env.CORS_ALLOWED_ORIGINS 
  ? process.env.CORS_ALLOWED_ORIGINS.split(',').map(origin => origin.trim())
  : [
      'https://propart.ae',
      'https://www.propart.ae',
      'https://system.pro-part.online',
      'https://admin.pro-part.online',
      'http://localhost:3000',
      'http://localhost:3001',
      'http://localhost:3002',
    ];

const corsOptions = {
  origin: (origin: string | undefined, callback: (err: Error | null, allow?: boolean | string) => void) => {
    // Дозволяємо запити без origin (наприклад, з Postman або curl)
    if (!origin) {
      return callback(null, true);
    }
    // Перевіряємо, чи origin в списку дозволених
    if (allowedOrigins.includes(origin)) {
      // Повертаємо сам origin, щоб встановити конкретне значення в Access-Control-Allow-Origin
      console.log(`✅ CORS allowed origin: ${origin}`);
      callback(null, origin);
    } else {
      console.warn(`⚠️  CORS blocked origin: ${origin}`);
      callback(new Error(`Not allowed by CORS: ${origin}`));
    }
  },
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'x-api-key', 'x-api-secret'],
  credentials: true,
  optionsSuccessStatus: 200,
};

// CORS для публічних ендпоінтів (дозволяє всі джерела, оскільки захищено через API key)
app.use('/api/public', cors({
  origin: '*', // Дозволяємо всі джерела для публічних API
  methods: ['GET', 'OPTIONS'],
  allowedHeaders: ['x-api-key', 'x-api-secret', 'Content-Type', 'Authorization'],
  credentials: false,
}));

// CORS для інших ендпоінтів
app.use(cors(corsOptions));
app.use(express.json());
app.use('/uploads', express.static('uploads'));

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/properties', propertiesRoutes);
app.use('/api/settings', settingsRoutes);
app.use('/api/settings/api-keys', apiKeysRoutes);
app.use('/api/courses', coursesRoutes);
app.use('/api/news', newsRoutes);
app.use('/api/support', supportRoutes);
app.use('/api/users', usersRoutes);
app.use('/api/upload', uploadRoutes);
app.use('/api/public', publicRoutes);
app.use('/api/collections', collectionsRoutes);
app.use('/api/favorites', favoritesRoutes);
app.use('/api/investments', investmentsRoutes);
app.use('/api/course-progress', courseProgressRoutes);

// Root route
app.get('/', (req, res) => {
  res.json({ 
    message: 'Admin Panel Backend API',
    status: 'running',
    version: '1.0.0',
    endpoints: {
      health: '/health',
      api: '/api'
    }
  });
});

// Health check
app.get('/health', (req, res) => {
  const dbStatus = AppDataSource.isInitialized ? 'connected' : 'disconnected';
  res.json({ 
    status: 'ok', 
    database: dbStatus,
    timestamp: new Date().toISOString() 
  });
});

// Initialize database and start server
console.log('🔄 Initializing database connection...');
console.log('📋 DATABASE_URL:', process.env.DATABASE_URL ? 'Set (hidden)' : 'NOT SET!');
console.log('📊 Entities count:', entities.length);

AppDataSource.initialize()
  .then(async () => {
    console.log('✅ Database connected');
    console.log('📊 Database entities loaded:', AppDataSource.entityMetadatas.length);
    console.log('🔍 Entity names:', AppDataSource.entityMetadatas.map(e => e.name).join(', '));
    
    // Тимчасово: синхронізуємо схему якщо ENABLE_SYNC=true
    if (process.env.ENABLE_SYNC === 'true') {
      console.log('🔄 Synchronizing database schema...');
      await AppDataSource.synchronize();
      console.log('✅ Database schema synchronized');
    }
    
    app.listen(PORT, () => {
      console.log(`🚀 Admin Panel Backend running on http://localhost:${PORT}`);
    });
  })
  .catch((error) => {
    console.error('❌ Database connection failed:', error);
    console.error('Error details:', error.message);
    if (error.stack) {
      console.error('Stack trace:', error.stack);
    }
    console.error('📋 DATABASE_URL:', process.env.DATABASE_URL || 'NOT SET');
    console.error('📊 Entities count:', entities.length);
    // Запускаємо сервер навіть якщо БД не підключилась, щоб бачити помилки
    app.listen(PORT, () => {
      console.log(`⚠️  Admin Panel Backend running WITHOUT database on http://localhost:${PORT}`);
      console.log('⚠️  API will return errors until database is connected');
    });
  });

