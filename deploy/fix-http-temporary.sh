#!/bin/bash

# Тимчасове виправлення - використання HTTP замість HTTPS

set -e

echo "🔧 Тимчасове виправлення - HTTP замість HTTPS..."
echo ""

# Оновлюємо next.config.js щоб використовувати HTTP
cat > /opt/admin-pro-part/admin-panel/next.config.js << 'EOF'
/** @type {import('next').NextConfig} */
const nextConfig = {
  output: 'standalone',
  images: {
    domains: ['example.com'],
    remotePatterns: [
      {
        protocol: 'https',
        hostname: '**',
      },
      {
        protocol: 'http',
        hostname: '**',
      },
    ],
  },
  env: {
    NEXT_PUBLIC_API_URL: process.env.NEXT_PUBLIC_API_URL || (
      process.env.NODE_ENV === 'production' 
        ? 'http://system.pro-part.online/api'
        : 'http://localhost:4000/api'
    ),
  },
  webpack(config) {
    config.module.rules.push({
      test: /\.svg$/,
      use: ["@svgr/webpack"],
    });
    return config;
  },
}

module.exports = nextConfig
EOF

# Оновлюємо api.ts щоб використовувати HTTP
cat > /opt/admin-pro-part/admin-panel/src/lib/api.ts << 'EOF'
import axios from 'axios'

// Використовуємо HTTP для production (тимчасово, поки не налаштовано SSL)
const getApiUrl = () => {
  if (typeof window !== 'undefined') {
    const origin = window.location.origin
    // Якщо це pro-part домен, використовуємо HTTP
    if (origin.includes('pro-part.online')) {
      return origin.replace('https://', 'http://') + '/api'
    }
  }
  return process.env.NEXT_PUBLIC_API_URL || 'http://localhost:4000/api'
}

export const api = axios.create({
  baseURL: getApiUrl(),
  headers: {
    'Content-Type': 'application/json',
  },
})

// Request interceptor для додавання JWT токену
api.interceptors.request.use(
  (config) => {
    const apiUrl = getApiUrl()
    config.baseURL = apiUrl
    
    const token = typeof window !== 'undefined' ? localStorage.getItem('token') : null
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
    }
    return config
  },
  (error) => {
    return Promise.reject(error)
  }
)

// Response interceptor для обробки помилок
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401 || error.response?.status === 403) {
      if (typeof window !== 'undefined' && !window.location.pathname.includes('/login')) {
        console.warn('Authentication required, redirecting to login...');
        window.location.href = '/login'
      }
    }
    return Promise.reject(error)
  }
)
EOF

# Перебудовуємо фронтенд
echo "🔨 Перебудова фронтенду..."
cd /opt/admin-pro-part
docker-compose -f docker-compose.prod.yml build admin-panel-frontend
docker-compose -f docker-compose.prod.yml up -d admin-panel-frontend

echo ""
echo "✅ Готово! Тепер використовується HTTP"
echo "🌐 Перевірте: http://system.pro-part.online"

