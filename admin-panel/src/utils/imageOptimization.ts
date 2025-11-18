/**
 * Утиліта для оптимізації URL зображень
 * Працює з різними джерелами: Cloudinary, api.reelly.io, files.alnair.ae
 */

/**
 * Отримує оптимізований URL для thumbnail (48x48px для списку properties)
 * Для Cloudinary - додає transformations через URL
 * Для інших джерел - повертає оригінал (Next.js Image оптимізує автоматично)
 */
export const getThumbnailUrl = (
  url: string | undefined | null,
  size = 48
): string | null => {
  if (!url) return null;

  // Для Cloudinary - додаємо transformations для швидкої оптимізації на CDN
  if (url.includes('res.cloudinary.com')) {
    const parts = url.split('/upload/');
    if (parts.length === 2) {
      // Cloudinary зробить resize на своєму CDN
      return `${parts[0]}/upload/w_${size},h_${size},c_fill,q_auto,f_auto/${parts[1]}`;
    }
  }

  // Для api.reelly.io та files.alnair.ae - повертаємо як є
  // Next.js Image Optimization автоматично оптимізує через Image Optimization API
  // Він зробить resize до потрібного розміру та оптимізує формат (WebP/AVIF)
  return url;
};

/**
 * Отримує оптимізований URL з конкретними розмірами
 */
export const getOptimizedImageUrl = (
  url: string | undefined | null,
  width: number,
  height?: number
): string | null => {
  if (!url) return null;

  // Cloudinary transformations
  if (url.includes('res.cloudinary.com')) {
    const parts = url.split('/upload/');
    if (parts.length === 2) {
      const heightParam = height ? `,h_${height}` : '';
      return `${parts[0]}/upload/w_${width}${heightParam},q_auto,f_auto/${parts[1]}`;
    }
  }

  // Для інших джерел - повертаємо оригінал
  // Next.js Image оптимізує автоматично
  return url;
};

