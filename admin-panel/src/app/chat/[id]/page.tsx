'use client'
import { useState, useEffect, useRef } from 'react'
import { useRouter, useParams } from 'next/navigation'
import { api } from '@/lib/api'

interface ChatMessage {
  id: string
  sender: 'user' | 'manager'
  messageText: string
  managerId: string | null
  createdAt: string
}

interface ChatSession {
  id: string
  userName: string | null
  userPhone: string | null
  status: 'active' | 'closed' | 'archived'
  managerId: string | null
  createdAt: string
  updatedAt: string
}

export default function ChatDetailPage() {
  const router = useRouter()
  const params = useParams()
  const sessionId = params.id as string
  const messagesEndRef = useRef<HTMLDivElement>(null)

  const [session, setSession] = useState<ChatSession | null>(null)
  const [messages, setMessages] = useState<ChatMessage[]>([])
  const [loading, setLoading] = useState(true)
  const [sending, setSending] = useState(false)
  const [newMessage, setNewMessage] = useState('')
  const [lastPollTime, setLastPollTime] = useState<Date>(new Date())

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' })
  }

  const loadSession = async () => {
    try {
      setLoading(true)
      const response = await api.get(`/chat/sessions/${sessionId}`)
      console.log('Chat session response:', response.data)
      
      // Handle API response structure
      const data = response.data?.data || response.data
      if (data?.session) {
        setSession(data.session)
        setMessages(data.messages || [])
      } else if (response.data?.success && response.data?.data) {
        setSession(response.data.data.session)
        setMessages(response.data.data.messages || [])
      }
    } catch (error) {
      console.error('Error loading chat session:', error)
    } finally {
      setLoading(false)
    }
  }

  const loadNewMessages = async () => {
    try {
      const response = await api.get(`/chat/sessions/${sessionId}/messages?since=${lastPollTime.toISOString()}`)
      
      // Handle API response structure
      const data = response.data?.data || response.data
      const messages = data?.messages || []
      
      if (messages.length > 0) {
        setMessages(prev => {
          const existingIds = new Set(prev.map(m => m.id))
          const newMessages = messages.filter((m: ChatMessage) => !existingIds.has(m.id))
          if (newMessages.length > 0) {
            setLastPollTime(new Date())
            return [...prev, ...newMessages].sort((a, b) => 
              new Date(a.createdAt).getTime() - new Date(b.createdAt).getTime()
            )
          }
          return prev
        })
        scrollToBottom()
      }
    } catch (error) {
      console.error('Error loading new messages:', error)
    }
  }

  const sendMessage = async () => {
    if (!newMessage.trim() || sending) return

    try {
      setSending(true)
      const response = await api.post(`/chat/sessions/${sessionId}/messages`, {
        message: newMessage,
        sender: 'manager',
        managerId: localStorage.getItem('userId') || null,
      })

      console.log('Send message response:', response.data)
      
      // Handle API response structure
      const data = response.data?.data || response.data
      const message = data?.message || data
      
      if (message) {
        setMessages(prev => [...prev, message])
        setNewMessage('')
        setLastPollTime(new Date())
        scrollToBottom()
      }
    } catch (error) {
      console.error('Error sending message:', error)
    } finally {
      setSending(false)
    }
  }

  const closeSession = async () => {
    if (!confirm('Close this chat session?')) return

    try {
      await api.post(`/chat/sessions/${sessionId}/close`)
      router.push('/chat')
    } catch (error) {
      console.error('Error closing session:', error)
    }
  }

  useEffect(() => {
    loadSession()
    setLastPollTime(new Date())
  }, [sessionId])

  useEffect(() => {
    scrollToBottom()
  }, [messages])

  useEffect(() => {
    // Polling для нових повідомлень кожні 2 секунди
    const interval = setInterval(() => {
      loadNewMessages()
    }, 2000)

    return () => clearInterval(interval)
  }, [sessionId, lastPollTime])

  const formatTime = (dateString: string) => {
    const date = new Date(dateString)
    return date.toLocaleTimeString('uk-UA', { hour: '2-digit', minute: '2-digit' })
  }

  const formatDate = (dateString: string) => {
    const date = new Date(dateString)
    const now = new Date()
    const isToday = date.toDateString() === now.toDateString()
    
    if (isToday) {
      return `Today, ${formatTime(dateString)}`
    }
    
    const yesterday = new Date(now)
    yesterday.setDate(yesterday.getDate() - 1)
    if (date.toDateString() === yesterday.toDateString()) {
      return `Yesterday, ${formatTime(dateString)}`
    }
    
    return date.toLocaleDateString('uk-UA') + ', ' + formatTime(dateString)
  }

  if (loading) {
    return <div className="text-center py-8">Loading...</div>
  }

  if (!session) {
    return <div className="text-center py-8">Chat session not found</div>
  }

  return (
    <div className="flex flex-col h-[calc(100vh-200px)]">
      {/* Header */}
      <div className="bg-white dark:bg-gray-800 p-4 border-b border-gray-200 dark:border-gray-700 flex items-center justify-between">
        <div>
          <h2 className="text-xl font-semibold text-gray-800 dark:text-white">
            {session.userName || 'Anonymous'}
          </h2>
          <p className="text-sm text-gray-500 dark:text-gray-400">
            {session.userPhone || 'No phone'}
          </p>
        </div>
        <div className="flex gap-2">
          <button
            onClick={() => router.push('/chat')}
            className="px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg"
          >
            Back
          </button>
          {session.status === 'active' && (
            <button
              onClick={closeSession}
              className="px-4 py-2 bg-red-500 text-white rounded-lg hover:bg-red-600"
            >
              Close Session
            </button>
          )}
        </div>
      </div>

      {/* Messages */}
      <div className="flex-1 overflow-y-auto p-4 space-y-4 bg-gray-50 dark:bg-gray-900">
        {messages.map((message) => (
          <div
            key={message.id}
            className={`flex ${
              message.sender === 'manager' ? 'justify-end' : 'justify-start'
            }`}
          >
            <div
              className={`max-w-md px-4 py-2 rounded-lg ${
                message.sender === 'manager'
                  ? 'bg-blue-500 text-white'
                  : 'bg-white dark:bg-gray-800 text-gray-800 dark:text-white border border-gray-200 dark:border-gray-700'
              }`}
            >
              <div className="text-sm">{message.messageText}</div>
              <div
                className={`text-xs mt-1 ${
                  message.sender === 'manager'
                    ? 'text-blue-100'
                    : 'text-gray-500 dark:text-gray-400'
                }`}
              >
                {formatDate(message.createdAt)}
              </div>
            </div>
          </div>
        ))}
        <div ref={messagesEndRef} />
      </div>

      {/* Input */}
      {session.status === 'active' && (
        <div className="bg-white dark:bg-gray-800 p-4 border-t border-gray-200 dark:border-gray-700">
          <div className="flex gap-2">
            <input
              type="text"
              value={newMessage}
              onChange={(e) => setNewMessage(e.target.value)}
              onKeyDown={(e) => {
                if (e.key === 'Enter' && !e.shiftKey) {
                  e.preventDefault()
                  sendMessage()
                }
              }}
              placeholder="Type a message..."
              className="flex-1 px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg dark:bg-gray-700 dark:text-white"
              disabled={sending}
            />
            <button
              onClick={sendMessage}
              disabled={sending || !newMessage.trim()}
              className="px-6 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              Send
            </button>
          </div>
        </div>
      )}
    </div>
  )
}

