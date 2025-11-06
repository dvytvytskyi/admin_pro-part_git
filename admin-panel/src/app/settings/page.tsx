'use client'
import { useState, useEffect, useCallback } from 'react'
import { api } from '@/lib/api'
import axios from 'axios'
import Tabs from '@/components/ui/tabs/Tabs'
import Button from '@/components/ui/button/Button'
import Input from '@/components/form/input/InputField'
import { Modal } from '@/components/ui/modal'
import { Tooltip } from '@/components/ui/tooltip/Tooltip'
import TextArea from '@/components/form/input/TextArea'

export default function SettingsPage() {
  const [developers, setDevelopers] = useState<any[]>([])
  const [facilities, setFacilities] = useState<any[]>([])
  const [countries, setCountries] = useState<any[]>([])
  const [cities, setCities] = useState<any[]>([])
  const [areas, setAreas] = useState<any[]>([])

  useEffect(() => {
    // Log token status for debugging
    if (typeof window !== 'undefined') {
      const token = localStorage.getItem('token');
      console.log('Token exists:', !!token, 'Token length:', token?.length || 0);
    }
    loadData()
  }, [])

  const loadData = async () => {
    try {
      // Check if token exists
      const token = typeof window !== 'undefined' ? localStorage.getItem('token') : null;
      if (!token) {
        console.warn('No token found, redirecting to login...');
        if (typeof window !== 'undefined') {
          window.location.href = '/login';
        }
        return;
      }

      const [devs, facs, locations] = await Promise.all([
        api.get('/settings/developers').catch((err) => {
          console.error('Error loading developers:', err.response?.data || err.message);
          if (err.response?.status === 401) {
            console.warn('Unauthorized, redirecting to login...');
            if (typeof window !== 'undefined') {
              window.location.href = '/login';
            }
          }
          return { data: { data: [] } };
        }),
        api.get('/settings/facilities').catch((err) => {
          console.error('Error loading facilities:', err.response?.data || err.message);
          return { data: { data: [] } };
        }),
        api.get('/settings/locations').catch((err) => {
          console.error('Error loading locations:', err.response?.data || err.message);
          return { data: { data: [] } };
        }),
      ])
      
      console.log('Loaded developers:', devs.data?.data?.length || 0);
      const developersData = devs.data?.data || []
      
      // Log sample developer data to verify structure
      if (developersData.length > 0) {
        const sampleDev = developersData.find((d: any) => d.logo || d.description || d.images)
        if (sampleDev) {
          console.log('Sample developer with data:', {
            name: sampleDev.name,
            hasLogo: !!sampleDev.logo,
            logo: sampleDev.logo?.substring(0, 50),
            hasDescription: !!sampleDev.description,
            description: sampleDev.description?.substring(0, 50),
            hasImages: !!sampleDev.images,
            imagesType: typeof sampleDev.images,
            imagesIsArray: Array.isArray(sampleDev.images),
            imagesLength: sampleDev.images?.length
          })
        }
      }
      
      setDevelopers(developersData)
      setFacilities(facs.data?.data || [])
      setCountries(locations.data?.data?.countries || [])
      setCities(locations.data?.data?.cities || [])
      setAreas(locations.data?.data?.areas || [])
    } catch (error) {
      console.error('Error loading settings:', error)
    }
  }

  const tabs = [
    {
      key: 'developers',
      label: 'Developers',
      children: <DevelopersTab developers={developers} onReload={loadData} />,
    },
    {
      key: 'facilities',
      label: 'Facilities',
      children: <FacilitiesTab facilities={facilities} onReload={loadData} />,
    },
    {
      key: 'locations',
      label: 'Locations',
      children: (
        <LocationsTab
          countries={countries}
          cities={cities}
          areas={areas}
          onReload={loadData}
        />
      ),
    },
  ]

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-semibold text-gray-800 dark:text-white">
        Settings
      </h1>
      <div className="rounded-xl border border-gray-200 bg-white p-6 dark:border-gray-800 dark:bg-gray-900">
        <Tabs items={tabs} />
      </div>
    </div>
  )
}

// Developers Tab
function DevelopersTab({ developers, onReload }: any) {
  const [newDeveloper, setNewDeveloper] = useState('')
  const [currentPage, setCurrentPage] = useState(1)
  const [deletingId, setDeletingId] = useState<string | null>(null)
  const [showDeleteModal, setShowDeleteModal] = useState(false)
  const [developerToDelete, setDeveloperToDelete] = useState<any>(null)
  const [hasAutoLoaded, setHasAutoLoaded] = useState(false)
  const [addingDeveloper, setAddingDeveloper] = useState(false)
  const [cleaningUp, setCleaningUp] = useState(false)
  const [searchQuery, setSearchQuery] = useState('')
  
  // Developer edit modal state
  const [showEditDeveloperModal, setShowEditDeveloperModal] = useState(false)
  const [editingDeveloper, setEditingDeveloper] = useState<any>(null)
  const [developerDescription, setDeveloperDescription] = useState('')
  const [developerLogo, setDeveloperLogo] = useState('')
  const [developerImages, setDeveloperImages] = useState<string[]>([])
  const [uploadingImage, setUploadingImage] = useState(false)
  const [savingDeveloper, setSavingDeveloper] = useState(false)
  
  // Helper to check if button should be enabled
  const hasValidInput = newDeveloper && newDeveloper.trim().length > 0
  const isButtonDisabled = addingDeveloper || !hasValidInput
  const itemsPerPage = 100
  
  // Reset addingDeveloper state on mount (in case it was stuck)
  useEffect(() => {
    setAddingDeveloper(false)
  }, [])
  
  // Reset addingDeveloper state if it gets stuck (safety mechanism)
  useEffect(() => {
    if (addingDeveloper) {
      const timer = setTimeout(() => {
        console.warn('Adding developer timeout - resetting state')
        setAddingDeveloper(false)
      }, 10000) // 10 seconds timeout
      return () => clearTimeout(timer)
    }
  }, [addingDeveloper])
  
  // Debug: log state changes
  useEffect(() => {
    console.log('Developer input state:', { 
      newDeveloper, 
      hasValidInput, 
      addingDeveloper, 
      isButtonDisabled 
    })
  }, [newDeveloper, hasValidInput, addingDeveloper, isButtonDisabled])

  const predefinedDevelopers = [
    "7th Key",
    "A S I Real Estate Development",
    "AB Developers",
    "ABA Real Estate Development",
    "ADE Properties",
    "AHS Properties",
    "AMBER Developments",
    "AMBS Real Estate Development",
    "AMIS Properties",
    "AMWAJ Development",
    "ARADA",
    "ARIB Developments",
    "AUM Development",
    "AYAT Development",
    "AYS Property Development",
    "Abou Eid Real Estate Development",
    "Aces Property Development L.L.C",
    "Acube Developers",
    "Ag Properties",
    "Ahmadyar Real Estate Development",
    "Al Ali Property Investment",
    "Al Habtoor Group",
    "Al Mawared Properties",
    "Al Sayyah Group",
    "Al Seeb Real Estate Development",
    "Al Tareq Star Real Estate Development",
    "Alaia Developments",
    "Albait Al Duwaliy Real Estate Development",
    "Aldar",
    "Alta Real Estate Development",
    "Amaal Development",
    "Amirah Developments",
    "Anax Developments",
    "Aqua",
    "Arabian Gulf Properties",
    "Arady Properties",
    "Aras Development",
    "Arete Developments",
    "Arista Properties",
    "Arsenal East",
    "Atmosphere Living",
    "Avelon Developments",
    "Avenew Development",
    "Azizi",
    "B N H Real Estate Developer",
    "BT Properties",
    "Barco Developers",
    "Beyond",
    "Binghatti",
    "Black Soil",
    "Bling Development",
    "Bloom Heights Properties L.L.C",
    "BnW Developments",
    "Bold Living",
    "Bonyan International Investment Group",
    "C Fourteen",
    "CDS Developments",
    "Calgary Properties",
    "Casa Vista & Golden Woods Developers",
    "Casa Vista Development",
    "Casagrand",
    "Centurion Development",
    "Cirrera Development",
    "Citi Developers",
    "City View Development",
    "Condor",
    "Confident Group",
    "Credo Investments",
    "Crystal Bay Development",
    "DECA Development",
    "DHG Real Estate Group",
    "DMCC",
    "DV8 Developers",
    "Damac",
    "Danube",
    "Dar Al Arkan Properties",
    "Dar Al Karama",
    "DarGlobal",
    "Deyaar",
    "Dubai Properties",
    "Dubai South",
    "Dugasta Properties Development",
    "EMS Development",
    "ENSO",
    "East & West Properties",
    "Ellington",
    "Elton Real Estate Development",
    "Elysian Development",
    "Emaar Properties",
    "Emirates National Investment",
    "Empire Developments",
    "Escan Real Estate",
    "Ever Glory Developments",
    "Expo City",
    "FIM Partners",
    "Fakhruddin Properties",
    "Five Holdings",
    "Fortune 5",
    "Forum Real Estate Development",
    "GJ Properties",
    "Galaxy Realty",
    "Gemini Property Developers",
    "Ginco Properties",
    "Glorious Future",
    "Golden Woods",
    "Green Group",
    "Green Horizon Development",
    "Green Yard Properties Development",
    "Grid Properties",
    "Grovy Real Estate Development",
    "Gulf House Real Estate Development",
    "Gulf Land Property Developers",
    "H&H Development",
    "HMB Homes",
    "HRE Development",
    "HZ Development",
    "Hayaat Developments",
    "Heilbronn Properties Ltd.",
    "IGO",
    "IKR Development",
    "Iman Developers",
    "Imtiaz",
    "Infracorp",
    "Iquna Properties",
    "Iraz Developments",
    "Irth Development",
    "Ithra Dubai",
    "Januss Developers",
    "Kappa Acca Real Estate Development",
    "Karma Development",
    "Kasco Real Estate Development",
    "Khamas Group",
    "LIV",
    "LMD",
    "Lamar Development",
    "Lapis Properties",
    "Laraix",
    "Laya Developers",
    "Leos Development",
    "London Gate",
    "Lucky Aeon",
    "MAAIA Developers",
    "MAG Property Development",
    "MAK Developers",
    "MERED",
    "MS Homes",
    "MVS Real Estate Development",
    "Maakdream Properties",
    "Mada'in",
    "Madar Developments",
    "Majid Al Futtaim",
    "Majid Developments",
    "Major Developments",
    "Manam RED",
    "Manchester Real Estate",
    "Marquis",
    "Mashriq Elite Real Estate Development",
    "Me Do Re",
    "Meraas",
    "Meraki Developers",
    "Metac Development",
    "Meteora",
    "Mill Hill",
    "Mira Developments",
    "Mr. Eight",
    "Mulk Properties",
    "Muraba Properties",
    "Myra Properties",
    "NED Properties",
    "Nabni",
    "Nakheel",
    "Naseeb Group",
    "National Properties",
    "New MFOUR Real Estate Development",
    "Newbury Developments",
    "Nexus",
    "Nshama",
    "Nuri Living",
    "OCTA Development",
    "ONE YARD",
    "Object One",
    "Oksa Developer",
    "Omniyat",
    "One Development",
    "Orange.Life!",
    "Oro 24",
    "PG Properties",
    "Palladium Development",
    "Palma Development",
    "Pantheon",
    "Pasha 1",
    "Peace Homes Development",
    "Peak Summit Real Estate Development",
    "Pearlshire",
    "Pinnacle A K S Real Estate Development",
    "Premier Choice",
    "Prescott Development",
    "Prestige One",
    "QUBE Development",
    "Rabdan Real Estate Developments",
    "Rashed Aljabri",
    "Reef Luxury Developments",
    "Regent Developments",
    "Reportage",
    "Rijas Developers",
    "Riviera Group",
    "Roz Real Estate Development",
    "Rvl Real Estate",
    "S&S Developments",
    "SAAS",
    "SABA Properties",
    "SCC Vertex Development",
    "SIDO Developer",
    "SOL Properties",
    "SOL Properties (managed by You&Co)",
    "SRG",
    "Sama Ezdan",
    "Samana",
    "Sankari Property",
    "Segrex Development",
    "Select Group",
    "Seven Tides",
    "Shakirov Developments",
    "Siroya",
    "Skyline Builders",
    "Sobha",
    "Stamn Development",
    "Svarn Development",
    "Swank Development",
    "Swiss Property",
    "Symbolic Developments",
    "Tabeer",
    "Taraf",
    "Tarrad Development",
    "Tasmeer Indigo Properties",
    "Tebyan Real Estate Development Enterprises",
    "The 100",
    "The Developer Properties",
    "The First Group",
    "The Heart of Europe",
    "Tiger Properties",
    "Time Properties",
    "Tomorrow World Properties",
    "Topero Properties",
    "TownX",
    "Tranquil Infra Developers",
    "Triplanet Range Developements",
    "True Future Real Estate Development",
    "UniEstate Properties",
    "Union Properties",
    "Unique Saray",
    "Urban Properties",
    "Urban Venture",
    "Vakson First Property Development",
    "Valores Property Development",
    "Vantage Developments",
    "Vantage Ventures",
    "Vincitore",
    "Vision developments",
    "WELL Concept RED",
    "Wadan Developments",
    "Wasl",
    "Wellington Developments",
    "West F5 Development",
    "Yas Developers",
    "Zenith Ventures Real Estate Development",
    "Zimaya Properties",
    "Zumurud Real Estate - Sole Proprietorship"
  ]

  const handleAdd = async () => {
    console.log('handleAdd called', { newDeveloper, addingDeveloper })
    
    if (!newDeveloper || !newDeveloper.trim()) {
      alert('Please enter a developer name')
      return
    }
    
    if (addingDeveloper) {
      console.log('Already adding, ignoring')
      return // Prevent double submission
    }
    
    const developerName = newDeveloper.trim()
    console.log('Setting addingDeveloper to true')
    setAddingDeveloper(true)
    
    try {
      console.log('Adding developer:', developerName)
      
      // Try to add developer
      const response = await api.post('/settings/developers', { name: developerName })
      console.log('Success:', response.data)
      
      if (response.data?.success !== false) {
        // Success - clear input and reload
        setNewDeveloper('')
        await onReload()
        setCurrentPage(1)
      } else {
        alert(response.data?.message || 'Failed to add developer')
      }
    } catch (error: any) {
      console.error('Error adding developer:', error)
      console.error('Error response:', error.response)
      
      // Check if it's an auth error
      if (error.response?.status === 401 || error.response?.status === 403) {
        alert('Please log in to add developers')
        if (typeof window !== 'undefined') {
          window.location.href = '/login'
        }
        return
      }
      
      const errorMessage = error.response?.data?.message || error.message || 'Failed to add developer'
      alert(errorMessage)
    } finally {
      console.log('Setting addingDeveloper to false')
      setAddingDeveloper(false)
    }
  }

  const handleLoadPredefined = useCallback(async () => {
    try {
      const existingNames = new Set(developers.map((d: any) => d.name))
      const toAdd = predefinedDevelopers.filter(name => !existingNames.has(name))
      
      if (toAdd.length === 0) {
        return
      }
      
      // Add all developers in parallel, but ignore duplicates (409 errors)
      const results = await Promise.allSettled(
        toAdd.map(name => api.post('/settings/developers', { name }))
      )
      
      // Log any errors except duplicate errors (409)
      results.forEach((result, index) => {
        if (result.status === 'rejected') {
          const status = result.reason?.response?.status
          if (status !== 409) {
            console.error(`Error adding developer "${toAdd[index]}":`, result.reason)
          }
        }
      })
      
      onReload()
    } catch (error) {
      console.error('Error loading predefined developers:', error)
    }
  }, [developers, onReload])

  const handleDeleteClick = (dev: any) => {
    setDeveloperToDelete(dev)
    setShowDeleteModal(true)
  }

  const handleConfirmDelete = async () => {
    if (!developerToDelete) return
    
    setDeletingId(developerToDelete.id)
    try {
      await api.delete(`/settings/developers/${developerToDelete.id}`)
      setShowDeleteModal(false)
      setDeveloperToDelete(null)
      
      // Adjust page if current page becomes empty after deletion
      const newTotalPages = Math.ceil((developers.length - 1) / itemsPerPage)
      if (currentPage > newTotalPages && newTotalPages > 0) {
        setCurrentPage(newTotalPages)
      }
      
      onReload()
    } catch (error) {
      console.error('Error deleting developer:', error)
    } finally {
      setDeletingId(null)
    }
  }

  const handleCancelDelete = () => {
    setShowDeleteModal(false)
    setDeveloperToDelete(null)
  }

  const handleCleanupDuplicates = async () => {
    if (!confirm('This will remove all duplicate developers, keeping only one of each name. Continue?')) {
      return
    }

    setCleaningUp(true)
    try {
      const { data } = await api.post('/settings/developers/cleanup-duplicates')
      alert(`Success! Removed ${data.data.deleted} duplicates. Kept ${data.data.kept} unique developers.`)
      onReload()
      setCurrentPage(1)
    } catch (error: any) {
      console.error('Error cleaning up duplicates:', error)
      alert(error.response?.data?.message || 'Failed to clean up duplicates')
    } finally {
      setCleaningUp(false)
    }
  }

  const handleEditDeveloperClick = (developer: any) => {
    console.log('Opening developer modal with data:', developer)
    
    // Ensure images is an array (TypeORM simple-array might return string)
    let images = developer.images || []
    if (typeof images === 'string') {
      // If it's a string (comma-separated), split it
      images = images.split(',').filter((url: string) => url.trim())
    } else if (!Array.isArray(images)) {
      images = []
    }
    
    setEditingDeveloper(developer)
    setDeveloperDescription(developer.description || '')
    setDeveloperLogo(developer.logo || '')
    setDeveloperImages(images)
    setShowEditDeveloperModal(true)
  }

  const handleCloseEditDeveloperModal = () => {
    setShowEditDeveloperModal(false)
    setEditingDeveloper(null)
    setDeveloperDescription('')
    setDeveloperLogo('')
    setDeveloperImages([])
  }

  const handleDeveloperImageUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const files = e.target.files
    if (!files || files.length === 0) return

    setUploadingImage(true)
    try {
      const formData = new FormData()
      Array.from(files).forEach((file) => {
        formData.append('files', file)
      })

      const token = typeof window !== 'undefined' ? localStorage.getItem('token') : null
      const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:4000/api'
      const { data } = await axios.post(`${API_URL}/upload/images`, formData, {
        headers: {
          'Content-Type': 'multipart/form-data',
          ...(token && { Authorization: `Bearer ${token}` }),
        },
      })

      const newUrls = data?.data?.urls || data?.urls || []
      setDeveloperImages([...developerImages, ...newUrls])
    } catch (error: any) {
      console.error('Error uploading images:', error)
      alert(error.response?.data?.message || 'Error uploading photos')
    } finally {
      setUploadingImage(false)
      e.target.value = ''
    }
  }

  const handleRemoveDeveloperImage = (index: number) => {
    setDeveloperImages(developerImages.filter((_, i) => i !== index))
  }

  const handleSaveDeveloper = async () => {
    if (!editingDeveloper) return

    setSavingDeveloper(true)
    try {
      await api.put(`/settings/developers/${editingDeveloper.id}`, {
        name: editingDeveloper.name,
        logo: developerLogo,
        description: developerDescription,
        images: developerImages,
      })

      onReload()
      handleCloseEditDeveloperModal()
    } catch (error: any) {
      console.error('Error saving developer:', error)
      alert(error.response?.data?.message || 'Error saving developer')
    } finally {
      setSavingDeveloper(false)
    }
  }

  // Auto-load predefined developers on mount if list is empty (only once)
  useEffect(() => {
    // Only auto-load if list is empty and we haven't already attempted to load
    if (developers.length === 0 && !hasAutoLoaded) {
      setHasAutoLoaded(true)
      handleLoadPredefined()
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [])

  // Auto-populate modal fields when editingDeveloper changes
  useEffect(() => {
    if (editingDeveloper) {
      console.log('Auto-populating modal with developer data:', {
        name: editingDeveloper.name,
        hasLogo: !!editingDeveloper.logo,
        hasDescription: !!editingDeveloper.description,
        hasImages: !!editingDeveloper.images,
        imagesType: typeof editingDeveloper.images,
        imagesIsArray: Array.isArray(editingDeveloper.images),
        imagesValue: editingDeveloper.images
      })
      
      // Ensure images is an array (TypeORM simple-array might return string)
      let images = editingDeveloper.images || []
      if (typeof images === 'string') {
        // If it's a string (comma-separated), split it
        images = images.split(',').filter((url: string) => url.trim())
      } else if (!Array.isArray(images)) {
        images = []
      }
      
      console.log('Setting modal fields:', {
        description: editingDeveloper.description || '',
        logo: editingDeveloper.logo || '',
        images: images
      })
      
      setDeveloperDescription(editingDeveloper.description || '')
      setDeveloperLogo(editingDeveloper.logo || '')
      setDeveloperImages(images)
    }
  }, [editingDeveloper])

  // Filter developers based on search query
  const filteredDevelopers = developers.filter((dev: any) => {
    if (!searchQuery.trim()) return true
    const query = searchQuery.toLowerCase().trim()
    return dev.name.toLowerCase().includes(query)
  })

  // Reset to first page when search query changes
  useEffect(() => {
    setCurrentPage(1)
  }, [searchQuery])

  // Calculate pagination
  const totalPages = Math.ceil(filteredDevelopers.length / itemsPerPage)
  const startIndex = (currentPage - 1) * itemsPerPage
  const endIndex = startIndex + itemsPerPage
  const paginatedDevelopers = filteredDevelopers.slice(startIndex, endIndex)

  return (
    <>
      <div className="space-y-6">
        <div className="flex items-center gap-4">
          <Input
            type="text"
            placeholder="Developer name"
            value={newDeveloper}
            onChange={(e) => {
              const value = e.target.value
              console.log('Input changed:', value, 'trimmed length:', value.trim().length)
              setNewDeveloper(value)
              // Always reset addingDeveloper when user types (safety)
              if (addingDeveloper) {
                console.log('Resetting addingDeveloper state')
                setAddingDeveloper(false)
              }
            }}
            className="flex-1"
            onKeyDown={(e) => {
              if (e.key === 'Enter' && newDeveloper.trim() && !addingDeveloper) {
                handleAdd()
              }
            }}
          />
          <Tooltip 
            content="Please fill in the developer name field first" 
            disabled={hasValidInput || addingDeveloper}
          >
            <Button 
              onClick={handleAdd} 
              disabled={addingDeveloper || !hasValidInput}
              className="min-w-[100px]"
              type="button"
              style={{ 
                opacity: (addingDeveloper || !hasValidInput) ? 0.5 : 1,
                cursor: (addingDeveloper || !hasValidInput) ? 'not-allowed' : 'pointer'
              }}
            >
              {addingDeveloper ? (
                <>
                  <svg className="animate-spin h-4 w-4 mr-2 inline" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                    <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                    <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                  </svg>
                  Adding...
                </>
              ) : (
                'Add'
              )}
            </Button>
          </Tooltip>
        </div>


        {/* Search Bar */}
        <div className="relative">
          <div className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400">
            <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
              <path d="M7.33333 12.6667C10.2789 12.6667 12.6667 10.2789 12.6667 7.33333C12.6667 4.38781 10.2789 2 7.33333 2C4.38781 2 2 4.38781 2 7.33333C2 10.2789 4.38781 12.6667 7.33333 12.6667Z" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"/>
              <path d="M14 14L11.1 11.1" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"/>
            </svg>
          </div>
          <Input
            type="text"
            placeholder="Search developers..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="w-full pl-10 pr-10"
          />
          {searchQuery && (
            <button
              onClick={() => setSearchQuery('')}
              className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600 dark:hover:text-gray-300"
              title="Clear search"
            >
              <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
                <path d="M12 4L4 12M4 4l8 8" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/>
              </svg>
            </button>
          )}
        </div>

        {/* Search Results Info */}
        {searchQuery && (
          <div className="text-sm text-gray-500 dark:text-gray-400">
            {filteredDevelopers.length === 0 ? (
              <span>No developers found matching "{searchQuery}"</span>
            ) : (
              <span>Found {filteredDevelopers.length} developer{filteredDevelopers.length !== 1 ? 's' : ''} matching "{searchQuery}"</span>
            )}
          </div>
        )}

        <div className="space-y-2">
          {paginatedDevelopers.length === 0 ? (
            <p className="text-gray-500 dark:text-gray-400 text-center py-8">
              {searchQuery ? 'No developers found' : 'No developers'}
            </p>
          ) : (
            <>
              {paginatedDevelopers.map((dev: any) => (
                <div
                  key={dev.id}
                  className="flex items-center justify-between rounded-lg border border-gray-200 p-4 dark:border-gray-800 hover:bg-gray-50 dark:hover:bg-gray-800/50 transition-colors cursor-pointer"
                  onClick={() => handleEditDeveloperClick(dev)}
                >
                  <span className="text-gray-800 dark:text-white">{dev.name}</span>
                  <button
                    onClick={(e) => {
                      e.stopPropagation()
                      handleDeleteClick(dev)
                    }}
                    disabled={deletingId === dev.id}
                    className="text-error-500 hover:text-error-600 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
                  >
                    {deletingId === dev.id ? (
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
              ))}

              {/* Pagination */}
              {totalPages > 1 && (
                <div className="flex items-center justify-between pt-4 border-t border-gray-200 dark:border-gray-800">
                  <div className="text-sm text-gray-500 dark:text-gray-400">
                    Showing {startIndex + 1} to {Math.min(endIndex, filteredDevelopers.length)} of {filteredDevelopers.length} developer{filteredDevelopers.length !== 1 ? 's' : ''}
                    {searchQuery && ` (${developers.length} total)`}
                  </div>
                  <div className="flex items-center gap-2">
                    <Button
                      variant="outline"
                      size="sm"
                      onClick={() => setCurrentPage(prev => Math.max(1, prev - 1))}
                      disabled={currentPage === 1}
                    >
                      Previous
                    </Button>
                    <div className="text-sm text-gray-700 dark:text-gray-300">
                      Page {currentPage} of {totalPages}
                    </div>
                    <Button
                      variant="outline"
                      size="sm"
                      onClick={() => setCurrentPage(prev => Math.min(totalPages, prev + 1))}
                      disabled={currentPage === totalPages}
                    >
                      Next
                    </Button>
                  </div>
                </div>
              )}
            </>
          )}
        </div>
      </div>

      {/* Delete Confirmation Modal */}
      <Modal isOpen={showDeleteModal} onClose={handleCancelDelete} className="max-w-md m-4">
        <div className="p-6">
          <div className="flex items-start gap-4 mb-6">
            <div className="flex-shrink-0 w-12 h-12 rounded-full bg-error-100 dark:bg-error-900/20 flex items-center justify-center">
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" className="text-error-600 dark:text-error-400">
                <path d="M12 9V13M12 17H12.01M21 12C21 16.9706 16.9706 21 12 21C7.02944 21 3 16.9706 3 12C3 7.02944 7.02944 3 12 3C16.9706 3 21 7.02944 21 12Z" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/>
              </svg>
            </div>
            <div className="flex-1">
              <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-2">
                Delete Developer
              </h3>
              <p className="text-sm text-gray-600 dark:text-gray-400">
                Are you sure you want to delete <span className="font-medium text-gray-900 dark:text-white">"{developerToDelete?.name}"</span>? This action cannot be undone.
              </p>
            </div>
          </div>
          <div className="flex items-center justify-end gap-3">
            <Button
              variant="outline"
              onClick={handleCancelDelete}
              disabled={deletingId !== null}
            >
              No, Cancel
            </Button>
            <Button
              onClick={handleConfirmDelete}
              disabled={deletingId !== null}
              className="bg-error-600 hover:bg-error-700 text-white"
            >
              {deletingId !== null ? (
                <>
                  <svg className="animate-spin h-4 w-4 mr-2" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                    <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                    <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                  </svg>
                  Deleting...
                </>
              ) : (
                'Yes, Delete'
              )}
            </Button>
          </div>
        </div>
      </Modal>

      {/* Edit Developer Modal */}
      <Modal isOpen={showEditDeveloperModal} onClose={handleCloseEditDeveloperModal} className="max-w-4xl m-4 max-h-[90vh] overflow-y-auto">
        <div className="p-6">
          <h2 className="text-2xl font-semibold text-gray-900 dark:text-white mb-6">
            Edit Developer: {editingDeveloper?.name || 'Unnamed'}
          </h2>

          <div className="space-y-6">
            {/* Name Section */}
            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                  Developer Name
                </label>
                <Input
                  type="text"
                  value={editingDeveloper?.name || ''}
                  onChange={(e) => {
                    if (editingDeveloper) {
                      setEditingDeveloper({ ...editingDeveloper, name: e.target.value })
                    }
                  }}
                  placeholder="Enter developer name"
                />
              </div>
            </div>

            {/* Logo Section */}
            <div className="space-y-4">
              <h3 className="text-lg font-medium text-gray-900 dark:text-white">Logo</h3>
              <div>
                <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                  Logo URL
                </label>
                <Input
                  type="text"
                  value={developerLogo}
                  onChange={(e) => setDeveloperLogo(e.target.value)}
                  placeholder="Enter logo URL"
                />
              </div>
              {developerLogo && (
                <div className="mt-2">
                  <img
                    src={developerLogo}
                    alt="Developer logo"
                    className="h-20 w-20 object-contain rounded-lg border border-gray-200 dark:border-gray-700"
                    onError={(e) => {
                      const img = e.target as HTMLImageElement;
                      console.error('Logo load error:', developerLogo);
                      img.style.display = 'none';
                    }}
                    onLoad={() => {
                      console.log('Logo loaded successfully:', developerLogo)
                    }}
                  />
                </div>
              )}
            </div>

            {/* Description Section */}
            <div className="space-y-4">
              <h3 className="text-lg font-medium text-gray-900 dark:text-white">Description</h3>
              <div>
                <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                  Description
                </label>
                <TextArea
                  value={developerDescription}
                  onChange={(value) => setDeveloperDescription(value)}
                  placeholder="Enter developer description"
                  rows={6}
                />
              </div>
            </div>

            {/* Images Section */}
            <div className="space-y-4">
              <div className="flex items-center justify-between">
                <h3 className="text-lg font-medium text-gray-900 dark:text-white">Photos</h3>
                <span className="text-sm text-gray-500 dark:text-gray-400">
                  {developerImages.length} photo{developerImages.length !== 1 ? 's' : ''}
                </span>
              </div>
              
              {developerImages.length > 0 && (
                <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-4">
                  {developerImages.map((url, index) => (
                    <div key={index} className="relative group">
                      <img
                        src={url}
                        alt={`Developer ${index + 1}`}
                        className="w-full aspect-square object-cover rounded-lg"
                      />
                      <button
                        onClick={() => handleRemoveDeveloperImage(index)}
                        className="absolute top-2 right-2 bg-error-500 hover:bg-error-600 text-white rounded-full p-1.5 opacity-0 group-hover:opacity-100 transition-opacity shadow-lg"
                        title="Remove photo"
                      >
                        <svg width="14" height="14" viewBox="0 0 16 16" fill="none">
                          <path d="M12 4L4 12M4 4l8 8" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/>
                        </svg>
                      </button>
                    </div>
                  ))}
                </div>
              )}

              <div className="border-2 border-dashed border-gray-300 dark:border-gray-700 rounded-lg p-6 hover:border-brand-400 dark:hover:border-brand-600 transition-colors">
                <input
                  type="file"
                  accept="image/*"
                  multiple
                  onChange={handleDeveloperImageUpload}
                  disabled={uploadingImage}
                  className="hidden"
                  id="developer-image-upload"
                />
                <label
                  htmlFor="developer-image-upload"
                  className="flex flex-col items-center justify-center cursor-pointer"
                >
                  {uploadingImage ? (
                    <div className="flex items-center gap-2 text-gray-600 dark:text-gray-400">
                      <svg className="animate-spin h-5 w-5" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                        <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                        <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                      </svg>
                      <span>Uploading...</span>
                    </div>
                  ) : (
                    <>
                      <svg className="w-12 h-12 text-gray-400 mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
                      </svg>
                      <span className="text-sm text-gray-600 dark:text-gray-400 text-center">
                        Click to upload photos
                      </span>
                    </>
                  )}
                </label>
              </div>
            </div>

            {/* Actions */}
            <div className="flex items-center justify-end gap-3 pt-4 border-t border-gray-200 dark:border-gray-800">
              <Button
                variant="outline"
                onClick={handleCloseEditDeveloperModal}
                disabled={savingDeveloper}
              >
                Cancel
              </Button>
              <Button
                onClick={handleSaveDeveloper}
                disabled={savingDeveloper}
              >
                {savingDeveloper ? (
                  <>
                    <svg className="animate-spin h-4 w-4 mr-2" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                      <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                      <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                    </svg>
                    Saving...
                  </>
                ) : (
                  'Save'
                )}
              </Button>
            </div>
          </div>
        </div>
      </Modal>
    </>
  )
}

// Facilities Tab
function FacilitiesTab({ facilities, onReload }: any) {
  const [newFacility, setNewFacility] = useState('')
  const [deletingId, setDeletingId] = useState<string | null>(null)
  const [showDeleteModal, setShowDeleteModal] = useState(false)
  const [facilityToDelete, setFacilityToDelete] = useState<any>(null)

  const handleAdd = async () => {
    if (!newFacility || !newFacility.trim()) {
      alert('Please enter a facility name')
      return
    }
    
    const token = typeof window !== 'undefined' ? localStorage.getItem('token') : null
    if (!token) {
      alert('Please log in to add facilities')
      window.location.href = '/login'
      return
    }
    
    try {
      console.log('Adding facility:', newFacility.trim())
      // Generate icon name from facility name
      const iconName = newFacility
        .toLowerCase()
        .replace(/[^a-z0-9\s]/g, '')
        .replace(/\s+/g, '-')
        .replace(/-+/g, '-')
        .trim();
      
      const response = await api.post('/settings/facilities', { 
        nameEn: newFacility.trim(),
        nameRu: newFacility.trim(),
        nameAr: newFacility.trim(),
        iconName: iconName || 'facility-icon'
      })
      console.log('Success:', response.data)
      setNewFacility('')
      onReload()
    } catch (error: any) {
      console.error('Error adding facility:', error)
      console.error('Error response:', error.response)
      const errorMessage = error.response?.data?.message || error.message || 'Failed to add facility'
      alert(errorMessage)
    }
  }

  const handleDeleteClick = (fac: any) => {
    setFacilityToDelete(fac)
    setShowDeleteModal(true)
  }

  const handleConfirmDelete = async () => {
    if (!facilityToDelete) return
    
    setDeletingId(facilityToDelete.id)
    try {
      await api.delete(`/settings/facilities/${facilityToDelete.id}`)
      setShowDeleteModal(false)
      setFacilityToDelete(null)
      onReload()
    } catch (error) {
      console.error('Error deleting facility:', error)
    } finally {
      setDeletingId(null)
    }
  }

  const handleCancelDelete = () => {
    setShowDeleteModal(false)
    setFacilityToDelete(null)
  }

  return (
    <>
      <div className="space-y-6">
        <div className="flex items-center gap-4">
          <Input
            type="text"
            placeholder="Facility name"
            value={newFacility}
            onChange={(e) => setNewFacility(e.target.value)}
            className="flex-1"
          />
          <Button onClick={handleAdd}>Add</Button>
        </div>
        <div className="grid grid-cols-1 gap-2 sm:grid-cols-2 lg:grid-cols-3">
          {facilities.length === 0 ? (
            <p className="text-gray-500">No facilities</p>
          ) : (
            facilities.map((fac: any) => (
              <div
                key={fac.id}
                className="flex items-center justify-between rounded-lg border border-gray-200 p-4 dark:border-gray-800"
              >
                <span className="text-gray-800 dark:text-white">
                  {fac.nameEn || fac.nameRu || fac.nameAr || fac.name || 'Unnamed Facility'}
                </span>
                <button
                  onClick={() => handleDeleteClick(fac)}
                  disabled={deletingId === fac.id}
                  className="text-error-500 hover:text-error-600 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
                >
                  {deletingId === fac.id ? (
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
            ))
          )}
        </div>
      </div>

      {/* Delete Confirmation Modal */}
      <Modal isOpen={showDeleteModal} onClose={handleCancelDelete} className="max-w-md m-4">
        <div className="p-6">
          <div className="flex items-start gap-4 mb-6">
            <div className="flex-shrink-0 w-12 h-12 rounded-full bg-error-100 dark:bg-error-900/20 flex items-center justify-center">
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" className="text-error-600 dark:text-error-400">
                <path d="M12 9V13M12 17H12.01M21 12C21 16.9706 16.9706 21 12 21C7.02944 21 3 16.9706 3 12C3 7.02944 7.02944 3 12 3C16.9706 3 21 7.02944 21 12Z" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/>
              </svg>
            </div>
            <div className="flex-1">
              <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-2">
                Delete Facility
              </h3>
              <p className="text-sm text-gray-600 dark:text-gray-400">
                Are you sure you want to delete <span className="font-medium text-gray-900 dark:text-white">"{facilityToDelete?.nameEn || facilityToDelete?.nameRu || facilityToDelete?.nameAr || facilityToDelete?.name}"</span>? This action cannot be undone.
              </p>
            </div>
          </div>
          <div className="flex items-center justify-end gap-3">
            <Button
              variant="outline"
              onClick={handleCancelDelete}
              disabled={deletingId !== null}
            >
              No, Cancel
            </Button>
            <Button
              onClick={handleConfirmDelete}
              disabled={deletingId !== null}
              className="bg-error-600 hover:bg-error-700 text-white"
            >
              {deletingId !== null ? (
                <>
                  <svg className="animate-spin h-4 w-4 mr-2" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                    <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                    <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                  </svg>
                  Deleting...
                </>
              ) : (
                'Yes, Delete'
              )}
            </Button>
          </div>
        </div>
      </Modal>
    </>
  )
}

// Locations Tab
function LocationsTab({ countries, cities, areas, onReload }: any) {
  const [activeSection, setActiveSection] = useState<'countries' | 'cities' | 'areas'>('countries')
  const [newItem, setNewItem] = useState('')
  const [deletingId, setDeletingId] = useState<string | null>(null)
  const [showDeleteModal, setShowDeleteModal] = useState(false)
  const [itemToDelete, setItemToDelete] = useState<any>(null)
  
  // Area edit modal state
  const [showEditAreaModal, setShowEditAreaModal] = useState(false)
  const [editingArea, setEditingArea] = useState<any>(null)
  const [areaDescription, setAreaDescription] = useState({ title: '', description: '' })
  const [areaInfrastructure, setAreaInfrastructure] = useState({ title: '', description: '' })
  const [areaImages, setAreaImages] = useState<string[]>([])
  const [uploadingImage, setUploadingImage] = useState(false)
  const [savingArea, setSavingArea] = useState(false)

  const handleAdd = async () => {
    if (!newItem || !newItem.trim()) {
      alert('Please enter a name')
      return
    }
    
    const token = typeof window !== 'undefined' ? localStorage.getItem('token') : null
    if (!token) {
      alert('Please log in to add locations')
      window.location.href = '/login'
      return
    }
    
    try {
      console.log('Adding location:', activeSection, newItem.trim())
      const endpoint = `/settings/${activeSection}`
      
      let payload: any = {};
      
      if (activeSection === 'countries') {
        // For countries, we need nameEn and code
        // User enters name, we'll use it as nameEn and generate code from first 2 letters
        const code = newItem.trim().substring(0, 2).toUpperCase();
        if (code.length < 2) {
          alert('Country name must be at least 2 characters to generate code')
          return
        }
        payload = {
          nameEn: newItem.trim(),
          nameRu: newItem.trim(),
          nameAr: newItem.trim(),
          code: code
        };
      } else if (activeSection === 'cities') {
        // For cities, we need nameEn and countryId
        // Use first available country (UAE should be there)
        const countriesResponse = await api.get('/settings/countries').catch(() => ({ data: { data: [] } }));
        const countries = countriesResponse.data?.data || [];
        const defaultCountryId = countries.length > 0 ? countries[0].id : null;
        
        if (!defaultCountryId) {
          alert('Please create a country first');
          return;
        }
        
        payload = {
          nameEn: newItem.trim(),
          nameRu: newItem.trim(),
          nameAr: newItem.trim(),
          countryId: defaultCountryId
        };
      } else if (activeSection === 'areas') {
        // For areas, we need nameEn and cityId
        // Use first available city (Dubai should be there)
        const citiesResponse = await api.get('/settings/cities').catch(() => ({ data: { data: [] } }));
        const cities = citiesResponse.data?.data || [];
        const defaultCityId = cities.length > 0 ? cities[0].id : null;
        
        if (!defaultCityId) {
          alert('Please create a city first');
          return;
        }
        
        payload = {
          nameEn: newItem.trim(),
          nameRu: newItem.trim(),
          nameAr: newItem.trim(),
          cityId: defaultCityId
        };
      }
      
      console.log('Payload:', payload)
      const response = await api.post(endpoint, payload)
      console.log('Success:', response.data)
      setNewItem('')
      onReload()
    } catch (error: any) {
      console.error('Error adding location:', error)
      console.error('Error response:', error.response)
      const errorMessage = error.response?.data?.message || error.message || 'Failed to add location'
      alert(errorMessage)
    }
  }

  const handleDeleteClick = (item: any) => {
    setItemToDelete(item)
    setShowDeleteModal(true)
  }

  const handleEditAreaClick = async (area: any) => {
    try {
      // Завантажуємо повні дані району з API для отримання актуальних description, infrastructure, images
      const response = await api.get(`/settings/areas/${area.id}`).catch(() => ({ data: { data: area } }))
      const fullArea = response.data?.data || area
      
      // Обробляємо description (може бути об'єктом або рядком)
      let descriptionObj = { title: '', description: '' }
      if (fullArea.description) {
        if (typeof fullArea.description === 'object') {
          descriptionObj = {
            title: fullArea.description.title || '',
            description: fullArea.description.description || ''
          }
        } else if (typeof fullArea.description === 'string') {
          descriptionObj = {
            title: fullArea.nameEn || '',
            description: fullArea.description
          }
        }
      }
      
      // Обробляємо infrastructure (може бути об'єктом або рядком)
      let infrastructureObj = { title: '', description: '' }
      if (fullArea.infrastructure) {
        if (typeof fullArea.infrastructure === 'object') {
          infrastructureObj = {
            title: fullArea.infrastructure.title || '',
            description: fullArea.infrastructure.description || ''
          }
        } else if (typeof fullArea.infrastructure === 'string') {
          infrastructureObj = {
            title: 'Infrastructure',
            description: fullArea.infrastructure
          }
        }
      }
      
      // Обробляємо images (має бути масивом)
      let imagesArray: string[] = []
      if (fullArea.images) {
        if (Array.isArray(fullArea.images)) {
          imagesArray = fullArea.images
        } else if (typeof fullArea.images === 'string') {
          imagesArray = [fullArea.images]
        }
      }
      
      setEditingArea(fullArea)
      setAreaDescription(descriptionObj)
      setAreaInfrastructure(infrastructureObj)
      setAreaImages(imagesArray)
      setShowEditAreaModal(true)
    } catch (error: any) {
      console.error('Error loading area details:', error)
      // Якщо помилка, все одно відкриваємо модальне вікно з тими даними, що є
      setEditingArea(area)
      setAreaDescription({
        title: typeof area.description === 'object' ? (area.description?.title || '') : '',
        description: typeof area.description === 'object' ? (area.description?.description || '') : (typeof area.description === 'string' ? area.description : '')
      })
      setAreaInfrastructure({
        title: typeof area.infrastructure === 'object' ? (area.infrastructure?.title || '') : '',
        description: typeof area.infrastructure === 'object' ? (area.infrastructure?.description || '') : (typeof area.infrastructure === 'string' ? area.infrastructure : '')
      })
      setAreaImages(Array.isArray(area.images) ? area.images : (area.images ? [area.images] : []))
      setShowEditAreaModal(true)
    }
  }

  const handleCloseEditAreaModal = () => {
    setShowEditAreaModal(false)
    setEditingArea(null)
    setAreaDescription({ title: '', description: '' })
    setAreaInfrastructure({ title: '', description: '' })
    setAreaImages([])
  }

  // Check photo aspect ratio (3x4 or 4x3)
  const checkImageAspectRatio = (file: File): Promise<boolean> => {
    return new Promise((resolve) => {
      const img = new Image()
      const objectUrl = URL.createObjectURL(file)
      
      img.onload = () => {
        URL.revokeObjectURL(objectUrl)
        const width = img.width
        const height = img.height
        const aspectRatio = width / height
        
        // Check for 3x4 (0.75) or 4x3 (1.333...)
        // Allow tolerance (±0.05) for more flexibility
        const is3x4 = Math.abs(aspectRatio - 0.75) < 0.05
        const is4x3 = Math.abs(aspectRatio - 1.333) < 0.05
        
        resolve(is3x4 || is4x3)
      }
      
      img.onerror = () => {
        URL.revokeObjectURL(objectUrl)
        resolve(false)
      }
      
      img.src = objectUrl
    })
  }

  const handleImageUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const files = e.target.files
    if (!files || files.length === 0) return

    // Check photo count
    if (areaImages.length + files.length > 8) {
      alert('Maximum 8 photos allowed')
      e.target.value = ''
      return
    }

    setUploadingImage(true)
    try {
      // Check aspect ratio for each file
      const filesArray = Array.from(files)
      for (const file of filesArray) {
        const isValidAspectRatio = await checkImageAspectRatio(file)
        if (!isValidAspectRatio) {
          const img = new Image()
          const objectUrl = URL.createObjectURL(file)
          await new Promise((resolve) => {
            img.onload = () => {
              URL.revokeObjectURL(objectUrl)
              const actualRatio = (img.width / img.height).toFixed(2)
              alert(`Photo "${file.name}" has invalid aspect ratio.\n\nCurrent: ${actualRatio} (${img.width}x${img.height})\nRequired: 0.75 (3x4) or 1.33 (4x3)`)
              resolve(null)
            }
            img.src = objectUrl
          })
          setUploadingImage(false)
          e.target.value = ''
          return
        }
      }

      // Upload photos
      const formData = new FormData()
      filesArray.forEach((file) => {
        formData.append('files', file)
      })

      // Use axios directly for multipart/form-data upload
      const token = typeof window !== 'undefined' ? localStorage.getItem('token') : null
      const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:4000/api'
      const { data } = await axios.post(`${API_URL}/upload/images`, formData, {
        headers: {
          'Content-Type': 'multipart/form-data',
          ...(token && { Authorization: `Bearer ${token}` }),
        },
      })

      const newUrls = data?.data?.urls || data?.urls || []
      setAreaImages([...areaImages, ...newUrls])
    } catch (error: any) {
      console.error('Error uploading images:', error)
      alert(error.response?.data?.message || 'Error uploading photos')
    } finally {
      setUploadingImage(false)
      e.target.value = ''
    }
  }

  const handleRemoveImage = (index: number) => {
    setAreaImages(areaImages.filter((_, i) => i !== index))
  }

  const handleSaveArea = async () => {
    if (!editingArea) return

    setSavingArea(true)
    try {
      await api.put(`/settings/areas/${editingArea.id}`, {
        description: areaDescription,
        infrastructure: areaInfrastructure,
        images: areaImages,
      })
      
      onReload()
      handleCloseEditAreaModal()
    } catch (error: any) {
      console.error('Error saving area:', error)
      alert(error.response?.data?.message || 'Error saving area')
    } finally {
      setSavingArea(false)
    }
  }

  const handleConfirmDelete = async () => {
    if (!itemToDelete) return
    
    setDeletingId(itemToDelete.id)
    try {
      const endpoint = `/settings/${activeSection}/${itemToDelete.id}`
      await api.delete(endpoint)
      setShowDeleteModal(false)
      setItemToDelete(null)
      onReload()
    } catch (error: any) {
      console.error('Error deleting location:', error)
      alert(error.response?.data?.message || 'Failed to delete location')
    } finally {
      setDeletingId(null)
    }
  }

  const handleCancelDelete = () => {
    setShowDeleteModal(false)
    setItemToDelete(null)
  }

  const items = activeSection === 'countries' ? countries : activeSection === 'cities' ? cities : areas
  const sectionName = activeSection === 'countries' ? 'Country' : activeSection === 'cities' ? 'City' : 'Area'
  const hasValidInput = newItem && newItem.trim().length > 0
  const tooltipMessage = `Please fill in the ${sectionName.toLowerCase()} name field first`

  return (
    <>
    <div className="space-y-6">
      <div className="flex gap-2 border-b border-gray-200 dark:border-gray-800">
        <button
          onClick={() => setActiveSection('countries')}
          className={`px-4 py-2 text-sm font-medium transition-colors border-b-2 ${
            activeSection === 'countries'
              ? 'border-brand-500 text-brand-500'
              : 'border-transparent text-gray-500 hover:text-gray-700'
          }`}
        >
          Countries
        </button>
        <button
          onClick={() => setActiveSection('cities')}
          className={`px-4 py-2 text-sm font-medium transition-colors border-b-2 ${
            activeSection === 'cities'
              ? 'border-brand-500 text-brand-500'
              : 'border-transparent text-gray-500 hover:text-gray-700'
          }`}
        >
          Cities
        </button>
        <button
          onClick={() => setActiveSection('areas')}
          className={`px-4 py-2 text-sm font-medium transition-colors border-b-2 ${
            activeSection === 'areas'
              ? 'border-brand-500 text-brand-500'
              : 'border-transparent text-gray-500 hover:text-gray-700'
          }`}
        >
          Areas
        </button>
      </div>

      <div className="flex items-center gap-4">
        <Input
          type="text"
          placeholder={`${activeSection === 'countries' ? 'Country' : activeSection === 'cities' ? 'City' : 'Area'} name`}
          value={newItem}
          onChange={(e) => setNewItem(e.target.value)}
          onKeyDown={(e) => {
            if (e.key === 'Enter') {
              handleAdd()
            }
          }}
          className="flex-1"
        />
        <Tooltip 
          content={tooltipMessage}
          disabled={hasValidInput}
        >
          <Button 
            onClick={handleAdd} 
            disabled={!hasValidInput}
            className="min-w-[100px]"
          >
            Add
          </Button>
        </Tooltip>
      </div>

      <div className="grid grid-cols-1 gap-2 sm:grid-cols-2 lg:grid-cols-3">
        {items.length === 0 ? (
          <p className="text-gray-500">No items</p>
        ) : (
          items.map((item: any) => (
            <div
              key={item.id}
              className={`flex items-center justify-between rounded-lg border border-gray-200 p-4 dark:border-gray-800 ${
                activeSection === 'areas' ? 'cursor-pointer hover:bg-gray-50 dark:hover:bg-gray-800' : ''
              }`}
              onClick={activeSection === 'areas' ? () => handleEditAreaClick(item) : undefined}
            >
              <span className="text-gray-800 dark:text-white flex-1">
                {item.nameEn || item.nameRu || item.nameAr || item.name || 'Unnamed'}
              </span>
              <button
                onClick={(e) => {
                  e.stopPropagation()
                  handleDeleteClick(item)
                }}
                disabled={deletingId === item.id}
                className="text-error-500 hover:text-error-600 disabled:opacity-50 disabled:cursor-not-allowed transition-colors ml-2"
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
          ))
        )}
      </div>

      {/* Delete Confirmation Modal */}
      <Modal isOpen={showDeleteModal} onClose={handleCancelDelete} className="max-w-md m-4">
        <div className="p-6">
          <div className="flex items-start gap-4 mb-6">
            <div className="flex-shrink-0 w-12 h-12 rounded-full bg-error-100 dark:bg-error-900/20 flex items-center justify-center">
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" className="text-error-600 dark:text-error-400">
                <path d="M12 9V13M12 17H12.01M21 12C21 16.9706 16.9706 21 12 21C7.02944 21 3 16.9706 3 12C3 7.02944 7.02944 3 12 3C16.9706 3 21 7.02944 21 12Z" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/>
              </svg>
            </div>
            <div className="flex-1">
              <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-2">
                Delete {sectionName}
              </h3>
              <p className="text-sm text-gray-600 dark:text-gray-400">
                Are you sure you want to delete <span className="font-medium text-gray-900 dark:text-white">"{itemToDelete?.nameEn || itemToDelete?.nameRu || itemToDelete?.nameAr || itemToDelete?.name || 'this item'}"</span>? This action cannot be undone.
              </p>
            </div>
          </div>
          <div className="flex items-center justify-end gap-3">
            <Button
              variant="outline"
              onClick={handleCancelDelete}
              disabled={deletingId !== null}
            >
              No, Cancel
            </Button>
            <Button
              onClick={handleConfirmDelete}
              disabled={deletingId !== null}
              className="bg-error-600 hover:bg-error-700 text-white"
            >
              {deletingId !== null ? (
                <>
                  <svg className="animate-spin h-4 w-4 mr-2" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                    <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                    <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                  </svg>
                  Deleting...
                </>
              ) : (
                'Yes, Delete'
              )}
            </Button>
          </div>
        </div>
      </Modal>

      {/* Edit Area Modal */}
      <Modal isOpen={showEditAreaModal} onClose={handleCloseEditAreaModal} className="max-w-4xl m-4 max-h-[90vh] overflow-y-auto">
        <div className="p-6">
          <h2 className="text-2xl font-semibold text-gray-900 dark:text-white mb-6">
            Edit Area: {editingArea?.nameEn || editingArea?.nameRu || editingArea?.nameAr || 'Unnamed'}
          </h2>

          <div className="space-y-6">
            {/* Description Section */}
            <div className="space-y-4">
              <h3 className="text-lg font-medium text-gray-900 dark:text-white">Description</h3>
              <div className="space-y-3">
                <div>
                  <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                    Description Title
                  </label>
                  <Input
                    type="text"
                    value={areaDescription.title}
                    onChange={(e) => setAreaDescription({ ...areaDescription, title: e.target.value })}
                    placeholder="Enter description title"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                    Description Text
                  </label>
                  <TextArea
                    value={areaDescription.description}
                    onChange={(value) => setAreaDescription({ ...areaDescription, description: value })}
                    placeholder="Enter area description"
                    rows={4}
                  />
                </div>
              </div>
            </div>

            {/* Infrastructure Section */}
            <div className="space-y-4">
              <h3 className="text-lg font-medium text-gray-900 dark:text-white">Infrastructure</h3>
              <div className="space-y-3">
                <div>
                  <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                    Infrastructure Title
                  </label>
                  <Input
                    type="text"
                    value={areaInfrastructure.title}
                    onChange={(e) => setAreaInfrastructure({ ...areaInfrastructure, title: e.target.value })}
                    placeholder="Enter infrastructure title"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                    Infrastructure Text
                  </label>
                  <TextArea
                    value={areaInfrastructure.description}
                    onChange={(value) => setAreaInfrastructure({ ...areaInfrastructure, description: value })}
                    placeholder="Enter infrastructure description"
                    rows={4}
                  />
                </div>
              </div>
            </div>

            {/* Images Section */}
            <div className="space-y-4">
              <div className="flex items-center justify-between">
                <h3 className="text-lg font-medium text-gray-900 dark:text-white">Photos</h3>
                <span className="text-sm text-gray-500 dark:text-gray-400">
                  {areaImages.length} / 8
                </span>
              </div>
              
              {areaImages.length > 0 && (
                <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-4">
                  {areaImages.map((url, index) => (
                    <div key={index} className="relative group">
                      <img
                        src={url}
                        alt={`Area ${index + 1}`}
                        className="w-full aspect-[3/4] object-cover rounded-lg"
                      />
                      <button
                        onClick={() => handleRemoveImage(index)}
                        className="absolute top-2 right-2 bg-error-500 hover:bg-error-600 text-white rounded-full p-1.5 opacity-0 group-hover:opacity-100 transition-opacity shadow-lg"
                        title="Remove photo"
                      >
                        <svg width="14" height="14" viewBox="0 0 16 16" fill="none">
                          <path d="M12 4L4 12M4 4l8 8" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/>
                        </svg>
                      </button>
                    </div>
                  ))}
                </div>
              )}

              {areaImages.length < 8 && (
                <div className="border-2 border-dashed border-gray-300 dark:border-gray-700 rounded-lg p-6 hover:border-brand-400 dark:hover:border-brand-600 transition-colors">
                  <input
                    type="file"
                    accept="image/*"
                    multiple
                    onChange={handleImageUpload}
                    disabled={uploadingImage}
                    className="hidden"
                    id="area-image-upload"
                  />
                  <label
                    htmlFor="area-image-upload"
                    className="flex flex-col items-center justify-center cursor-pointer"
                  >
                    {uploadingImage ? (
                      <div className="flex items-center gap-2 text-gray-600 dark:text-gray-400">
                        <svg className="animate-spin h-5 w-5" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                          <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                          <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                        </svg>
                        <span>Uploading...</span>
                      </div>
                    ) : (
                      <>
                        <svg className="w-12 h-12 text-gray-400 mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
                        </svg>
                        <span className="text-sm text-gray-600 dark:text-gray-400 text-center">
                          Click to upload photos
                        </span>
                        <span className="text-xs text-gray-500 dark:text-gray-500 mt-1 text-center block">
                          Format: 3x4 or 4x3 (portrait or landscape)
                        </span>
                        <span className="text-xs text-gray-500 dark:text-gray-500 mt-1 text-center block">
                          You can upload up to {8 - areaImages.length} photos
                        </span>
                      </>
                    )}
                  </label>
                </div>
              )}
            </div>

            {/* Actions */}
            <div className="flex items-center justify-end gap-3 pt-4 border-t border-gray-200 dark:border-gray-800">
              <Button
                variant="outline"
                onClick={handleCloseEditAreaModal}
                disabled={savingArea}
              >
                Cancel
              </Button>
              <Button
                onClick={handleSaveArea}
                disabled={savingArea}
              >
                {savingArea ? (
                  <>
                    <svg className="animate-spin h-4 w-4 mr-2" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                      <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                      <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                    </svg>
                    Saving...
                  </>
                ) : (
                  'Save'
                )}
              </Button>
            </div>
          </div>
        </div>
      </Modal>
    </div>
    </>
  )
}
