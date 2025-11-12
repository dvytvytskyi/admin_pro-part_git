'use client'
import { useState, useEffect } from 'react'
import { useRouter } from 'next/navigation'
import { api } from '@/lib/api'
import Image from 'next/image'
import { Table, TableBody, TableCell, TableHeader, TableRow } from '@/components/ui/table'
import Badge from '@/components/ui/badge/Badge'
import Button from '@/components/ui/button/Button'
import Input from '@/components/form/input/InputField'
import Pagination from '@/components/tables/Pagination'

export default function PropertiesPage() {
  const router = useRouter()
  const [properties, setProperties] = useState<any[]>([])
  const [loading, setLoading] = useState(true)
  const [propertyType, setPropertyType] = useState<'off-plan' | 'secondary'>('off-plan')
  const [searchQuery, setSearchQuery] = useState('')
  const [currentPage, setCurrentPage] = useState(1)
  const [itemsPerPage] = useState(100)
  const [totalCount, setTotalCount] = useState(0)
  const [totalPages, setTotalPages] = useState(1)
  const [imageLoadingStates, setImageLoadingStates] = useState<Record<string, boolean>>({})

  // Скидаємо сторінку на 1 при зміні типу проекту або пошуку
  useEffect(() => {
    setCurrentPage(1)
  }, [propertyType, searchQuery])

  useEffect(() => {
    loadProperties()
    // Scroll to top when tab changes
    window.scrollTo({
      top: 0,
      behavior: 'smooth'
    })
  }, [propertyType, currentPage, searchQuery])

  // Scroll to top when page changes
  useEffect(() => {
    window.scrollTo({
      top: 0,
      behavior: 'smooth'
    })
  }, [currentPage])

  const loadProperties = async () => {
    setLoading(true)
    try {
      // Формуємо параметри для запиту
      const params: any = {
        propertyType: propertyType,
        page: currentPage.toString(),
        limit: itemsPerPage.toString(),
      }
      
      // Додаємо пошук, якщо є
      if (searchQuery) {
        params.search = searchQuery
      }

      // Використовуємо публічний ендпоінт без автентифікації
      const { data } = await api.get('/public/properties', { params })
      
      // Бекенд ЗАВЖДИ повертає структуру з пагінацією
      if (data.data?.data && data.data?.pagination) {
        // Нова структура з пагінацією
        const propertiesData = data.data.data;
        
        // Діагностика: перевіряємо photos
        if (process.env.NODE_ENV === 'development') {
          const propertiesWithPhotos = propertiesData.filter((p: any) => p.photos && Array.isArray(p.photos) && p.photos.length > 0);
          const propertiesWithoutPhotos = propertiesData.filter((p: any) => !p.photos || !Array.isArray(p.photos) || p.photos.length === 0);
          console.log('[Properties] Loaded:', {
            total: propertiesData.length,
            withPhotos: propertiesWithPhotos.length,
            withoutPhotos: propertiesWithoutPhotos.length,
            samplePhotos: propertiesWithPhotos.slice(0, 3).map((p: any) => ({
              name: p.name,
              photos: p.photos,
              firstPhoto: p.photos?.[0],
              firstPhotoType: typeof p.photos?.[0],
            })),
          });
        }
        
        setProperties(propertiesData)
        setTotalCount(data.data.pagination.total)
        setTotalPages(data.data.pagination.totalPages)
      } else if (data.data && Array.isArray(data.data)) {
        // Fallback для старої структури (якщо бекенд ще не оновлений)
        console.warn('Backend returned old format without pagination')
        setProperties(data.data)
        setTotalCount(data.data.length)
        setTotalPages(Math.ceil(data.data.length / itemsPerPage))
      } else if (data.data && data.data.data && data.data.total !== undefined) {
        // Формат з data.data.data та data.data.total (старий формат бекенду)
        setProperties(data.data.data)
        setTotalCount(data.data.total)
        setTotalPages(Math.ceil(data.data.total / (data.data.limit || itemsPerPage)))
      } else {
        // Помилка або порожня відповідь
        console.error('Unexpected response format:', data)
        setProperties([])
        setTotalCount(0)
        setTotalPages(1)
      }
    } catch (error) {
      console.error('Error loading properties:', error)
      setProperties([])
      setTotalCount(0)
      setTotalPages(1)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="space-y-6">
      {/* Header with Add Button */}
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-semibold text-gray-800 dark:text-white">Properties</h1>
        <Button
          className="flex items-center gap-2"
          onClick={() => router.push('/properties/add')}
        >
          <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
            <path
              d="M8 3V13M3 8H13"
              stroke="currentColor"
              strokeWidth="2"
              strokeLinecap="round"
            />
          </svg>
          Add Property
        </Button>
      </div>

      {/* Filters and Search */}
      <div className="flex flex-col sm:flex-row gap-4 items-start sm:items-center justify-between">
        {/* Property Type Toggle */}
        <div className="inline-flex rounded-lg border border-gray-200 p-1 dark:border-gray-800 dark:bg-gray-900">
          <button
            onClick={() => setPropertyType('off-plan')}
            className={`px-4 py-2 rounded-md text-sm font-medium transition-colors ${
              propertyType === 'off-plan'
                ? 'bg-brand-500 text-white'
                : 'text-gray-700 hover:bg-gray-100 dark:text-gray-400 dark:hover:bg-white/5'
            }`}
          >
            Off-Plan
          </button>
          <button
            onClick={() => setPropertyType('secondary')}
            className={`px-4 py-2 rounded-md text-sm font-medium transition-colors ${
              propertyType === 'secondary'
                ? 'bg-brand-500 text-white'
                : 'text-gray-700 hover:bg-gray-100 dark:text-gray-400 dark:hover:bg-white/5'
            }`}
          >
            Secondary
          </button>
        </div>

        {/* Search */}
        <div className="w-full sm:w-auto sm:min-w-[300px]">
          <Input
            type="text"
            placeholder="Search by name or ID..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
          />
        </div>
      </div>

      {/* Datatable */}
      <div className="overflow-hidden rounded-xl border border-gray-200 bg-white dark:border-white/[0.05] dark:bg-white/[0.03]">
        <div className="max-w-full overflow-x-auto">
          <div className="min-w-[1102px]">
            <Table>
              {/* Table Header */}
              <TableHeader className="border-b border-gray-100 dark:border-white/[0.05]">
                <TableRow>
                  <TableCell
                    isHeader
                    className="px-5 py-3 font-medium text-gray-500 text-start text-theme-xs dark:text-gray-400"
                  >
                    Property
                  </TableCell>
                  <TableCell
                    isHeader
                    className="px-5 py-3 font-medium text-gray-500 text-start text-theme-xs dark:text-gray-400"
                  >
                    Location
                  </TableCell>
                  <TableCell
                    isHeader
                    className="px-5 py-3 font-medium text-gray-500 text-start text-theme-xs dark:text-gray-400"
                  >
                    Price
                  </TableCell>
                  <TableCell
                    isHeader
                    className="px-5 py-3 font-medium text-gray-500 text-start text-theme-xs dark:text-gray-400"
                  >
                    Bedrooms
                  </TableCell>
                  <TableCell
                    isHeader
                    className="px-5 py-3 font-medium text-gray-500 text-start text-theme-xs dark:text-gray-400"
                  >
                    Size
                  </TableCell>
                  <TableCell
                    isHeader
                    className="px-5 py-3 font-medium text-gray-500 text-start text-theme-xs dark:text-gray-400"
                  >
                    Status
                  </TableCell>
                  <TableCell
                    isHeader
                    className="px-5 py-3 font-medium text-gray-500 text-start text-theme-xs dark:text-gray-400"
                  >
                    Last Visited
                  </TableCell>
                </TableRow>
              </TableHeader>

              {/* Table Body */}
              <TableBody className="divide-y divide-gray-100 dark:divide-white/[0.05]">
                {loading ? (
                  <TableRow>
                    <TableCell colSpan={7} className="px-5 py-8 text-center text-gray-500">
                      Loading...
                    </TableCell>
                  </TableRow>
                ) : properties.length === 0 ? (
                  <TableRow>
                    <TableCell colSpan={7} className="px-5 py-8 text-center text-gray-500">
                      {searchQuery ? 'No properties found' : 'No properties'}
                    </TableCell>
                  </TableRow>
                ) : (
                  properties.map((property) => (
                    <TableRow 
                      key={property.id} 
                      className="hover:bg-gray-50 dark:hover:bg-gray-800/50 cursor-pointer"
                      onClick={() => router.push(`/properties/edit/${property.id}`)}
                    >
                      <TableCell className="px-5 py-4 sm:px-6 text-start">
                        <div className="flex items-center gap-3">
                          {(() => {
                            // Безпечна перевірка photos - перевіряємо що це валідний URL рядок
                            const firstPhoto = property.photos?.[0];
                            const isValidPhoto = firstPhoto && 
                              typeof firstPhoto === 'string' && 
                              firstPhoto.trim().length > 0 && 
                              (firstPhoto.startsWith('http://') || firstPhoto.startsWith('https://'));
                            
                            return isValidPhoto ? (
                            <div className="relative w-12 h-12 overflow-hidden rounded-lg border border-gray-200 dark:border-gray-700 bg-gray-100 dark:bg-gray-800">
                              {/* Skeleton loader - show while loading (undefined or true) */}
                              {imageLoadingStates[property.id] !== false && (
                                <div className="absolute inset-0 bg-gradient-to-br from-gray-300 via-gray-200 to-gray-300 dark:from-gray-600 dark:via-gray-700 dark:to-gray-600">
                                  {/* Shimmer effect */}
                                  <div className="absolute inset-0 overflow-hidden">
                                    <div className="absolute inset-0 bg-gradient-to-r from-transparent via-white/40 to-transparent animate-shimmer" />
                                  </div>
                                  {/* Pulse overlay for more visibility */}
                                  <div className="absolute inset-0 bg-gray-300/50 dark:bg-gray-700/50 animate-pulse" />
                                </div>
                              )}
                              <Image
                                width={48}
                                height={48}
                                src={firstPhoto}
                                alt={property.name || 'Property'}
                                className={`object-cover w-full h-full transition-opacity duration-300 ${
                                  imageLoadingStates[property.id] === false ? 'opacity-100' : 'opacity-0'
                                }`}
                                onLoad={() => {
                                  setImageLoadingStates((prev) => ({
                                    ...prev,
                                    [property.id]: false,
                                  }))
                                }}
                                onError={() => {
                                  setImageLoadingStates((prev) => ({
                                    ...prev,
                                    [property.id]: false,
                                  }))
                                }}
                              />
                            </div>
                            ) : (
                            <div className="w-12 h-12 rounded-lg border border-gray-200 dark:border-gray-700 bg-gray-100 dark:bg-gray-800 flex items-center justify-center">
                              <svg
                                className="w-6 h-6 text-gray-400"
                                fill="none"
                                stroke="currentColor"
                                viewBox="0 0 24 24"
                              >
                                <path
                                  strokeLinecap="round"
                                  strokeLinejoin="round"
                                  strokeWidth={2}
                                  d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"
                                />
                              </svg>
                            </div>
                          );
                          })()}
                          <div>
                            <span className="block font-medium text-gray-800 text-theme-sm dark:text-white/90">
                              {property.name || 'Unnamed Property'}
                            </span>
                            <span className="block text-gray-500 text-theme-xs dark:text-gray-400">
                              ID: {property.id?.slice(0, 8)}...
                            </span>
                          </div>
                        </div>
                      </TableCell>
                      <TableCell className="px-5 py-4 text-gray-500 text-start text-theme-sm dark:text-gray-400">
                        {property.area?.nameEn || property.city?.nameEn || '-'}
                      </TableCell>
                      <TableCell className="px-5 py-4 text-gray-800 text-start text-theme-sm dark:text-white/90 font-medium">
                        {property.price
                          ? `$${Math.round(property.price).toLocaleString('en-US', { minimumFractionDigits: 0, maximumFractionDigits: 0 })}`
                          : property.priceFrom
                            ? `From $${Math.round(property.priceFrom).toLocaleString('en-US', { minimumFractionDigits: 0, maximumFractionDigits: 0 })}`
                            : '-'}
                      </TableCell>
                      <TableCell className="px-5 py-4 text-gray-500 text-start text-theme-sm dark:text-gray-400">
                        {property.bedrooms
                          ? property.bedrooms
                          : property.bedroomsFrom && property.bedroomsTo
                            ? `${property.bedroomsFrom}-${property.bedroomsTo}`
                            : '-'}
                      </TableCell>
                      <TableCell className="px-5 py-4 text-gray-500 text-start text-theme-sm dark:text-gray-400">
                        {property.size
                          ? `${property.size} sq.m`
                          : property.sizeFrom && property.sizeTo
                            ? `${property.sizeFrom}-${property.sizeTo} sq.m`
                            : '-'}
                      </TableCell>
                      <TableCell className="px-5 py-4 text-start">
                        <Badge size="sm" color="success">
                          Active
                        </Badge>
                      </TableCell>
                      <TableCell className="px-5 py-4 text-gray-500 text-start text-theme-sm dark:text-gray-400">
                        {property.updatedAt
                          ? new Date(property.updatedAt).toLocaleDateString('en-US', {
                              year: 'numeric',
                              month: 'short',
                              day: 'numeric',
                              hour: '2-digit',
                              minute: '2-digit',
                            })
                          : property.createdAt
                            ? new Date(property.createdAt).toLocaleDateString('en-US', {
                                year: 'numeric',
                                month: 'short',
                                day: 'numeric',
                                hour: '2-digit',
                                minute: '2-digit',
                              })
                            : '-'}
                      </TableCell>
                    </TableRow>
                  ))
                )}
              </TableBody>
            </Table>
          </div>
        </div>
      </div>

      {/* Pagination */}
      <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
        <p className="text-sm text-gray-500 dark:text-gray-400">
          {totalCount > 0
            ? `Showing ${(currentPage - 1) * itemsPerPage + 1} to ${Math.min(currentPage * itemsPerPage, totalCount)} of ${totalCount} properties`
            : 'No properties found'}
        </p>
        {totalPages > 1 && (
          <Pagination
            currentPage={currentPage}
            totalPages={totalPages}
            onPageChange={setCurrentPage}
          />
        )}
      </div>
    </div>
  )
}
