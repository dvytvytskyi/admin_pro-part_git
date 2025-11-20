import { Entity, PrimaryGeneratedColumn, Column, OneToMany, CreateDateColumn, UpdateDateColumn } from 'typeorm';
import { ChatMessage } from './ChatMessage';

export enum ChatSessionStatus {
  ACTIVE = 'active',
  CLOSED = 'closed',
  ARCHIVED = 'archived',
}

@Entity('chat_sessions')
export class ChatSession {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column('varchar', { nullable: true })
  userName!: string | null;

  @Column('varchar', { nullable: true })
  userPhone!: string | null;

  @Column({
    type: 'enum',
    enum: ChatSessionStatus,
    default: ChatSessionStatus.ACTIVE,
  })
  status!: ChatSessionStatus;

  @Column('uuid', { nullable: true })
  managerId!: string | null; // ID менеджера, який займається чатом

  @Column('varchar', { nullable: true })
  userSessionId!: string | null; // ID сесії на клієнті (localStorage)

  @OneToMany(() => ChatMessage, message => message.session, { cascade: true })
  messages!: ChatMessage[];

  @CreateDateColumn()
  createdAt!: Date;

  @UpdateDateColumn()
  updatedAt!: Date;
}

