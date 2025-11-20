import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn } from 'typeorm';

@Entity('developers')
export class Developer {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ unique: true })
  name!: string;

  @Column({ nullable: true })
  logo!: string;

  @Column('jsonb', { nullable: true })
  description?: {
    en?: {
      description?: string;
    };
    ru?: {
      description?: string;
    };
    // Backward compatibility - old format as plain string
    description?: string;
  } | string;

  @Column('simple-array', { nullable: true })
  images?: string[]; // Масив URL фото

  @CreateDateColumn()
  createdAt!: Date;
}

