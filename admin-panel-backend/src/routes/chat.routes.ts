import express from 'express';
import { AppDataSource } from '../config/database';
import { ChatSession, ChatSessionStatus } from '../entities/ChatSession';
import { ChatMessage, ChatMessageSender } from '../entities/ChatMessage';
import { authenticateJWT } from '../middleware/auth';
import { successResponse, errorResponse } from '../utils/response';

const router = express.Router();

// Всі роути потребують автентифікації
router.use(authenticateJWT);

// GET /api/chat/sessions - Отримати список сесій
router.get('/sessions', async (req, res) => {
  try {
    const { status, page = '1', limit = '20', search } = req.query;
    
    const pageNum = parseInt(page.toString(), 10);
    const limitNum = parseInt(limit.toString(), 10);
    const skip = (pageNum - 1) * limitNum;

    const queryBuilder = AppDataSource.getRepository(ChatSession)
      .createQueryBuilder('session')
      .leftJoinAndSelect('session.messages', 'messages')
      .orderBy('session.updatedAt', 'DESC');

    if (status && typeof status === 'string') {
      queryBuilder.andWhere('session.status = :status', { status });
    }

    if (search && typeof search === 'string') {
      queryBuilder.andWhere(
        '(session.userName ILIKE :search OR session.userPhone ILIKE :search)',
        { search: `%${search}%` }
      );
    }

    const total = await queryBuilder.getCount();
    const sessions = await queryBuilder
      .skip(skip)
      .take(limitNum)
      .getMany();

    // Отримуємо останнє повідомлення для кожної сесії
    const sessionsWithLastMessage = await Promise.all(
      sessions.map(async (session) => {
        const lastMessage = await AppDataSource.getRepository(ChatMessage)
          .findOne({
            where: { sessionId: session.id },
            order: { createdAt: 'DESC' },
          });

        const unreadCount = await AppDataSource.getRepository(ChatMessage)
          .count({
            where: {
              sessionId: session.id,
              sender: ChatMessageSender.USER,
            },
          });

        return {
          id: session.id,
          userName: session.userName,
          userPhone: session.userPhone,
          status: session.status,
          managerId: session.managerId,
          userSessionId: session.userSessionId,
          lastMessage: lastMessage ? {
            id: lastMessage.id,
            text: lastMessage.messageText,
            sender: lastMessage.sender,
            createdAt: lastMessage.createdAt,
          } : null,
          unreadCount,
          messageCount: session.messages?.length || 0,
          createdAt: session.createdAt,
          updatedAt: session.updatedAt,
        };
      })
    );

    res.json(successResponse({
      sessions: sessionsWithLastMessage,
      pagination: {
        total,
        page: pageNum,
        limit: limitNum,
        totalPages: Math.ceil(total / limitNum),
      },
    }));
  } catch (error: any) {
    console.error('Error fetching chat sessions:', error);
    res.status(500).json(errorResponse('Failed to fetch chat sessions', error.message));
  }
});

// GET /api/chat/sessions/:id - Отримати конкретну сесію з повідомленнями
router.get('/sessions/:id', async (req, res) => {
  try {
    const { id } = req.params;

    const session = await AppDataSource.getRepository(ChatSession).findOne({
      where: { id },
      relations: ['messages'],
    });

    if (!session) {
      return res.status(404).json(errorResponse('Chat session not found'));
    }

    // Сортуємо повідомлення по даті
    const messages = (session.messages || []).sort((a, b) => 
      a.createdAt.getTime() - b.createdAt.getTime()
    );

    res.json(successResponse({
      session: {
        id: session.id,
        userName: session.userName,
        userPhone: session.userPhone,
        status: session.status,
        managerId: session.managerId,
        userSessionId: session.userSessionId,
        createdAt: session.createdAt,
        updatedAt: session.updatedAt,
      },
      messages: messages.map(msg => ({
        id: msg.id,
        sender: msg.sender,
        messageText: msg.messageText,
        managerId: msg.managerId,
        createdAt: msg.createdAt,
      })),
    }));
  } catch (error: any) {
    console.error('Error fetching chat session:', error);
    res.status(500).json(errorResponse('Failed to fetch chat session', error.message));
  }
});

// POST /api/chat/sessions - Створити нову сесію (використовується з фронтенду)
router.post('/sessions', async (req, res) => {
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

// POST /api/chat/sessions/:id/messages - Відправити повідомлення
router.post('/sessions/:id/messages', async (req, res) => {
  try {
    const { id } = req.params;
    const { message, sender = ChatMessageSender.USER, managerId = null } = req.body;

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

    // Якщо повідомлення від менеджера, оновлюємо managerId в сесії
    if (sender === ChatMessageSender.MANAGER && managerId) {
      session.managerId = managerId;
      await AppDataSource.getRepository(ChatSession).save(session);
    }

    const chatMessage = AppDataSource.getRepository(ChatMessage).create({
      sessionId: session.id,
      sender: sender as ChatMessageSender,
      messageText: message,
      managerId: sender === ChatMessageSender.MANAGER ? managerId : null,
    });

    const savedMessage = await AppDataSource.getRepository(ChatMessage).save(chatMessage);

    // Оновлюємо updatedAt сесії
    session.updatedAt = new Date();
    await AppDataSource.getRepository(ChatSession).save(session);

    res.json(successResponse({
      message: {
        id: savedMessage.id,
        sender: savedMessage.sender,
        messageText: savedMessage.messageText,
        managerId: savedMessage.managerId,
        createdAt: savedMessage.createdAt,
      },
    }));
  } catch (error: any) {
    console.error('Error sending message:', error);
    res.status(500).json(errorResponse('Failed to send message', error.message));
  }
});

// POST /api/chat/sessions/:id/close - Закрити сесію
router.post('/sessions/:id/close', async (req, res) => {
  try {
    const { id } = req.params;

    const session = await AppDataSource.getRepository(ChatSession).findOne({
      where: { id },
    });

    if (!session) {
      return res.status(404).json(errorResponse('Chat session not found'));
    }

    session.status = ChatSessionStatus.CLOSED;
    await AppDataSource.getRepository(ChatSession).save(session);

    res.json(successResponse({ success: true }));
  } catch (error: any) {
    console.error('Error closing chat session:', error);
    res.status(500).json(errorResponse('Failed to close chat session', error.message));
  }
});

// POST /api/chat/sessions/:id/assign - Призначити менеджера на сесію
router.post('/sessions/:id/assign', async (req, res) => {
  try {
    const { id } = req.params;
    const { managerId } = req.body;

    const session = await AppDataSource.getRepository(ChatSession).findOne({
      where: { id },
    });

    if (!session) {
      return res.status(404).json(errorResponse('Chat session not found'));
    }

    session.managerId = managerId || null;
    await AppDataSource.getRepository(ChatSession).save(session);

    res.json(successResponse({ success: true }));
  } catch (error: any) {
    console.error('Error assigning manager:', error);
    res.status(500).json(errorResponse('Failed to assign manager', error.message));
  }
});

// GET /api/chat/sessions/:id/messages - Отримати повідомлення сесії (з опцією since)
router.get('/sessions/:id/messages', async (req, res) => {
  try {
    const { id } = req.params;
    const { since } = req.query;

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
        managerId: msg.managerId,
        createdAt: msg.createdAt,
      })),
    }));
  } catch (error: any) {
    console.error('Error fetching messages:', error);
    res.status(500).json(errorResponse('Failed to fetch messages', error.message));
  }
});

// GET /api/chat/stats - Статистика чатів
router.get('/stats', async (req, res) => {
  try {
    const activeCount = await AppDataSource.getRepository(ChatSession).count({
      where: { status: ChatSessionStatus.ACTIVE },
    });

    const closedCount = await AppDataSource.getRepository(ChatSession).count({
      where: { status: ChatSessionStatus.CLOSED },
    });

    const totalMessages = await AppDataSource.getRepository(ChatMessage).count();

    const unreadSessions = await AppDataSource.getRepository(ChatMessage)
      .createQueryBuilder('message')
      .select('DISTINCT message.sessionId', 'sessionId')
      .where('message.sender = :sender', { sender: ChatMessageSender.USER })
      .getRawMany();

    res.json(successResponse({
      activeSessions: activeCount,
      closedSessions: closedCount,
      totalMessages,
      unreadSessions: unreadSessions.length,
    }));
  } catch (error: any) {
    console.error('Error fetching chat stats:', error);
    res.status(500).json(errorResponse('Failed to fetch chat stats', error.message));
  }
});

export default router;

