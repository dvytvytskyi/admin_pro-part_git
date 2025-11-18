'use client'
import { useState, useEffect } from 'react'
import { api } from '@/lib/api'
import Button from '@/components/ui/button/Button'
import Input from '@/components/form/input/InputField'
import { Modal } from '@/components/ui/modal'

export default function IntegrationsPage() {
  const [apiKeys, setApiKeys] = useState<any[]>([])
  const [loading, setLoading] = useState(true)
  const [showCreateModal, setShowCreateModal] = useState(false)
  const [showKeyModal, setShowKeyModal] = useState(false)
  const [newKeyName, setNewKeyName] = useState('')
  const [creating, setCreating] = useState(false)
  const [newApiKey, setNewApiKey] = useState<any>(null)
  const [deletingId, setDeletingId] = useState<string | null>(null)
  const [showDeleteModal, setShowDeleteModal] = useState(false)
  const [keyToDelete, setKeyToDelete] = useState<any>(null)

  useEffect(() => {
    // Log token status for debugging
    if (typeof window !== 'undefined') {
      const token = localStorage.getItem('token')
      console.log('Token exists:', !!token, 'Token length:', token?.length || 0)
    }
    loadApiKeys()
  }, [])

  const loadApiKeys = async () => {
    try {
      // Check if token exists
      const token = typeof window !== 'undefined' ? localStorage.getItem('token') : null
      if (!token) {
        console.warn('No token found, redirecting to login...')
        if (typeof window !== 'undefined') {
          const currentOrigin = window.location.origin;
          window.location.href = `${currentOrigin}/login`;
        }
        return
      }

      setLoading(true)
      const response = await api.get('/settings/api-keys')
      setApiKeys(response.data.data || [])
    } catch (error: any) {
      console.error('Error loading API keys:', error)
      if (error.response?.status === 401) {
        console.warn('Unauthorized, redirecting to login...')
        if (typeof window !== 'undefined') {
          const currentOrigin = window.location.origin;
          window.location.href = `${currentOrigin}/login`;
        }
      }
    } finally {
      setLoading(false)
    }
  }

  const handleCreate = async () => {
    try {
      setCreating(true)
      const response = await api.post('/settings/api-keys', { name: newKeyName || undefined })
      setNewApiKey(response.data.data)
      setShowCreateModal(false)
      setShowKeyModal(true)
      setNewKeyName('')
      await loadApiKeys()
    } catch (error: any) {
      console.error('Error creating API key:', error)
      const errorMessage = error.response?.data?.message || error.message || 'Failed to create API key. Please make sure the backend server is running.'
      alert(errorMessage)
    } finally {
      setCreating(false)
    }
  }

  const handleDeleteClick = (key: any) => {
    setKeyToDelete(key)
    setShowDeleteModal(true)
  }

  const handleConfirmDelete = async () => {
    if (!keyToDelete) return

    try {
      setDeletingId(keyToDelete.id)
      await api.delete(`/settings/api-keys/${keyToDelete.id}`)
      setShowDeleteModal(false)
      setKeyToDelete(null)
      await loadApiKeys()
    } catch (error: any) {
      console.error('Error deleting API key:', error)
      alert('Failed to delete API key')
    } finally {
      setDeletingId(null)
    }
  }

  const handleCancelDelete = () => {
    setShowDeleteModal(false)
    setKeyToDelete(null)
  }

  const handleToggleActive = async (key: any) => {
    try {
      await api.patch(`/settings/api-keys/${key.id}/toggle`)
      await loadApiKeys()
    } catch (error: any) {
      console.error('Error toggling API key:', error)
      alert('Failed to toggle API key')
    }
  }

  const copyToClipboard = (text: string) => {
    navigator.clipboard.writeText(text)
    alert('Copied to clipboard!')
  }

  const formatDate = (date: string) => {
    return new Date(date).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
    })
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-semibold text-gray-800 dark:text-white">
            Integrations
          </h1>
          <p className="text-sm text-gray-500 dark:text-gray-400 mt-1">
            Manage API keys for external integrations (website, mobile app, etc.)
          </p>
        </div>
        <Button onClick={() => setShowCreateModal(true)}>
          Create API Key
        </Button>
      </div>

      <div className="rounded-xl border border-gray-200 bg-white p-6 shadow-theme-xs dark:border-gray-800 dark:bg-gray-900">
        {loading ? (
          <div className="text-center py-12 text-gray-500 dark:text-gray-400">
            <div className="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-gray-900 dark:border-white"></div>
            <p className="mt-4">Loading API keys...</p>
          </div>
        ) : apiKeys.length === 0 ? (
          <div className="text-center py-12 text-gray-500 dark:text-gray-400">
            <svg
              className="mx-auto h-12 w-12 text-gray-400 dark:text-gray-500"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={2}
                d="M15 7a2 2 0 012 2m4 0a6 6 0 01-7.743 5.743L11 17H9v2H7v2H4a1 1 0 01-1-1v-2.586a1 1 0 01.293-.707l5.964-5.964A6 6 0 1121 9z"
              />
            </svg>
            <h3 className="mt-4 text-lg font-medium text-gray-900 dark:text-white">No API keys</h3>
            <p className="mt-2 text-sm text-gray-500 dark:text-gray-400">
              Get started by creating a new API key.
            </p>
            <div className="mt-6">
              <Button onClick={() => setShowCreateModal(true)}>
                Create API Key
              </Button>
            </div>
          </div>
        ) : (
          <div className="space-y-4">
            {apiKeys.map((key) => (
              <div
                key={key.id}
                className="rounded-lg border border-gray-200 bg-white p-6 dark:border-gray-700 dark:bg-gray-800 hover:border-gray-300 dark:hover:border-gray-600 transition-colors"
              >
                <div className="flex items-start justify-between">
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-3 mb-3">
                      <h3 className="text-lg font-semibold text-gray-900 dark:text-white">
                        {key.name || 'Untitled API Key'}
                      </h3>
                      <span
                        className={`px-2.5 py-1 text-xs font-medium rounded-full ${
                          key.isActive
                            ? 'bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-400'
                            : 'bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-400'
                        }`}
                      >
                        {key.isActive ? 'Active' : 'Inactive'}
                      </span>
                    </div>
                    <div className="space-y-2">
                      <div className="flex items-center gap-2">
                        <span className="text-sm font-medium text-gray-700 dark:text-gray-300">API Key:</span>
                        <code className="flex-1 bg-gray-50 dark:bg-gray-900 px-3 py-1.5 rounded-md text-sm font-mono text-gray-800 dark:text-gray-200 border border-gray-200 dark:border-gray-700">
                          {key.apiKey}
                        </code>
                        <button
                          onClick={() => copyToClipboard(key.apiKey)}
                          className="px-3 py-1.5 text-sm text-blue-600 hover:text-blue-700 dark:text-blue-400 dark:hover:text-blue-300 hover:bg-blue-50 dark:hover:bg-blue-900/20 rounded-md transition-colors"
                          title="Copy to clipboard"
                        >
                          <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z" />
                          </svg>
                        </button>
                      </div>
                      <div className="flex items-center gap-4 text-xs text-gray-500 dark:text-gray-400">
                        {key.lastUsedAt ? (
                          <span>Last used: {formatDate(key.lastUsedAt)}</span>
                        ) : (
                          <span className="text-gray-400 dark:text-gray-500">Never used</span>
                        )}
                        <span>•</span>
                        <span>Created: {formatDate(key.createdAt)}</span>
                      </div>
                    </div>
                  </div>
                  <div className="flex items-center gap-2 ml-4">
                    <button
                      onClick={() => handleToggleActive(key)}
                      className={`px-4 py-2 text-sm font-medium rounded-lg transition-colors ${
                        key.isActive
                          ? 'bg-gray-100 text-gray-700 hover:bg-gray-200 dark:bg-gray-700 dark:text-gray-300 dark:hover:bg-gray-600'
                          : 'bg-green-100 text-green-700 hover:bg-green-200 dark:bg-green-900/30 dark:text-green-400 dark:hover:bg-green-900/40'
                      }`}
                    >
                      {key.isActive ? 'Deactivate' : 'Activate'}
                    </button>
                    <button
                      onClick={() => handleDeleteClick(key)}
                      className="px-4 py-2 text-sm font-medium rounded-lg bg-error-100 text-error-700 hover:bg-error-200 dark:bg-error-900/30 dark:text-error-400 dark:hover:bg-error-900/40 transition-colors"
                    >
                      Delete
                    </button>
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* API Documentation Link */}
      <div className="rounded-xl border border-blue-200 bg-blue-50 dark:border-blue-900 dark:bg-blue-900/20 p-6">
        <div className="flex items-start gap-3">
          <svg
            className="h-6 w-6 text-blue-600 dark:text-blue-400 flex-shrink-0 mt-0.5"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth={2}
              d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
            />
          </svg>
          <div className="flex-1">
            <h3 className="text-lg font-semibold text-blue-900 dark:text-blue-400 mb-2">
              API Documentation
            </h3>
            <p className="text-sm text-blue-800 dark:text-blue-300 mb-4">
              View complete API documentation with schemas, examples, and integration guides for all endpoints.
            </p>
            <a
              href="/integrations/docs"
              className="inline-flex items-center gap-2 px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg transition-colors text-sm font-medium"
            >
              <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
              </svg>
              View Full Documentation
            </a>
          </div>
        </div>
      </div>

      {/* Create API Key Modal */}
      <Modal
        isOpen={showCreateModal}
        onClose={() => {
          setShowCreateModal(false)
          setNewKeyName('')
        }}
        className=""
      >
        <div className="p-6 sm:p-8">
          <div className="mb-6">
            <h2 className="text-2xl font-semibold text-gray-900 dark:text-white mb-2">
              Create API Key
            </h2>
            <p className="text-sm text-gray-500 dark:text-gray-400">
              Generate a new API key for external integrations
            </p>
          </div>
          
          <div className="space-y-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Name <span className="text-gray-400 dark:text-gray-500 font-normal">(optional)</span>
              </label>
              <Input
                value={newKeyName}
                onChange={(e) => setNewKeyName(e.target.value)}
                placeholder="e.g., Production Website, Mobile App"
                onKeyDown={(e) => {
                  if (e.key === 'Enter' && !creating && newKeyName.trim()) {
                    handleCreate()
                  }
                }}
                className="w-full"
              />
              <p className="mt-2 text-xs text-gray-500 dark:text-gray-400">
                Give your API key a descriptive name to easily identify it later.
              </p>
            </div>
            
            <div className="flex gap-3 justify-end pt-6 border-t border-gray-200 dark:border-gray-700">
              <Button
                variant="outline"
                onClick={() => {
                  setShowCreateModal(false)
                  setNewKeyName('')
                }}
                disabled={creating}
              >
                Cancel
              </Button>
              <Button 
                onClick={handleCreate} 
                disabled={creating || !newKeyName.trim()}
                className="min-w-[100px]"
              >
                {creating ? (
                  <>
                    <svg className="animate-spin h-4 w-4 mr-2 inline" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                      <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                      <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                    </svg>
                    Creating...
                  </>
                ) : (
                  'Create'
                )}
              </Button>
            </div>
          </div>
        </div>
      </Modal>

      {/* Show New API Key Modal */}
      <Modal
        isOpen={showKeyModal}
        onClose={() => {
          setShowKeyModal(false)
          setNewApiKey(null)
        }}
        className=""
      >
        <div className="p-6 sm:p-8">
          <div className="mb-6">
            <h2 className="text-2xl font-semibold text-gray-900 dark:text-white mb-2">
              API Key Created Successfully
            </h2>
            <p className="text-sm text-gray-500 dark:text-gray-400">
              Save these credentials in a secure location
            </p>
          </div>
          
          <div className="space-y-6">
            <div className="bg-yellow-50 dark:bg-yellow-900/20 border border-yellow-200 dark:border-yellow-800 rounded-lg p-4">
              <div className="flex items-start gap-3">
                <svg
                  className="h-5 w-5 text-yellow-600 dark:text-yellow-400 flex-shrink-0 mt-0.5"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={2}
                    d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"
                  />
                </svg>
                <div>
                  <p className="text-sm font-medium text-yellow-800 dark:text-yellow-300">
                    Important: Save your credentials now
                  </p>
                  <p className="text-xs text-yellow-700 dark:text-yellow-400 mt-1">
                    The API Secret will only be shown once. Make sure to copy and store it securely.
                  </p>
                </div>
              </div>
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                API Key
              </label>
              <div className="flex items-center gap-2">
                <code className="flex-1 bg-gray-50 dark:bg-gray-800 px-4 py-3 rounded-lg text-sm font-mono text-gray-900 dark:text-gray-100 border border-gray-200 dark:border-gray-700 break-all">
                  {newApiKey?.apiKey}
                </code>
                <button
                  onClick={() => copyToClipboard(newApiKey?.apiKey)}
                  className="px-4 py-3 bg-blue-600 hover:bg-blue-700 text-white rounded-lg transition-colors flex-shrink-0 shadow-sm hover:shadow-md"
                  title="Copy to clipboard"
                >
                  <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z" />
                  </svg>
                </button>
              </div>
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                API Secret
              </label>
              <div className="flex items-center gap-2">
                <code className="flex-1 bg-gray-50 dark:bg-gray-800 px-4 py-3 rounded-lg text-sm font-mono text-gray-900 dark:text-gray-100 border border-gray-200 dark:border-gray-700 break-all">
                  {newApiKey?.apiSecret}
                </code>
                <button
                  onClick={() => copyToClipboard(newApiKey?.apiSecret)}
                  className="px-4 py-3 bg-blue-600 hover:bg-blue-700 text-white rounded-lg transition-colors flex-shrink-0 shadow-sm hover:shadow-md"
                  title="Copy to clipboard"
                >
                  <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z" />
                  </svg>
                </button>
              </div>
            </div>
            
            <div className="flex gap-3 justify-end pt-6 border-t border-gray-200 dark:border-gray-700">
              <Button
                onClick={() => {
                  setShowKeyModal(false)
                  setNewApiKey(null)
                }}
                className="min-w-[180px]"
              >
                I&apos;ve Saved My Credentials
              </Button>
            </div>
          </div>
        </div>
      </Modal>

      {/* Delete Confirmation Modal */}
      <Modal
        isOpen={showDeleteModal}
        onClose={handleCancelDelete}
        className=""
      >
        <div className="p-6 sm:p-8">
          <div className="mb-6">
            <h2 className="text-2xl font-semibold text-gray-900 dark:text-white mb-2">
              Delete API Key
            </h2>
            <p className="text-sm text-gray-500 dark:text-gray-400">
              This action cannot be undone
            </p>
          </div>
          
          <div className="space-y-6">
            <div>
              <p className="text-gray-700 dark:text-gray-300 mb-4">
                Are you sure you want to delete the API key <strong className="text-gray-900 dark:text-white font-semibold">{keyToDelete?.name || 'Untitled API Key'}</strong>?
              </p>
              <div className="bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-lg p-4">
                <div className="flex items-start gap-3">
                  <svg
                    className="h-5 w-5 text-red-600 dark:text-red-400 flex-shrink-0 mt-0.5"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                  >
                    <path
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      strokeWidth={2}
                      d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"
                    />
                  </svg>
                  <p className="text-sm text-red-800 dark:text-red-300">
                    This action cannot be undone and will immediately revoke access for all applications using this key.
                  </p>
                </div>
              </div>
            </div>
            
            <div className="flex gap-3 justify-end pt-6 border-t border-gray-200 dark:border-gray-700">
              <Button
                variant="outline"
                onClick={handleCancelDelete}
                disabled={deletingId !== null}
              >
                Cancel
              </Button>
              <Button
                onClick={handleConfirmDelete}
                disabled={deletingId !== null}
                className="bg-error-600 hover:bg-error-700 text-white min-w-[120px]"
              >
                {deletingId !== null ? (
                  <>
                    <svg className="animate-spin h-4 w-4 mr-2 inline" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                      <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                      <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                    </svg>
                    Deleting...
                  </>
                ) : (
                  'Delete'
                )}
              </Button>
            </div>
          </div>
        </div>
      </Modal>
    </div>
  )
}

