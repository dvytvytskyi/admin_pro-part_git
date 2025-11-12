FROM node:20-alpine AS builder

WORKDIR /app

# Копіюємо package files
COPY package*.json ./
COPY package-lock.json* ./

# Встановлюємо залежності
RUN npm ci

# Копіюємо вихідний код
COPY . .

# Додаємо мінімальні env змінні для build
# NEXT_PUBLIC_API_URL передається через build arg або .env.production
ARG NEXT_PUBLIC_API_URL=https://system.pro-part.online/api
ENV NEXT_PUBLIC_API_URL=${NEXT_PUBLIC_API_URL}
ENV NEXT_TELEMETRY_DISABLED=1

# Білдимо Next.js додаток
RUN npm run build

# Production образ
FROM node:20-alpine AS runner

WORKDIR /app

ENV NODE_ENV=production

# Створюємо non-root користувача
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# Копіюємо необхідні файли
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static
# Копіюємо public (папка повинна існувати в проекті, навіть якщо порожня)
COPY --from=builder --chown=nextjs:nodejs /app/public ./public

USER nextjs

EXPOSE 3001

ENV PORT=3001
ENV HOSTNAME="0.0.0.0"

CMD ["node", "server.js"]

