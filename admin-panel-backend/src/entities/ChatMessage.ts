import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, JoinColumn, CreateDateColumn } from 'typeorm';
import { ChatSession } from './ChatSession';

export enum ChatMessageSender {
  USER = 'user',
  MANAGER = 'manager',
}

@Entity('chat_messages')
export class ChatMessage {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column('uuid')
  sessionId!: string;

  @ManyToOne(() => ChatSession, session => session.messages, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'sessionId' })
  session!: ChatSession;

  @Column({
    type: 'enum',
    enum: ChatMessageSender,
  })
  sender!: ChatMessageSender;

  @Column('text')
  messageText!: string;

  @Column('uuid', { nullable: true })
  managerId!: string | null; // ID менеджера, якщо повідомлення від менеджера

  @CreateDateColumn()
  createdAt!: Date;
}

