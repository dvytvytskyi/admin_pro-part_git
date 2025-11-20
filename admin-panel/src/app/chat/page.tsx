'use client'
import { useState, useEffect } from 'react'
import { useRouter } from 'next/navigation'
import { api } from '@/lib/api'

interface ChatSession {
  id: string
  userName: string | null
  userPhone: string | null
  status: 'active' | 'closed' | 'archived'
  managerId: string | null
  lastMessage: {
    text: string
    sender: 'user' | 'manager'
    createdAt: string
  } | null
  unreadCount: number
  messageCount: number
  createdAt: string
  updatedAt: string
}

export default function ChatPage() {
  const router = useRouter()
  const [sessions, setSessions] = useState<ChatSession[]>([])
  const [loading, setLoading] = useState(true)
  const [statusFilter, setStatusFilter] = useState<'all' | 'active' | 'closed' | 'archived'>('active')
  const [search, setSearch] = useState('')
  const [page, setPage] = useState(1)
  const [totalPages, setTotalPages] = useState(1)
  const [stats, setStats] = useState({
    activeSessions: 0,
    closedSessions: 0,
    totalMessages: 0,
    unreadSessions: 0,
  })

  const loadSessions = async () => {
    try {
      setLoading(true)
      const params = new URLSearchParams()
      if (statusFilter !== 'all') {
        params.append('status', statusFilter)
      }
      if (search) {
        params.append('search', search)
      }
      params.append('page', page.toString())
      params.append('limit', '20')

      const response = await api.get(`/chat/sessions?${params.toString()}`)
      console.log('Chat sessions response:', response.data)
      
      // Handle API response structure
      const data = response.data?.data || response.data
      if (data?.sessions) {
        setSessions(data.sessions)
        setTotalPages(data.pagination?.totalPages || 1)
      } else if (response.data?.success && response.data?.data) {
        setSessions(response.data.data.sessions || [])
        setTotalPages(response.data.data.pagination?.totalPages || 1)
      }
    } catch (error) {
      console.error('Error loading chat sessions:', error)
    } finally {
      setLoading(false)
    }
  }

  const loadStats = async () => {
    try {
      const response = await api.get('/chat/stats')
      console.log('Chat stats response:', response.data)
      
      // Handle API response structure
      const data = response.data?.data || response.data
      if (data) {
        setStats({
          activeSessions: data.activeSessions || 0,
          closedSessions: data.closedSessions || 0,
          totalMessages: data.totalMessages || 0,
          unreadSessions: data.unreadSessions || 0,
        })
      }
    } catch (error) {
      console.error('Error loading stats:', error)
    }
  }

  useEffect(() => {
    loadSessions()
    loadStats()
  }, [statusFilter, page])

  useEffect(() => {
    // Автооновлення кожні 5 секунд
    const interval = setInterval(() => {
      loadSessions()
      loadStats()
    }, 5000)

    return () => clearInterval(interval)
  }, [statusFilter, search, page])

  const handleCloseSession = async (sessionId: string) => {
    try {
      await api.post(`/chat/sessions/${sessionId}/close`)
      loadSessions()
      loadStats()
    } catch (error) {
      console.error('Error closing session:', error)
    }
  }

  const formatDate = (dateString: string) => {
    const date = new Date(dateString)
    const now = new Date()
    const diff = now.getTime() - date.getTime()
    const minutes = Math.floor(diff / 60000)
    const hours = Math.floor(diff / 3600000)
    const days = Math.floor(diff / 86400000)

    if (minutes < 1) return 'Just now'
    if (minutes < 60) return `${minutes}m ago`
    if (hours < 24) return `${hours}h ago`
    if (days < 7) return `${days}d ago`
    return date.toLocaleDateString()
  }

  const getStatusBadge = (status: string) => {
    const colors = {
      active: 'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200',
      closed: 'bg-gray-100 text-gray-800 dark:bg-gray-800 dark:text-gray-200',
      archived: 'bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-200',
    }
    return (
      <span
        className={`px-2 py-1 rounded-full text-xs font-medium ${
          colors[status as keyof typeof colors] || colors.active
        }`}
      >
        {status}
      </span>
    )
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-semibold text-gray-800 dark:text-white">Chat Sessions</h1>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <div className="bg-white dark:bg-gray-800 p-4 rounded-lg shadow">
          <div className="text-sm text-gray-500 dark:text-gray-400">Active</div>
          <div className="text-2xl font-bold text-gray-800 dark:text-white">{stats.activeSessions}</div>
        </div>
        <div className="bg-white dark:bg-gray-800 p-4 rounded-lg shadow">
          <div className="text-sm text-gray-500 dark:text-gray-400">Closed</div>
          <div className="text-2xl font-bold text-gray-800 dark:text-white">{stats.closedSessions}</div>
        </div>
        <div className="bg-white dark:bg-gray-800 p-4 rounded-lg shadow">
          <div className="text-sm text-gray-500 dark:text-gray-400">Total Messages</div>
          <div className="text-2xl font-bold text-gray-800 dark:text-white">{stats.totalMessages}</div>
        </div>
        <div className="bg-white dark:bg-gray-800 p-4 rounded-lg shadow">
          <div className="text-sm text-gray-500 dark:text-gray-400">Unread</div>
          <div className="text-2xl font-bold text-orange-600 dark:text-orange-400">{stats.unreadSessions}</div>
        </div>
      </div>

      {/* Filters */}
      <div className="bg-white dark:bg-gray-800 p-4 rounded-lg shadow flex gap-4 items-center">
        <div className="flex gap-2">
          {(['all', 'active', 'closed', 'archived'] as const).map((status) => (
            <button
              key={status}
              onClick={() => {
                setStatusFilter(status)
                setPage(1)
              }}
              className={`px-4 py-2 rounded ${
                statusFilter === status
                  ? 'bg-blue-500 text-white'
                  : 'bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300'
              }`}
            >
              {status.charAt(0).toUpperCase() + status.slice(1)}
            </button>
          ))}
        </div>
        <input
          type="text"
          placeholder="Search by name or phone..."
          value={search}
          onChange={(e) => {
            setSearch(e.target.value)
            setPage(1)
          }}
          onKeyDown={(e) => {
            if (e.key === 'Enter') {
              loadSessions()
            }
          }}
          className="flex-1 px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg dark:bg-gray-700 dark:text-white"
        />
      </div>

      {/* Sessions List */}
      {loading ? (
        <div className="text-center py-8">Loading...</div>
      ) : sessions.length === 0 ? (
        <div className="text-center py-8 text-gray-500">No chat sessions found</div>
      ) : (
        <div className="bg-white dark:bg-gray-800 rounded-lg shadow overflow-hidden">
          <table className="w-full">
            <thead className="bg-gray-50 dark:bg-gray-700">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                  User
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                  Last Message
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                  Status
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                  Updated
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                  Actions
                </th>
              </tr>
            </thead>
            <tbody className="bg-white dark:bg-gray-800 divide-y divide-gray-200 dark:divide-gray-700">
              {sessions.map((session) => (
                <tr
                  key={session.id}
                  className="hover:bg-gray-50 dark:hover:bg-gray-700 cursor-pointer"
                  onClick={() => router.push(`/chat/${session.id}`)}
                >
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="flex items-center">
                      <div>
                        <div className="text-sm font-medium text-gray-900 dark:text-white">
                          {session.userName || 'Anonymous'}
                        </div>
                        <div className="text-sm text-gray-500 dark:text-gray-400">
                          {session.userPhone || 'No phone'}
                        </div>
                      </div>
                      {session.unreadCount > 0 && (
                        <span className="ml-2 bg-orange-500 text-white text-xs px-2 py-1 rounded-full">
                          {session.unreadCount}
                        </span>
                      )}
                    </div>
                  </td>
                  <td className="px-6 py-4">
                    <div className="text-sm text-gray-900 dark:text-white max-w-md truncate">
                      {session.lastMessage?.text || 'No messages'}
                    </div>
                    {session.lastMessage && (
                      <div className="text-xs text-gray-500 dark:text-gray-400">
                        {session.lastMessage.sender === 'user' ? '👤' : '👨‍💼'} {formatDate(session.lastMessage.createdAt)}
                      </div>
                    )}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">{getStatusBadge(session.status)}</td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400">
                    {formatDate(session.updatedAt)}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                    <button
                      onClick={(e) => {
                        e.stopPropagation()
                        router.push(`/chat/${session.id}`)
                      }}
                      className="text-blue-600 hover:text-blue-900 dark:text-blue-400 dark:hover:text-blue-300 mr-3"
                    >
                      Open
                    </button>
                    {session.status === 'active' && (
                      <button
                        onClick={(e) => {
                          e.stopPropagation()
                          handleCloseSession(session.id)
                        }}
                        className="text-red-600 hover:text-red-900 dark:text-red-400 dark:hover:text-red-300"
                      >
                        Close
                      </button>
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {/* Pagination */}
      {totalPages > 1 && (
        <div className="flex justify-center gap-2">
          <button
            onClick={() => setPage(p => Math.max(1, p - 1))}
            disabled={page === 1}
            className="px-4 py-2 border rounded disabled:opacity-50"
          >
            Previous
          </button>
          <span className="px-4 py-2">
            Page {page} of {totalPages}
          </span>
          <button
            onClick={() => setPage(p => Math.min(totalPages, p + 1))}
            disabled={page >= totalPages}
            className="px-4 py-2 border rounded disabled:opacity-50"
          >
            Next
          </button>
        </div>
      )}
    </div>
  )
}

