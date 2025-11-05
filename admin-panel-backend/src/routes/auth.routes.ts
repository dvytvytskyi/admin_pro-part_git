import express from 'express';
import jwt from 'jsonwebtoken';
import bcrypt from 'bcrypt';
import { AppDataSource } from '../config/database';
import { User, UserRole, UserStatus } from '../entities/User';
import { PasswordResetToken } from '../entities/PasswordResetToken';
import { successResponse } from '../utils/response';
import { authenticateJWT } from '../middleware/auth';
import { sendResetCodeEmail } from '../services/email.service';

const router = express.Router();

router.post('/login', async (req, res) => {
  const { email, password } = req.body;

  // Спочатку перевіряємо через env (для старого адміна)
  if (email === process.env.ADMIN_EMAIL && password === process.env.ADMIN_PASSWORD) {
    // Шукаємо користувача в БД або створюємо токен з email
    const adminUser = await AppDataSource.getRepository(User).findOne({
      where: { email },
    });
    
    // Завжди створюємо токен з id (якщо користувач не знайдений в БД, створюємо ід з email)
    const payload = adminUser 
      ? { id: adminUser.id, email, role: adminUser.role }
      : { id: 'admin-env-user', email, role: 'ADMIN' };
    
    const token = jwt.sign(payload, process.env.ADMIN_JWT_SECRET!, { expiresIn: '7d' });
    
    // Якщо користувач не знайдений в БД, повертаємо мінімальні дані
    if (!adminUser) {
      return res.json(successResponse({ 
        token,
        user: { 
          email, 
          role: 'ADMIN',
          status: 'ACTIVE'
        } 
      }, 'Login successful'));
    }
    
    const { passwordHash: _, ...userWithoutPassword } = adminUser;
    return res.json(successResponse({ token, user: userWithoutPassword }, 'Login successful'));
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

// Generate 6-digit code
const generateResetCode = (): string => {
  return Math.floor(100000 + Math.random() * 900000).toString();
};

router.post('/forgot-password', async (req, res) => {
  try {
    const { email } = req.body;

    if (!email) {
      return res.status(400).json({ success: false, message: 'Email is required' });
    }

    const userRepository = AppDataSource.getRepository(User);
    const tokenRepository = AppDataSource.getRepository(PasswordResetToken);

    // Find user by email
    const user = await userRepository.findOne({
      where: { email: email.toLowerCase().trim() },
    });

    // Always return success (security: don't reveal if email exists)
    if (!user) {
      return res.json(successResponse(null, 'If the email exists, a password reset code has been sent'));
    }

    // Generate 6-digit code
    const code = generateResetCode();

    // Generate reset token (JWT)
    const resetToken = jwt.sign(
      { userId: user.id, email: user.email, type: 'password-reset' },
      process.env.ADMIN_JWT_SECRET!,
      { expiresIn: '15m' }
    );

    // Invalidate any existing reset tokens for this user
    await tokenRepository.update(
      { userId: user.id, used: false },
      { used: true }
    );

    // Create new reset token
    const expiresAt = new Date();
    expiresAt.setMinutes(expiresAt.getMinutes() + 15); // 15 minutes from now

    const resetTokenEntity = tokenRepository.create({
      userId: user.id,
      code,
      resetToken,
      used: false,
      expiresAt,
    });

    await tokenRepository.save(resetTokenEntity);

    // Send email with code
    await sendResetCodeEmail(user.email, code);

    return res.json(successResponse(null, 'If the email exists, a password reset code has been sent'));
  } catch (error: any) {
    console.error('Error in forgot-password:', error);
    return res.status(500).json({ success: false, message: 'Failed to process password reset request' });
  }
});

router.post('/verify-reset-code', async (req, res) => {
  try {
    const { email, code } = req.body;

    if (!email || !code) {
      return res.status(400).json({ success: false, message: 'Email and code are required' });
    }

    const userRepository = AppDataSource.getRepository(User);
    const tokenRepository = AppDataSource.getRepository(PasswordResetToken);

    // Find user
    const user = await userRepository.findOne({
      where: { email: email.toLowerCase().trim() },
    });

    if (!user) {
      return res.status(404).json({ success: false, message: 'Invalid email or code' });
    }

    // Find active reset token
    const resetTokenEntity = await tokenRepository.findOne({
      where: {
        userId: user.id,
        code: code.trim(),
        used: false,
      },
      order: { createdAt: 'DESC' },
    });

    if (!resetTokenEntity) {
      return res.status(400).json({ success: false, message: 'Invalid or expired code' });
    }

    // Check if code is expired
    if (new Date() > resetTokenEntity.expiresAt) {
      return res.status(400).json({ success: false, message: 'Code has expired' });
    }

    // Return reset token (client will use this for reset-password)
    return res.json(successResponse({
      resetToken: resetTokenEntity.resetToken,
    }));
  } catch (error: any) {
    console.error('Error in verify-reset-code:', error);
    return res.status(500).json({ success: false, message: 'Failed to verify code' });
  }
});

router.post('/reset-password', async (req, res) => {
  try {
    const { resetToken, newPassword } = req.body;

    if (!resetToken || !newPassword) {
      return res.status(400).json({ success: false, message: 'Reset token and new password are required' });
    }

    // Validate password strength
    if (newPassword.length < 8) {
      return res.status(400).json({ success: false, message: 'Password must be at least 8 characters long' });
    }

    // Verify reset token
    let decoded: any;
    try {
      decoded = jwt.verify(resetToken, process.env.ADMIN_JWT_SECRET!);
      if (decoded.type !== 'password-reset') {
        return res.status(400).json({ success: false, message: 'Invalid reset token' });
      }
    } catch (error) {
      return res.status(400).json({ success: false, message: 'Invalid or expired reset token' });
    }

    const userRepository = AppDataSource.getRepository(User);
    const tokenRepository = AppDataSource.getRepository(PasswordResetToken);

    // Find user
    const user = await userRepository.findOne({
      where: { id: decoded.userId },
    });

    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    // Find and verify reset token entity
    const resetTokenEntity = await tokenRepository.findOne({
      where: {
        userId: user.id,
        resetToken,
        used: false,
      },
    });

    if (!resetTokenEntity) {
      return res.status(400).json({ success: false, message: 'Invalid or already used reset token' });
    }

    // Check if token is expired
    if (new Date() > resetTokenEntity.expiresAt) {
      return res.status(400).json({ success: false, message: 'Reset token has expired' });
    }

    // Hash new password
    const passwordHash = await bcrypt.hash(newPassword, 10);

    // Update user password
    user.passwordHash = passwordHash;
    await userRepository.save(user);

    // Mark reset token as used
    resetTokenEntity.used = true;
    await tokenRepository.save(resetTokenEntity);

    return res.json(successResponse(null, 'Password reset successfully'));
  } catch (error: any) {
    console.error('Error in reset-password:', error);
    return res.status(500).json({ success: false, message: 'Failed to reset password' });
  }
});

export default router;

