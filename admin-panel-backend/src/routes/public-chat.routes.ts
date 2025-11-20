import express from 'express';
import { AppDataSource } from '../config/database';
import { ChatSession, ChatSessionStatus } from '../entities/ChatSession';
import { ChatMessage, ChatMessageSender } from '../entities/ChatMessage';
import { authenticateApiKeyWithSecret, AuthRequest } from '../middleware/auth';
import { successResponse, errorResponse } from '../utils/response';
// Використовуємо fetch замість axios

const router = express.Router();

// Конфігурація Telegram
const TELEGRAM_BOT_TOKEN = process.env.TELEGRAM_BOT_TOKEN || '8363607929:AAHkTjaV21xrDrtIX9fEIGK107BZdIOmiAA';
const TELEGRAM_CHAT_ID = process.env.TELEGRAM_CHAT_ID || '-5034695946';
const TELEGRAM_API_URL = `https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage`;

// Функція для відправки в Telegram
async function sendToTelegram(name: string | null, phone: string | null, message: string, timestamp?: string) {
  try {
    let telegramMessage = '💬 *Нове повідомлення з чату*\n\n';
    
    if (name) {
      telegramMessage += `👤 *Ім\'я:* ${name}\n`;
    }
    
    if (phone) {
      telegramMessage += `📞 *Телефон:* ${phone}\n`;
    }
    
    telegramMessage += `\n💭 *Повідомлення:*\n${message}\n`;
    
    if (timestamp) {
      const date = new Date(timestamp);
      const formattedDate = date.toLocaleString('uk-UA', {
        day: '2-digit',
        month: '2-digit',
        year: 'numeric',
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit',
      });
      telegramMessage += `\n🕐 ${formattedDate}`;
    }

    const response = await fetch(TELEGRAM_API_URL, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        chat_id: TELEGRAM_CHAT_ID,
        text: telegramMessage,
        parse_mode: 'Markdown',
      }),
    });

    if (!response.ok) {
      const errorData = await response.json().catch(() => ({}));
      throw new Error(`Telegram API error: ${JSON.stringify(errorData)}`);
    }

    return await response.json();
  } catch (error: any) {
    console.error('Error sending to Telegram:', error.response?.data || error.message);
    throw error;
  }
}

// POST /api/public/chat/sessions - Створити сесію або отримати існуючу (для фронтенду)
router.post('/chat/sessions', authenticateApiKeyWithSecret, async (req: AuthRequest, res) => {
  try {
    const { name, phone, userSessionId, firstMessage } = req.body;

    // Перевіряємо, чи вже є активна сесія з цим userSessionId
    let session = await AppDataSource.getRepository(ChatSession).findOne({
      where: {
        userSessionId: userSessionId || null,
        status: ChatSessionStatus.ACTIVE,
      },
      order: { createdAt: 'DESC' },
    });

    if (!session) {
      // Створюємо нову сесію
      session = AppDataSource.getRepository(ChatSession).create({
        userName: name || null,
        userPhone: phone || null,
        status: ChatSessionStatus.ACTIVE,
        userSessionId: userSessionId || null,
      });

      session = await AppDataSource.getRepository(ChatSession).save(session);
    } else {
      // Оновлюємо дані користувача, якщо вони змінились
      if (name && !session.userName) {
        session.userName = name;
      }
      if (phone && !session.userPhone) {
        session.userPhone = phone;
      }
      session = await AppDataSource.getRepository(ChatSession).save(session);
    }

    // Якщо є перше повідомлення, додаємо його
    if (firstMessage) {
      const message = AppDataSource.getRepository(ChatMessage).create({
        sessionId: session.id,
        sender: ChatMessageSender.USER,
        messageText: firstMessage,
      });
      await AppDataSource.getRepository(ChatMessage).save(message);

      // Відправляємо в Telegram
      try {
        await sendToTelegram(
          session.userName || name || null,
          session.userPhone || phone || null,
          firstMessage,
          new Date().toISOString()
        );
      } catch (telegramError) {
        console.error('Failed to send to Telegram:', telegramError);
        // Продовжуємо роботу навіть якщо Telegram недоступний
      }
    }

    // Отримуємо всі повідомлення сесії
    const messages = await AppDataSource.getRepository(ChatMessage).find({
      where: { sessionId: session.id },
      order: { createdAt: 'ASC' },
    });

    res.json(successResponse({
      sessionId: session.id,
      session: {
        id: session.id,
        userName: session.userName,
        userPhone: session.userPhone,
        status: session.status,
        createdAt: session.createdAt,
      },
      messages: messages.map(msg => ({
        id: msg.id,
        sender: msg.sender,
        messageText: msg.messageText,
        createdAt: msg.createdAt,
      })),
    }));
  } catch (error: any) {
    console.error('Error creating chat session:', error);
    res.status(500).json(errorResponse('Failed to create chat session', error.message));
  }
});

// POST /api/public/chat/sessions/:id/messages - Відправити повідомлення від користувача (для фронтенду)
router.post('/chat/sessions/:id/messages', authenticateApiKeyWithSecret, async (req: AuthRequest, res) => {
  try {
    const { id } = req.params;
    const { message } = req.body;

    if (!message || typeof message !== 'string') {
      return res.status(400).json(errorResponse('Message text is required'));
    }

    const session = await AppDataSource.getRepository(ChatSession).findOne({
      where: { id },
    });

    if (!session) {
      return res.status(404).json(errorResponse('Chat session not found'));
    }

    if (session.status === ChatSessionStatus.CLOSED || session.status === ChatSessionStatus.ARCHIVED) {
      return res.status(400).json(errorResponse('Cannot send message to closed or archived session'));
    }

    // Створюємо повідомлення
    const chatMessage = AppDataSource.getRepository(ChatMessage).create({
      sessionId: session.id,
      sender: ChatMessageSender.USER,
      messageText: message,
    });

    const savedMessage = await AppDataSource.getRepository(ChatMessage).save(chatMessage);

    // Оновлюємо updatedAt сесії
    session.updatedAt = new Date();
    await AppDataSource.getRepository(ChatSession).save(session);

    // Відправляємо в Telegram
    try {
      await sendToTelegram(
        session.userName,
        session.userPhone,
        message,
        savedMessage.createdAt.toISOString()
      );
    } catch (telegramError) {
      console.error('Failed to send to Telegram:', telegramError);
      // Продовжуємо роботу навіть якщо Telegram недоступний
    }

    res.json(successResponse({
      message: {
        id: savedMessage.id,
        sender: savedMessage.sender,
        messageText: savedMessage.messageText,
        createdAt: savedMessage.createdAt,
      },
    }));
  } catch (error: any) {
    console.error('Error sending message:', error);
    res.status(500).json(errorResponse('Failed to send message', error.message));
  }
});

// GET /api/public/chat/sessions/:id/messages - Отримати повідомлення сесії (для фронтенду з polling)
router.get('/chat/sessions/:id/messages', authenticateApiKeyWithSecret, async (req: AuthRequest, res) => {
  try {
    const { id } = req.params;
    const { since } = req.query; // ISO timestamp для отримання тільки нових повідомлень

    const session = await AppDataSource.getRepository(ChatSession).findOne({
      where: { id },
    });

    if (!session) {
      return res.status(404).json(errorResponse('Chat session not found'));
    }

    let queryBuilder = AppDataSource.getRepository(ChatMessage)
      .createQueryBuilder('message')
      .where('message.sessionId = :sessionId', { sessionId: id })
      .orderBy('message.createdAt', 'ASC');

    // Якщо є параметр since, отримуємо тільки нові повідомлення
    if (since && typeof since === 'string') {
      try {
        const sinceDate = new Date(since);
        queryBuilder.andWhere('message.createdAt > :since', { since: sinceDate });
      } catch (e) {
        // Ігноруємо помилку парсингу дати
      }
    }

    const messages = await queryBuilder.getMany();

    res.json(successResponse({
      messages: messages.map(msg => ({
        id: msg.id,
        sender: msg.sender,
        messageText: msg.messageText,
        createdAt: msg.createdAt,
      })),
    }));
  } catch (error: any) {
    console.error('Error fetching messages:', error);
    res.status(500).json(errorResponse('Failed to fetch messages', error.message));
  }
});

// POST /api/public/chat/notify - Legacy endpoint для telegram-notify (зберігає в БД)
router.post('/chat/notify', authenticateApiKeyWithSecret, async (req: AuthRequest, res) => {
  try {
    const { name, phone, message, timestamp } = req.body;

    if (!message || typeof message !== 'string') {
      return res.status(400).json(errorResponse('Message text is required'));
    }

    // Шукаємо активну сесію за телефоном або ім'ям
    let session = await AppDataSource.getRepository(ChatSession).findOne({
      where: [
        { userPhone: phone || null, status: ChatSessionStatus.ACTIVE },
        { userName: name || null, status: ChatSessionStatus.ACTIVE },
      ],
      order: { createdAt: 'DESC' },
    });

    // Якщо немає сесії, створюємо нову
    if (!session) {
      session = AppDataSource.getRepository(ChatSession).create({
        userName: name || null,
        userPhone: phone || null,
        status: ChatSessionStatus.ACTIVE,
      });
      session = await AppDataSource.getRepository(ChatSession).save(session);
    } else {
      // Оновлюємо дані, якщо вони змінились
      if (name && !session.userName) {
        session.userName = name;
      }
      if (phone && !session.userPhone) {
        session.userPhone = phone;
      }
      session = await AppDataSource.getRepository(ChatSession).save(session);
    }

    // Додаємо повідомлення
    const chatMessage = AppDataSource.getRepository(ChatMessage).create({
      sessionId: session.id,
      sender: ChatMessageSender.USER,
      messageText: message,
    });

    await AppDataSource.getRepository(ChatMessage).save(chatMessage);

    // Оновлюємо updatedAt сесії
    session.updatedAt = new Date();
    await AppDataSource.getRepository(ChatSession).save(session);

    // Відправляємо в Telegram
    try {
      await sendToTelegram(
        session.userName,
        session.userPhone,
        message,
        timestamp || new Date().toISOString()
      );
    } catch (telegramError) {
      console.error('Failed to send to Telegram:', telegramError);
      // Продовжуємо роботу навіть якщо Telegram недоступний
    }

    res.json(successResponse({ success: true, sessionId: session.id }));
  } catch (error: any) {
    console.error('Error in chat notify:', error);
    res.status(500).json(errorResponse('Failed to process chat notification', error.message));
  }
});

export default router;

