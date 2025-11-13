import axios from 'axios'
import { redirectToLogin } from '@/utils/redirect'

const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:4000/api'

export const api = axios.create({
  baseURL: API_URL,
  headers: {
    'Content-Type': 'application/json',
  },
})

// Request interceptor для додавання JWT токену
api.interceptors.request.use(
  (config) => {
    const token = typeof window !== 'undefined' ? localStorage.getItem('token') : null
    if (token) {
      // Перевіряємо, чи токен не порожній і не містить зайвих пробілів
      const cleanToken = token.trim()
      if (cleanToken) {
        config.headers.Authorization = `Bearer ${cleanToken}`
        // Діагностичне логування (тільки для розробки)
        if (process.env.NODE_ENV === 'development') {
          console.log('🔑 Token added to request:', cleanToken.substring(0, 20) + '...')
        }
      } else {
        console.warn('⚠️ Empty token found in localStorage')
      }
    } else {
      console.warn('⚠️ No token found in localStorage')
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
    // Redirect to login for both 401 and 403 (unauthorized/forbidden)
    if (error.response?.status === 401 || error.response?.status === 403) {
      // Don't redirect if we're already on login page
      if (typeof window !== 'undefined' && !window.location.pathname.includes('/login')) {
        console.warn('Authentication required, redirecting to login...');
        redirectToLogin();
      }
    }
    return Promise.reject(error)
  }
)

