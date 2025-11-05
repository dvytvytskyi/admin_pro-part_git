import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, JoinColumn, CreateDateColumn } from 'typeorm';
import { User } from './User';

@Entity('password_reset_tokens')
export class PasswordResetToken {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column('uuid')
  userId!: string;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'userId' })
  user!: User;

  @Column()
  code!: string; // 6-digit code

  @Column()
  resetToken!: string; // JWT token for password reset

  @Column({ default: false })
  used!: boolean; // Whether the code has been used

  @Column('timestamptz')
  expiresAt!: Date; // Expiration time (15 minutes from creation)

  @CreateDateColumn()
  createdAt!: Date;
}

