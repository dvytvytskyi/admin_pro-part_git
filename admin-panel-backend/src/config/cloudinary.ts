import { v2 as cloudinary } from 'cloudinary';
import dotenv from 'dotenv';

dotenv.config();

// Support both CLOUDINARY_URL and individual env variables
if (process.env.CLOUDINARY_URL) {
  // Parse CLOUDINARY_URL format: cloudinary://api_key:api_secret@cloud_name
  cloudinary.config();
} else {
  cloudinary.config({
    cloud_name: process.env.CLOUDINARY_CLOUD_NAME || 'dgv0rxd60',
    api_key: process.env.CLOUDINARY_API_KEY || '141613625537469',
    api_secret: process.env.CLOUDINARY_API_SECRET || 'GgziMAcVfQvOGD44Yj0OlNqitPg',
  });
}

export default cloudinary;

