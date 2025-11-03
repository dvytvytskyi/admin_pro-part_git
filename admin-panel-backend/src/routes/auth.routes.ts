import express from 'express';
import jwt from 'jsonwebtoken';
import bcrypt from 'bcrypt';
import { AppDataSource } from '../config/database';
import { User, UserRole, UserStatus } from '../entities/User';
import { successResponse } from '../utils/response';
import { authenticateJWT } from '../middleware/auth';

const router = express.Router();

router.post('/login', async (req, res) => {
  const { email, password } = req.body;

  // Спочатку перевіряємо через env (для старого адміна)
  if (email === process.env.ADMIN_EMAIL && password === process.env.ADMIN_PASSWORD) {
    // Шукаємо користувача в БД або створюємо токен з email
    const adminUser = await AppDataSource.getRepository(User).findOne({
      where: { email },
    });
    
    const payload = adminUser 
      ? { id: adminUser.id, email, role: adminUser.role }
      : { email, role: 'ADMIN' };
    
    const token = jwt.sign(payload, process.env.ADMIN_JWT_SECRET!, { expiresIn: '7d' });
    return res.json(successResponse({ token }, 'Login successful'));
  }

  // Перевіряємо в БД для реєстрованих користувачів
  const user = await AppDataSource.getRepository(User).findOne({
    where: { email },
  });

  if (!user) {
    return res.status(401).json({ success: false, message: 'Invalid credentials' });
  }

  const isValidPassword = await bcrypt.compare(password, user.passwordHash);
  if (!isValidPassword) {
    return res.status(401).json({ success: false, message: 'Invalid credentials' });
  }

  const token = jwt.sign(
    { id: user.id, email: user.email, role: user.role },
    process.env.ADMIN_JWT_SECRET!,
    { expiresIn: '7d' }
  );

  const { passwordHash: _, ...userWithoutPassword } = user;
  return res.json(successResponse({ token, user: userWithoutPassword }, 'Login successful'));
});

router.get('/me', authenticateJWT, async (req: any, res) => {
  try {
    const userId = req.user?.id;
    if (!userId) {
      return res.status(401).json({ success: false, message: 'User not found' });
    }

    const user = await AppDataSource.getRepository(User).findOne({
      where: { id: userId },
      select: ['id', 'email', 'phone', 'firstName', 'lastName', 'role', 'status', 'licenseNumber', 'avatar', 'createdAt', 'updatedAt'],
    });

    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    return res.json(successResponse(user));
  } catch (error: any) {
    console.error('Error fetching user:', error);
    return res.status(500).json({ success: false, message: 'Failed to fetch user' });
  }
});

router.post('/register', async (req, res) => {
  try {
    const { email, phone, password, firstName, lastName, role, licenseNumber } = req.body;

    // Validate required fields
    if (!email || !phone || !password || !firstName || !lastName || !role) {
      return res.status(400).json({ success: false, message: 'All required fields must be provided' });
    }

    // Validate role
    if (!Object.values(UserRole).includes(role)) {
      return res.status(400).json({ success: false, message: 'Invalid role' });
    }

    // Validate broker requires license number
    if (role === UserRole.BROKER && !licenseNumber) {
      return res.status(400).json({ success: false, message: 'License number is required for BROKER role' });
    }

    const userRepository = AppDataSource.getRepository(User);

    // Check if user already exists
    const existingUser = await userRepository.findOne({
      where: [{ email }, { phone }],
    });

    if (existingUser) {
      return res.status(409).json({ success: false, message: 'User with this email or phone already exists' });
    }

    // Hash password
    const passwordHash = await bcrypt.hash(password, 10);

    // Create user
    const user = userRepository.create({
      email,
      phone,
      passwordHash,
      firstName,
      lastName,
      role,
      licenseNumber: licenseNumber || null,
      status: role === UserRole.CLIENT ? UserStatus.ACTIVE : UserStatus.PENDING,
    });

    await userRepository.save(user);

    // Generate JWT token
    const token = jwt.sign(
      { id: user.id, email: user.email, role: user.role },
      process.env.ADMIN_JWT_SECRET!,
      { expiresIn: '7d' }
    );

    // Don't return password hash
    const { passwordHash: _, ...userWithoutPassword } = user;

    return res.status(201).json(successResponse({ user: userWithoutPassword, accessToken: token }, 'User created successfully'));
  } catch (error: any) {
    console.error('Registration error:', error);
    return res.status(500).json({ success: false, message: 'Failed to create user' });
  }
});

export default router;

