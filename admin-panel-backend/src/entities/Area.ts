import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, JoinColumn } from 'typeorm';
import { City } from './City';

@Entity('areas')
export class Area {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column()
  cityId!: string;

  @ManyToOne(() => City, city => city.areas)
  @JoinColumn({ name: 'cityId' })
  city!: City;

  @Column()
  nameEn!: string;

  @Column()
  nameRu!: string;

  @Column()
  nameAr!: string;

  @Column('jsonb', { nullable: true })
  description?: {
    title?: string;
    description?: string;
  };

  @Column('jsonb', { nullable: true })
  infrastructure?: {
    title?: string;
    description?: string;
  };

  @Column('simple-array', { nullable: true })
  images?: string[]; // Масив URL фото (до 8 штук, 3x4 або 4x3)
}

