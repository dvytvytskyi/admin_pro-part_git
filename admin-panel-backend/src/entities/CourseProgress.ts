import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, JoinColumn, CreateDateColumn, UpdateDateColumn, Unique } from 'typeorm';
import { User } from './User';
import { Course } from './Course';

@Entity('course_progress')
@Unique(['userId', 'courseId'])
export class CourseProgress {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column('uuid')
  userId!: string;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'userId' })
  user!: User;

  @Column('uuid')
  courseId!: string;

  @ManyToOne(() => Course, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'courseId' })
  course!: Course;

  @Column('simple-array', { nullable: true })
  completedContentIds?: string[]; // Array of CourseContent IDs that user has completed

  @Column('simple-array', { nullable: true })
  completedLinkIds?: string[]; // Array of CourseLink IDs that user has clicked/viewed

  @Column({ default: false })
  isCompleted!: boolean; // Whether the entire course is completed

  @Column('int', { default: 0 })
  progressPercentage!: number; // 0-100

  @Column('timestamptz', { nullable: true })
  completedAt?: Date; // When course was fully completed

  @Column('timestamptz', { nullable: true })
  lastAccessedAt?: Date; // Last time user accessed this course

  @CreateDateColumn()
  createdAt!: Date;

  @UpdateDateColumn()
  updatedAt!: Date;
}

