import 'reflect-metadata';
import bcrypt from 'bcrypt';
import { AppDataSource } from '../config/database';
import { User, UserRole, UserStatus } from '../entities/User';

async function createUser() {
  try {
    console.log('🔄 Connecting to database...');
    await AppDataSource.initialize();
    console.log('✅ Database connected\n');

    const email = 'anna@propart.ae';
    const phone = '+971501234567'; // Default phone, can be updated later
    const password = 'Anna2025!ProPart';
    const firstName = 'Anna';
    const lastName = 'ProPart';
    const role = UserRole.ADMIN;
    const status = UserStatus.ACTIVE;

    const userRepository = AppDataSource.getRepository(User);

    // Check if user already exists
    const existingUser = await userRepository.findOne({
      where: [{ email }, { phone }],
    });

    if (existingUser) {
      console.log('⚠️  User already exists!');
      console.log('   Email:', existingUser.email);
      console.log('   Phone:', existingUser.phone);
      console.log('   Role:', existingUser.role);
      console.log('\n📋 User credentials:');
      console.log('   Email:', email);
      console.log('   Password:', password);
      await AppDataSource.destroy();
      return;
    }

    // Hash password
    console.log('🔐 Hashing password...');
    const passwordHash = await bcrypt.hash(password, 10);

    // Create user
    console.log('👤 Creating user...');
    const user = userRepository.create({
      email,
      phone,
      passwordHash,
      firstName,
      lastName,
      role,
      status,
    });

    await userRepository.save(user);

    console.log('\n✅ User created successfully!\n');
    console.log('📋 User credentials:');
    console.log('   Email:', email);
    console.log('   Username:', email);
    console.log('   Password:', password);
    console.log('   Role:', role);
    console.log('   Status:', status);
    console.log('   First Name:', firstName);
    console.log('   Last Name:', lastName);
    console.log('   Phone:', phone);
    console.log('\n⚠️  Please save these credentials securely!');

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

createUser();

