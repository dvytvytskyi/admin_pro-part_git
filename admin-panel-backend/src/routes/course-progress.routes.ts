import express from 'express';
import { AppDataSource } from '../config/database';
import { CourseProgress } from '../entities/CourseProgress';
import { Course } from '../entities/Course';
import { User } from '../entities/User';
import { authenticateJWT, authenticateAPIKey } from '../middleware/auth';
import { successResponse } from '../utils/response';

const router = express.Router();

router.use((req, res, next) => {
  const apiKey = req.headers['x-api-key'];
  if (apiKey) return authenticateAPIKey(req, res, next);
  return authenticateJWT(req, res, next);
});

// GET /api/course-progress/:userId - Get all progress for a user
router.get('/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    
    const progressList = await AppDataSource.getRepository(CourseProgress).find({
      where: { userId },
      relations: ['course'],
      order: { lastAccessedAt: 'DESC', createdAt: 'DESC' },
    });

    res.json(successResponse(progressList));
  } catch (error: any) {
    console.error('Error fetching course progress:', error);
    res.status(500).json({ success: false, message: error.message || 'Failed to fetch course progress' });
  }
});

// GET /api/course-progress/:userId/:courseId - Get progress for specific course
router.get('/:userId/:courseId', async (req, res) => {
  try {
    const { userId, courseId } = req.params;
    
    let progress = await AppDataSource.getRepository(CourseProgress).findOne({
      where: { userId, courseId },
      relations: ['course'],
    });

    // If no progress exists, create default
    if (!progress) {
      progress = AppDataSource.getRepository(CourseProgress).create({
        userId,
        courseId,
        completedContentIds: [],
        completedLinkIds: [],
        isCompleted: false,
        progressPercentage: 0,
      });
      await AppDataSource.getRepository(CourseProgress).save(progress);
      
      // Reload with relations
      progress = await AppDataSource.getRepository(CourseProgress).findOne({
        where: { id: progress.id },
        relations: ['course'],
      });
    }

    res.json(successResponse(progress));
  } catch (error: any) {
    console.error('Error fetching course progress:', error);
    res.status(500).json({ success: false, message: error.message || 'Failed to fetch course progress' });
  }
});

// POST /api/course-progress - Update progress (mark content/link as completed)
router.post('/', async (req, res) => {
  try {
    const { userId, courseId, contentId, linkId } = req.body;

    if (!userId || !courseId) {
      return res.status(400).json({ success: false, message: 'userId and courseId are required' });
    }

    // Verify user exists
    const user = await AppDataSource.getRepository(User).findOne({
      where: { id: userId },
    });

    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    // Verify course exists and get its contents/links
    const course = await AppDataSource.getRepository(Course).findOne({
      where: { id: courseId },
      relations: ['contents', 'links'],
    });

    if (!course) {
      return res.status(404).json({ success: false, message: 'Course not found' });
    }

    // Find or create progress
    let progress = await AppDataSource.getRepository(CourseProgress).findOne({
      where: { userId, courseId },
    });

    if (!progress) {
      progress = AppDataSource.getRepository(CourseProgress).create({
        userId,
        courseId,
        completedContentIds: [],
        completedLinkIds: [],
        isCompleted: false,
        progressPercentage: 0,
        lastAccessedAt: new Date(),
      });
    } else {
      progress.lastAccessedAt = new Date();
    }

    // Update completed content/link
    if (contentId) {
      const contentIds = progress.completedContentIds || [];
      if (!contentIds.includes(contentId)) {
        contentIds.push(contentId);
        progress.completedContentIds = contentIds;
      }
    }

    if (linkId) {
      const linkIds = progress.completedLinkIds || [];
      if (!linkIds.includes(linkId)) {
        linkIds.push(linkId);
        progress.completedLinkIds = linkIds;
      }
    }

    // Calculate progress percentage
    const totalItems = (course.contents?.length || 0) + (course.links?.length || 0);
    const completedItems = (progress.completedContentIds?.length || 0) + (progress.completedLinkIds?.length || 0);
    
    if (totalItems > 0) {
      progress.progressPercentage = Math.round((completedItems / totalItems) * 100);
    }

    // Check if course is completed
    if (progress.progressPercentage === 100 && !progress.isCompleted) {
      progress.isCompleted = true;
      progress.completedAt = new Date();
    }

    await AppDataSource.getRepository(CourseProgress).save(progress);

    // Return updated progress with course data
    const updatedProgress = await AppDataSource.getRepository(CourseProgress).findOne({
      where: { id: progress.id },
      relations: ['course'],
    });

    res.json(successResponse(updatedProgress));
  } catch (error: any) {
    console.error('Error updating course progress:', error);
    res.status(500).json({ success: false, message: error.message || 'Failed to update course progress' });
  }
});

// PUT /api/course-progress/:userId/:courseId - Bulk update progress
router.put('/:userId/:courseId', async (req, res) => {
  try {
    const { userId, courseId } = req.params;
    const { completedContentIds, completedLinkIds } = req.body;

    // Verify user and course exist
    const user = await AppDataSource.getRepository(User).findOne({
      where: { id: userId },
    });

    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    const course = await AppDataSource.getRepository(Course).findOne({
      where: { id: courseId },
      relations: ['contents', 'links'],
    });

    if (!course) {
      return res.status(404).json({ success: false, message: 'Course not found' });
    }

    // Find or create progress
    let progress = await AppDataSource.getRepository(CourseProgress).findOne({
      where: { userId, courseId },
    });

    if (!progress) {
      progress = AppDataSource.getRepository(CourseProgress).create({
        userId,
        courseId,
        completedContentIds: completedContentIds || [],
        completedLinkIds: completedLinkIds || [],
        isCompleted: false,
        progressPercentage: 0,
        lastAccessedAt: new Date(),
      });
    } else {
      if (completedContentIds !== undefined) {
        progress.completedContentIds = completedContentIds;
      }
      if (completedLinkIds !== undefined) {
        progress.completedLinkIds = completedLinkIds;
      }
      progress.lastAccessedAt = new Date();
    }

    // Calculate progress percentage
    const totalItems = (course.contents?.length || 0) + (course.links?.length || 0);
    const completedItems = (progress.completedContentIds?.length || 0) + (progress.completedLinkIds?.length || 0);
    
    if (totalItems > 0) {
      progress.progressPercentage = Math.round((completedItems / totalItems) * 100);
    }

    // Check if course is completed
    if (progress.progressPercentage === 100 && !progress.isCompleted) {
      progress.isCompleted = true;
      progress.completedAt = new Date();
    }

    await AppDataSource.getRepository(CourseProgress).save(progress);

    // Return updated progress
    const updatedProgress = await AppDataSource.getRepository(CourseProgress).findOne({
      where: { id: progress.id },
      relations: ['course'],
    });

    res.json(successResponse(updatedProgress));
  } catch (error: any) {
    console.error('Error updating course progress:', error);
    res.status(500).json({ success: false, message: error.message || 'Failed to update course progress' });
  }
});

export default router;

