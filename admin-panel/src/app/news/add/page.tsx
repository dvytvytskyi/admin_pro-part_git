'use client'
import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { api } from '@/lib/api'
import Form from '@/components/form/Form'
import Label from '@/components/form/Label'
import Input from '@/components/form/input/InputField'
import Select from '@/components/form/Select'
import Button from '@/components/ui/button/Button'

interface ContentItem {
  id: string
  type: 'text' | 'image' | 'video'
  title: string
  description: string
  imageUrl: string
  videoUrl: string
}

export default function AddNewsPage() {
  const router = useRouter()
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [uploadingImage, setUploadingImage] = useState<string | null>(null)
  const [uploadingMainImage, setUploadingMainImage] = useState(false)
  
  const [formData, setFormData] = useState({
    title: '',
    description: '',
    imageUrl: '',
    isPublished: false,
  })

  const [contents, setContents] = useState<ContentItem[]>([])

  const contentTypeOptions = [
    { value: 'text', label: 'Text' },
    { value: 'image', label: 'Image' },
    { value: 'video', label: 'Video' },
  ]

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
    const { name, value } = e.target
    setFormData(prev => ({ ...prev, [name]: value }))
  }

  const handleTogglePublished = (e: React.ChangeEvent<HTMLInputElement>) => {
    setFormData(prev => ({ ...prev, isPublished: e.target.checked }))
  }

  const handleAddContent = () => {
    const newContent: ContentItem = {
      id: Date.now().toString(),
      type: 'text',
      title: '',
      description: '',
      imageUrl: '',
      videoUrl: '',
    }
    setContents([...contents, newContent])
  }

  const handleUpdateContent = (id: string, field: keyof ContentItem, value: string) => {
    setContents(contents.map(item => 
      item.id === id ? { ...item, [field]: value } : item
    ))
  }

  const handleRemoveContent = (id: string) => {
    setContents(contents.filter(item => item.id !== id))
  }

  const handleImageUpload = async (contentId: string, file: File) => {
    setUploadingImage(contentId)
    try {
      const formData = new FormData()
      formData.append('file', file)
      
      const { data } = await api.post('/upload/image', formData, {
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      })
      
      if (data.data?.url) {
        handleUpdateContent(contentId, 'imageUrl', data.data.url)
      }
    } catch (err) {
      console.error('Error uploading image:', err)
      setError('Failed to upload image. Please try again.')
    } finally {
      setUploadingImage(null)
    }
  }

  const handleMainImageUpload = async (file: File) => {
    setUploadingMainImage(true)
    try {
      const formData = new FormData()
      formData.append('file', file)
      
      const { data } = await api.post('/upload/image', formData, {
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      })
      
      if (data.data?.url) {
        setFormData(prev => ({ ...prev, imageUrl: data.data.url }))
      }
    } catch (err) {
      console.error('Error uploading image:', err)
      setError('Failed to upload image. Please try again.')
    } finally {
      setUploadingMainImage(false)
    }
  }

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    setError(null)
    setLoading(true)

    // Validation
    if (!formData.title || !formData.description) {
      setError('Please fill in all required fields')
      setLoading(false)
      return
    }

    try {
      const payload = {
        title: formData.title,
        description: formData.description,
        imageUrl: formData.imageUrl || null,
        isPublished: formData.isPublished,
        publishedAt: formData.isPublished ? new Date().toISOString() : null,
        contents: contents.map((content, index) => ({
          type: content.type,
          title: content.title,
          description: content.description || null,
          imageUrl: content.imageUrl || null,
          videoUrl: content.videoUrl || null,
          order: index,
        })),
      }

      await api.post('/news', payload)
      
      // Success - redirect to news
      router.push('/news')
    } catch (err: any) {
      console.error('Error creating news:', err)
      console.error('Error details:', {
        status: err.response?.status,
        data: err.response?.data,
        message: err.message,
      })
      
      // Extract error message from response
      let errorMessage = 'Failed to create news. Please try again.'
      if (err.response?.data) {
        if (err.response.data.message) {
          errorMessage = err.response.data.message
        } else if (err.response.data.error) {
          errorMessage = err.response.data.error
        } else if (typeof err.response.data === 'string') {
          errorMessage = err.response.data
        }
      } else if (err.message) {
        errorMessage = err.message
      }
      
      setError(errorMessage)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="max-w-7xl mx-auto space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-semibold text-gray-800 dark:text-white">
            Add New News
          </h1>
          <p className="text-sm text-gray-500 dark:text-gray-400 mt-1">
            Create a new news article with content
          </p>
        </div>
        <Button
          variant="outline"
          onClick={() => router.back()}
          disabled={loading}
        >
          <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
            <path d="M10 12L6 8L10 4" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
          </svg>
          Cancel
        </Button>
      </div>

      {/* Two Column Layout */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Form Section - Left 2 columns */}
        <div className="lg:col-span-2">
          <div className="rounded-xl border border-gray-200 bg-white dark:border-gray-800 dark:bg-gray-900 p-6">
            <Form onSubmit={handleSubmit}>
              {/* Error Message */}
              {error && (
                <div className="mb-6 p-4 rounded-lg bg-error-50 border border-error-200 dark:bg-error-900/20 dark:border-error-800">
                  <p className="text-sm text-error-600 dark:text-error-400">{error}</p>
                </div>
              )}

              <div className="space-y-6">
                {/* Basic Information */}
                <div>
                  <h2 className="text-lg font-medium text-gray-800 dark:text-white mb-4">
                    Basic Information
                  </h2>
                  <div className="space-y-4">
                    <div>
                      <Label htmlFor="title">Title *</Label>
                      <Input
                        id="title"
                        name="title"
                        type="text"
                        placeholder="Enter news title"
                        value={formData.title}
                        onChange={handleChange}
                        required
                      />
                    </div>
                    <div>
                      <Label htmlFor="description">Description *</Label>
                      <textarea
                        id="description"
                        name="description"
                        placeholder="Enter news description"
                        value={formData.description}
                        onChange={handleChange}
                        required
                        rows={4}
                        className="h-auto w-full rounded-lg border border-gray-300 px-4 py-2.5 text-sm shadow-theme-xs placeholder:text-gray-400 focus:border-brand-300 focus:outline-hidden focus:ring-3 focus:ring-brand-500/10 dark:border-gray-700 dark:bg-gray-900 dark:text-white/90 dark:placeholder:text-white/30 dark:focus:border-brand-800 bg-transparent text-gray-800"
                      />
                    </div>
                    
                    {/* Main Image Upload */}
                    <div>
                      <Label>Featured Image</Label>
                      <div className="space-y-3">
                        {formData.imageUrl ? (
                          <div className="relative w-full aspect-video rounded-lg overflow-hidden border border-gray-200 dark:border-gray-700">
                            <img 
                              src={formData.imageUrl} 
                              alt="Featured image"
                              className="w-full h-full object-cover"
                              onError={(e) => {
                                (e.target as HTMLImageElement).style.display = 'none'
                              }}
                            />
                            <button
                              type="button"
                              onClick={() => setFormData(prev => ({ ...prev, imageUrl: '' }))}
                              className="absolute top-2 right-2 p-1.5 rounded-lg bg-white dark:bg-gray-800 shadow-md hover:bg-gray-100 dark:hover:bg-gray-700 text-gray-600 hover:text-red-500 dark:text-gray-300"
                            >
                              <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
                                <path d="M4 12L12 4M4 4L12 12" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/>
                              </svg>
                            </button>
                          </div>
                        ) : uploadingMainImage ? (
                          <div className="border-2 border-dashed border-brand-300 dark:border-brand-700 rounded-lg p-6">
                            <div className="flex flex-col items-center justify-center">
                              <svg className="animate-spin h-8 w-8 text-brand-500 mb-2" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                                <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                                <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                              </svg>
                              <span className="text-sm font-medium text-gray-600 dark:text-gray-400">
                                Uploading...
                              </span>
                            </div>
                          </div>
                        ) : (
                          <div className="border-2 border-dashed border-gray-300 dark:border-gray-700 rounded-lg p-6 hover:border-brand-400 dark:hover:border-brand-600 transition-colors">
                            <input
                              type="file"
                              accept="image/*"
                              onChange={(e) => {
                                const file = e.target.files?.[0]
                                if (file) {
                                  handleMainImageUpload(file)
                                }
                              }}
                              className="hidden"
                              id="main-image-upload"
                              disabled={uploadingMainImage}
                            />
                            <label
                              htmlFor="main-image-upload"
                              className="flex flex-col items-center justify-center cursor-pointer"
                            >
                              <svg width="48" height="48" viewBox="0 0 24 24" fill="none" className="text-gray-400 mb-2">
                                <path d="M21 15V19C21 19.5304 20.7893 20.0391 20.4142 20.4142C20.0391 20.7893 19.5304 21 19 21H5C4.46957 21 3.96086 20.7893 3.58579 20.4142C3.21071 20.0391 3 19.5304 3 19V15M17 8L12 3M12 3L7 8M12 3V15" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
                              </svg>
                              <span className="text-sm font-medium text-gray-600 dark:text-gray-400">
                                Click to upload featured image
                              </span>
                              <span className="text-xs text-gray-500 dark:text-gray-500 mt-1">
                                PNG, JPG, GIF up to 10MB
                              </span>
                            </label>
                          </div>
                        )}
                      </div>
                    </div>

                    {/* Published Toggle */}
                    <div className="flex items-center gap-3">
                      <input
                        type="checkbox"
                        id="isPublished"
                        checked={formData.isPublished}
                        onChange={handleTogglePublished}
                        className="w-4 h-4 rounded border-gray-300 text-brand-500 focus:ring-brand-500"
                      />
                      <Label htmlFor="isPublished" className="mb-0 cursor-pointer">
                        Publish immediately
                      </Label>
                    </div>
                  </div>
                </div>

                {/* Content Sections */}
                <div>
                  <div className="flex items-center justify-between mb-4">
                    <h2 className="text-lg font-medium text-gray-800 dark:text-white">
                      Content Sections
                    </h2>
                    <Button
                      type="button"
                      size="sm"
                      onClick={handleAddContent}
                      variant="outline"
                    >
                      <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
                        <path d="M8 3V13M3 8H13" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/>
                      </svg>
                      Add Content
                    </Button>
                  </div>

                  {contents.length === 0 ? (
                    <div className="text-center py-8 border-2 border-dashed border-gray-200 dark:border-gray-700 rounded-lg">
                      <p className="text-gray-500 dark:text-gray-400">No content sections added yet</p>
                    </div>
                  ) : (
                    <div className="space-y-4">
                      {contents.map((content, index) => (
                        <div key={content.id} className="border border-gray-200 dark:border-gray-800 rounded-lg p-4">
                          <div className="flex items-center justify-between mb-4">
                            <h3 className="font-medium text-gray-800 dark:text-white">Section {index + 1}</h3>
                            <button
                              type="button"
                              onClick={() => handleRemoveContent(content.id)}
                              className="p-1 rounded-lg hover:bg-gray-100 dark:hover:bg-white/5 text-gray-500 hover:text-red-500"
                            >
                              <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
                                <path d="M4 12L12 4M4 4L12 12" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/>
                              </svg>
                            </button>
                          </div>
                          
                          <div className="space-y-4">
                            <div>
                              <Label>Type</Label>
                              <Select
                                options={contentTypeOptions}
                                placeholder="Select type"
                                defaultValue={content.type}
                                onChange={(value) => handleUpdateContent(content.id, 'type', value as any)}
                              />
                            </div>
                            <div>
                              <Label>Title *</Label>
                              <Input
                                type="text"
                                placeholder="Enter title"
                                value={content.title}
                                onChange={(e) => handleUpdateContent(content.id, 'title', e.target.value)}
                              />
                            </div>
                            <div>
                              <Label>Description</Label>
                              <textarea
                                placeholder="Enter description"
                                value={content.description}
                                onChange={(e) => handleUpdateContent(content.id, 'description', e.target.value)}
                                rows={3}
                                className="h-auto w-full rounded-lg border border-gray-300 px-4 py-2.5 text-sm shadow-theme-xs placeholder:text-gray-400 focus:border-brand-300 focus:outline-hidden focus:ring-3 focus:ring-brand-500/10 dark:border-gray-700 dark:bg-gray-900 dark:text-white/90 dark:placeholder:text-white/30 dark:focus:border-brand-800 bg-transparent text-gray-800"
                              />
                            </div>
                            {content.type === 'image' && (
                              <div>
                                <Label>Image</Label>
                                <div className="space-y-3">
                                  {content.imageUrl ? (
                                    <div className="relative w-full aspect-video rounded-lg overflow-hidden border border-gray-200 dark:border-gray-700">
                                      <img 
                                        src={content.imageUrl} 
                                        alt={content.title || 'Uploaded image'}
                                        className="w-full h-full object-cover"
                                        onError={(e) => {
                                          (e.target as HTMLImageElement).style.display = 'none'
                                        }}
                                      />
                                      <button
                                        type="button"
                                        onClick={() => handleUpdateContent(content.id, 'imageUrl', '')}
                                        className="absolute top-2 right-2 p-1.5 rounded-lg bg-white dark:bg-gray-800 shadow-md hover:bg-gray-100 dark:hover:bg-gray-700 text-gray-600 hover:text-red-500 dark:text-gray-300"
                                      >
                                        <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
                                          <path d="M4 12L12 4M4 4L12 12" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/>
                                        </svg>
                                      </button>
                                    </div>
                                  ) : uploadingImage === content.id ? (
                                    <div className="border-2 border-dashed border-brand-300 dark:border-brand-700 rounded-lg p-6">
                                      <div className="flex flex-col items-center justify-center">
                                        <svg className="animate-spin h-8 w-8 text-brand-500 mb-2" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                                          <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                                          <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                                        </svg>
                                        <span className="text-sm font-medium text-gray-600 dark:text-gray-400">
                                          Uploading...
                                        </span>
                                      </div>
                                    </div>
                                  ) : (
                                    <div className="border-2 border-dashed border-gray-300 dark:border-gray-700 rounded-lg p-6 hover:border-brand-400 dark:hover:border-brand-600 transition-colors">
                                      <input
                                        type="file"
                                        accept="image/*"
                                        onChange={(e) => {
                                          const file = e.target.files?.[0]
                                          if (file) {
                                            handleImageUpload(content.id, file)
                                          }
                                        }}
                                        className="hidden"
                                        id={`image-upload-${content.id}`}
                                        disabled={uploadingImage !== null}
                                      />
                                      <label
                                        htmlFor={`image-upload-${content.id}`}
                                        className="flex flex-col items-center justify-center cursor-pointer"
                                      >
                                        <svg width="48" height="48" viewBox="0 0 24 24" fill="none" className="text-gray-400 mb-2">
                                          <path d="M21 15V19C21 19.5304 20.7893 20.0391 20.4142 20.4142C20.0391 20.7893 19.5304 21 19 21H5C4.46957 21 3.96086 20.7893 3.58579 20.4142C3.21071 20.0391 3 19.5304 3 19V15M17 8L12 3M12 3L7 8M12 3V15" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
                                        </svg>
                                        <span className="text-sm font-medium text-gray-600 dark:text-gray-400">
                                          Click to upload image
                                        </span>
                                        <span className="text-xs text-gray-500 dark:text-gray-500 mt-1">
                                          PNG, JPG, GIF up to 10MB
                                        </span>
                                      </label>
                                    </div>
                                  )}
                                  {content.imageUrl && (
                                    <div className="text-xs text-gray-500 dark:text-gray-400 break-all">
                                      {content.imageUrl}
                                    </div>
                                  )}
                                </div>
                              </div>
                            )}
                            {content.type === 'video' && (
                              <div>
                                <Label>Video URL</Label>
                                <Input
                                  type="text"
                                  placeholder="Enter video URL"
                                  value={content.videoUrl}
                                  onChange={(e) => handleUpdateContent(content.id, 'videoUrl', e.target.value)}
                                />
                              </div>
                            )}
                          </div>
                        </div>
                      ))}
                    </div>
                  )}
                </div>

                {/* Submit Buttons */}
                <div className="flex items-center justify-end gap-3 pt-4 border-t border-gray-200 dark:border-gray-800">
                  <Button
                    type="button"
                    variant="outline"
                    onClick={() => router.back()}
                    disabled={loading}
                  >
                    Cancel
                  </Button>
                  <Button
                    type="submit"
                    disabled={loading}
                    className="flex items-center gap-2"
                  >
                    {loading ? (
                      <>
                        <svg className="animate-spin h-4 w-4" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                          <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                          <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                        </svg>
                        Creating...
                      </>
                    ) : (
                      <>
                        <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
                          <path d="M13.3333 4L6 11.3333L2.66667 8" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
                        </svg>
                        Create News
                      </>
                    )}
                  </Button>
                </div>
              </div>
            </Form>
          </div>
        </div>

        {/* Preview Section - Right 1 column */}
        <div className="lg:col-span-1">
          <div className="rounded-xl border border-gray-200 bg-white dark:border-gray-800 dark:bg-gray-900 p-6 sticky top-6">
            <h3 className="text-lg font-medium text-gray-800 dark:text-white mb-4">
              Preview
            </h3>
            
            <div className="space-y-4">
              {/* News Header */}
              {formData.title || formData.description ? (
                <div className="space-y-3 pb-4 border-b border-gray-200 dark:border-gray-700">
                  {formData.imageUrl && (
                    <div className="w-full aspect-video rounded-lg overflow-hidden border border-gray-200 dark:border-gray-700">
                      <img 
                        src={formData.imageUrl} 
                        alt="Featured"
                        className="w-full h-full object-cover"
                        onError={(e) => {
                          (e.target as HTMLImageElement).style.display = 'none'
                        }}
                      />
                    </div>
                  )}
                  {formData.title && (
                    <h2 className="text-xl font-bold text-gray-900 dark:text-white">
                      {formData.title}
                    </h2>
                  )}
                  {formData.description && (
                    <p className="text-sm text-gray-600 dark:text-gray-300 line-clamp-3">
                      {formData.description}
                    </p>
                  )}
                </div>
              ) : (
                <div className="py-4 border-b border-gray-200 dark:border-gray-700 text-center">
                  <p className="text-sm text-gray-400 italic">News title and description will appear here</p>
                </div>
              )}

              {/* Contents Preview */}
              {contents.length > 0 && (
                <div className="space-y-4">
                  <h4 className="font-medium text-gray-800 dark:text-white text-sm">Contents:</h4>
                  {contents.map((content, index) => (
                    <div key={content.id} className="border border-gray-200 dark:border-gray-700 rounded-lg p-3">
                      {content.title && (
                        <h5 className="font-medium text-gray-900 dark:text-white mb-1 text-sm">
                          {content.title}
                        </h5>
                      )}
                      {content.description && (
                        <p className="text-xs text-gray-600 dark:text-gray-300 mb-2 line-clamp-2">
                          {content.description}
                        </p>
                      )}
                      {content.type === 'image' && content.imageUrl && (
                        <div className="w-full aspect-video bg-gray-100 dark:bg-gray-800 rounded overflow-hidden">
                          <img 
                            src={content.imageUrl} 
                            alt={content.title}
                            className="w-full h-full object-cover"
                            onError={(e) => {
                              (e.target as HTMLImageElement).style.display = 'none'
                            }}
                          />
                        </div>
                      )}
                      {content.type === 'video' && content.videoUrl && (
                        <div className="w-full aspect-video bg-gray-100 dark:bg-gray-800 rounded flex items-center justify-center">
                          <svg width="24" height="24" viewBox="0 0 24 24" fill="none" className="text-gray-400">
                            <path d="M8 5V19L19 12L8 5Z" fill="currentColor"/>
                          </svg>
                        </div>
                      )}
                      <div className="mt-2">
                        <span className="inline-block px-2 py-0.5 text-xs font-medium rounded bg-gray-100 dark:bg-gray-800 text-gray-600 dark:text-gray-400">
                          {content.type}
                        </span>
                      </div>
                    </div>
                  ))}
                </div>
              )}

              {contents.length === 0 && (
                <div className="py-8 text-center">
                  <p className="text-sm text-gray-400 italic">Add content sections to see preview</p>
                </div>
              )}
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

