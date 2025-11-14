import 'reflect-metadata';
import { AppDataSource } from '../config/database';
import { ApiKey } from '../entities/ApiKey';

async function createSpecificApiKey() {
  try {
    console.log('🔑 Створення конкретного API ключа...\n');

    await AppDataSource.initialize();
    console.log('✅ Підключено до бази даних\n');

    const apiKeyRepo = AppDataSource.getRepository(ApiKey);

    // Конкретні значення з запиту
    const apiKey = 'fyr_8f968d115244e76d209a26f5177c5c998aca0e8dbce4a6e9071b2bc43b78f6d2';
    const apiSecret = '5c8335f9c7e476cbe77454fd32532cc68f57baf86f7f96e6bafcf682f98b275bc579d73484cf5bada7f4cd7d071b122778b71f414fb96b741c5fe60394d1795f';

    console.log('📝 Створюю API ключ:');
    console.log(`   API Key: ${apiKey}`);
    console.log(`   API Secret: ${apiSecret.substring(0, 30)}...\n`);

    // Перевірка на дублікати
    const existingKey = await apiKeyRepo.findOne({
      where: { apiKey },
    });

    if (existingKey) {
      console.log('⚠️  Ключ з таким значенням вже існує!');
      console.log(`   ID: ${existingKey.id}`);
      console.log(`   Назва: ${existingKey.name}`);
      console.log(`   Активний: ${existingKey.isActive ? '✅' : '❌'}`);
      return;
    }

    // Створення нового ключа
    const newApiKey = apiKeyRepo.create({
      apiKey,
      apiSecret,
      name: 'Production API Key for propart.ae',
      isActive: true,
    });

    const saved = await apiKeyRepo.save(newApiKey);

    console.log('✅ API ключ успішно створено!');
    console.log(`   ID: ${saved.id}`);
    console.log(`   Назва: ${saved.name}`);
    console.log(`   API Key: ${saved.apiKey}`);
    console.log(`   API Secret: ${saved.apiSecret}`);
    console.log(`   Активний: ${saved.isActive ? '✅' : '❌'}`);
    console.log(`   Створено: ${saved.createdAt}\n`);

    console.log('📋 Тестовий запит:');
    console.log(`   curl -H "x-api-key: ${saved.apiKey}" \\`);
    console.log(`        -H "x-api-secret: ${saved.apiSecret}" \\`);
    console.log(`        https://admin.pro-part.online/api/public/areas\n`);

    await AppDataSource.destroy();
  } catch (error: any) {
    console.error('❌ Помилка:', error.message);
    if (error.stack) {
      console.error(error.stack);
    }
    process.exit(1);
  }
}

createSpecificApiKey();

