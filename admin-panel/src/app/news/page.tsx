'use client'
import { useState, useEffect } from 'react'
import { useRouter } from 'next/navigation'
import { api } from '@/lib/api'
import { Table, TableBody, TableCell, TableHeader, TableRow } from '@/components/ui/table'
import Badge from '@/components/ui/badge/Badge'
import Button from '@/components/ui/button/Button'
import Image from 'next/image'

export default function NewsPage() {
  const router = useRouter()
  const [news, setNews] = useState<any[]>([])
  const [loading, setLoading] = useState(true)
  const [deletingId, setDeletingId] = useState<string | null>(null)

  useEffect(() => {
    console.log('NewsPage mounted, loading news...')
    loadNews()
  }, [])

  const loadNews = async () => {
    setLoading(true)
    try {
      const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:4000/api'
      console.log('🔍 Loading news from:', apiUrl)
      console.log('🔍 API instance baseURL:', api.defaults.baseURL)
      console.log('🔍 Token exists:', typeof window !== 'undefined' ? !!localStorage.getItem('token') : 'N/A')
      
      const { data } = await api.get('/news')
      console.log('✅ News API response:', data)
      const newsData = data.data || []
      console.log('📰 News data count:', newsData.length)
      // Format dates and ensure proper structure
      const formattedNews = newsData.map((item: any) => ({
        ...item,
        image: item.imageUrl || null,
        content: item.description || '',
        status: item.isPublished ? 'published' : 'draft',
        createdAt: item.createdAt ? new Date(item.createdAt).toLocaleDateString('en-US', { 
          year: 'numeric', 
          month: 'short', 
          day: 'numeric' 
        }) : '-',
      }))
      console.log('Formatted news count:', formattedNews.length)
      setNews(formattedNews)
    } catch (error: any) {
      console.error('Error loading news:', error)
      console.error('Error response:', error.response?.data)
      console.error('Error status:', error.response?.status)
      alert(`Помилка завантаження новин: ${error.response?.data?.message || error.message || 'Невідома помилка'}`)
      setNews([])
    } finally {
      setLoading(false)
    }
  }

  const handleDeleteNews = async (newsId: string) => {
    if (!confirm('Are you sure you want to delete this news? This action cannot be undone.')) {
      return
    }

    setDeletingId(newsId)
    try {
      await api.delete(`/news/${newsId}`)
      await loadNews()
    } catch (error) {
      console.error('Error deleting news:', error)
      alert('Failed to delete news. Please try again.')
    } finally {
      setDeletingId(null)
    }
  }

  const getStatusBadgeColor = (status: string) => {
    switch (status) {
      case 'published':
        return 'success'
      case 'draft':
        return 'warning'
      case 'archived':
        return 'error'
      default:
        return 'light'
    }
  }

  const getStatusLabel = (status: string) => {
    switch (status) {
      case 'published':
        return 'Published'
      case 'draft':
        return 'Draft'
      case 'archived':
        return 'Archived'
      default:
        return status
    }
  }

  return (
    <div className="space-y-6">
      {/* Header with Add Button */}
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-semibold text-gray-800 dark:text-white">
          News
        </h1>
        <Button className="flex items-center gap-2" onClick={() => router.push('/news/add')}>
          <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
            <path d="M8 3V13M3 8H13" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/>
          </svg>
          Add News
        </Button>
      </div>

      {/* Table */}
      <div className="overflow-hidden rounded-xl border border-gray-200 bg-white dark:border-gray-800 dark:bg-gray-900">
        <div className="max-w-full overflow-x-auto">
          <Table>
            <TableHeader className="border-b border-gray-100 dark:border-white/5">
              <TableRow>
                <TableCell isHeader className="px-5 py-3 font-medium text-gray-500 text-theme-xs dark:text-gray-400 text-start">
                  News
                </TableCell>
                <TableCell isHeader className="px-5 py-3 font-medium text-gray-500 text-theme-xs dark:text-gray-400 text-start">
                  Text
                </TableCell>
                <TableCell isHeader className="px-5 py-3 font-medium text-gray-500 text-theme-xs dark:text-gray-400 text-start">
                  Status
                </TableCell>
                <TableCell isHeader className="px-5 py-3 font-medium text-gray-500 text-theme-xs dark:text-gray-400 text-start">
                  Created At
                </TableCell>
                <TableCell isHeader className="px-5 py-3 font-medium text-gray-500 text-theme-xs dark:text-gray-400 text-start">
                  Actions
                </TableCell>
              </TableRow>
            </TableHeader>

            <TableBody className="divide-y divide-gray-100 dark:divide-white/5">
              {loading ? (
                <TableRow>
                  <TableCell colSpan={5} className="px-5 py-8 text-center text-gray-500">
                    Loading...
                  </TableCell>
                </TableRow>
              ) : news.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={5} className="px-5 py-8 text-center text-gray-500">
                    No news
                  </TableCell>
                </TableRow>
              ) : (
                news.map((item) => (
                  <TableRow 
                    key={item.id} 
                    className="hover:bg-gray-50 dark:hover:bg-gray-800/50 cursor-pointer"
                    onClick={() => router.push(`/news/${item.id}`)}
                  >
                    <TableCell className="px-5 py-4">
                      <div className="flex items-center gap-3">
                        {item.image && (
                          <div className="w-12 h-12 overflow-hidden rounded-lg flex-shrink-0">
                            <Image
                              width={48}
                              height={48}
                              src={item.image}
                              alt={item.title}
                              className="object-cover w-full h-full"
                            />
                          </div>
                        )}
                        <div>
                          <span className="block font-medium text-gray-800 text-theme-sm dark:text-white/90 line-clamp-1">
                            {item.title}
                          </span>
                        </div>
                      </div>
                    </TableCell>
                    <TableCell className="px-5 py-4">
                      <span className="block text-gray-500 text-theme-sm dark:text-gray-400 line-clamp-2">
                        {item.content || '-'}
                      </span>
                    </TableCell>
                    <TableCell className="px-5 py-4">
                      <Badge size="sm" color={getStatusBadgeColor(item.status)}>
                        {getStatusLabel(item.status)}
                      </Badge>
                    </TableCell>
                    <TableCell className="px-5 py-4">
                      <span className="block text-gray-500 text-theme-sm dark:text-gray-400">
                        {item.createdAt || '-'}
                      </span>
                    </TableCell>
                    <TableCell className="px-5 py-4" onClick={(e) => e.stopPropagation()}>
                      <div className="flex items-center gap-2">
                        <button 
                          onClick={() => router.push(`/news/${item.id}`)}
                          className="p-2 rounded-lg hover:bg-gray-100 dark:hover:bg-white/5 text-gray-500 hover:text-gray-700 dark:hover:text-gray-300"
                          title="View/Edit"
                        >
                          <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
                            <path d="M11.3333 2.00004H4.66659C3.93021 2.00004 3.33325 2.59699 3.33325 3.33337V13.3334C3.33325 14.0698 3.93021 14.6667 4.66659 14.6667H11.3333C12.0696 14.6667 12.6666 14.0698 12.6666 13.3334V5.05337C12.6666 4.68443 12.5254 4.33033 12.2754 4.08033L9.94659 1.75162C9.69659 1.50162 9.34249 1.3604 8.97355 1.3604H4.66659C3.93021 1.3604 3.33325 1.95735 3.33325 2.69373V13.3334C3.33325 14.0698 3.93021 14.6667 4.66659 14.6667H11.3333C12.0696 14.6667 12.6666 14.0698 12.6666 13.3334V5.05337C12.6666 4.68443 12.5254 4.33033 12.2754 4.08033L9.94659 1.75162C9.69659 1.50162 9.34249 1.3604 8.97355 1.3604ZM8.97355 2.3604L11.3022 4.68911H8.97355V2.3604Z" fill="currentColor"/>
                          </svg>
                        </button>
                        <button 
                          onClick={() => handleDeleteNews(item.id)}
                          disabled={deletingId === item.id}
                          className="p-2 rounded-lg hover:bg-gray-100 dark:hover:bg-white/5 text-gray-500 hover:text-red-600 dark:hover:text-red-400 disabled:opacity-50"
                          title="Delete"
                        >
                          {deletingId === item.id ? (
                            <svg className="animate-spin h-4 w-4" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                              <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                              <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                            </svg>
                          ) : (
                            <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
                              <path d="M11.3333 2.00004C11.5083 2.00004 11.6763 2.07019 11.8013 2.19526C11.9263 2.32033 11.9963 2.48842 11.9963 2.66344V13.3334C11.9963 13.5084 11.9263 13.6765 11.8013 13.8016C11.6763 13.9267 11.5083 13.9968 11.3333 13.9968H4.66659C4.49157 13.9968 4.32348 13.9267 4.19841 13.8016C4.07334 13.6765 4.00319 13.5084 4.00319 13.3334V2.66344C4.00319 2.48842 4.07334 2.32033 4.19841 2.19526C4.32348 2.07019 4.49157 2.00004 4.66659 2.00004H6.66659L6.66659 1.33337C6.66659 1.15835 6.73674 0.990261 6.86181 0.865189C6.98688 0.740117 7.15497 0.669968 7.32999 0.669968H8.66999C8.84501 0.669968 9.0131 0.740117 9.13817 0.865189C9.26324 0.990261 9.33339 1.15835 9.33339 1.33337V2.00004H11.3333Z" fill="currentColor"/>
                            </svg>
                          )}
                        </button>
                      </div>
                    </TableCell>
                  </TableRow>
                ))
              )}
            </TableBody>
          </Table>
        </div>
      </div>
    </div>
  )
}
