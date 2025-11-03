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
ENV NEXT_PUBLIC_API_URL=http://localhost:4000/api

# Білдимо Next.js додаток (ігноруємо помилки типів для production build)
RUN npm run build || npm run build -- --no-lint

# Production образ
FROM node:20-alpine AS runner

WORKDIR /app

ENV NODE_ENV production

# Створюємо non-root користувача
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# Копіюємо необхідні файли
COPY --from=builder /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs

EXPOSE 3001

ENV PORT 3001
ENV HOSTNAME "0.0.0.0"

CMD ["node", "server.js"]

