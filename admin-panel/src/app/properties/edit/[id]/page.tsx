'use client'

import { useState, useEffect } from 'react'
import { useRouter, useParams } from 'next/navigation'
import { useForm, Controller } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'
import { api } from '@/lib/api'
import axios from 'axios'
import Button from '@/components/ui/button/Button'
import Input from '@/components/form/input/InputField'
import TextArea from '@/components/form/input/TextArea'
import Select from '@/components/form/Select'
import Label from '@/components/form/Label'
import Checkbox from '@/components/form/input/Checkbox'

// Property Type enum
enum PropertyType {
  OFF_PLAN = 'off-plan',
  SECONDARY = 'secondary',
}

// Unit Type enum
enum UnitType {
  APARTMENT = 'apartment',
  VILLA = 'villa',
  PENTHOUSE = 'penthouse',
  TOWNHOUSE = 'townhouse',
  OFFICE = 'office',
}

// Validation schemas
const unitSchema = z.object({
  unitId: z.string().min(1, 'Unit ID is required'),
  type: z.nativeEnum(UnitType),
  planImage: z.string().optional(),
  totalSize: z.string().min(1, 'Total size is required'),
  balconySize: z.string().optional(),
  price: z.string().min(1, 'Price is required'),
})

const offPlanSchema = z.object({
  propertyType: z.literal(PropertyType.OFF_PLAN),
  name: z.string().min(1, 'Name is required'),
  photos: z.array(z.string()).min(1, 'At least one photo is required'),
  countryId: z.string().min(1, 'Country is required'),
  cityId: z.string().min(1, 'City is required'),
  areaId: z.string().min(1, 'Area is required'),
  latitude: z.union([z.string(), z.number()]).transform((val) => {
    if (val === null || val === undefined || val === '') return ''
    return String(val).trim()
  }).refine((val) => val.length > 0, { message: 'Latitude is required' }),
  longitude: z.union([z.string(), z.number()]).transform((val) => {
    if (val === null || val === undefined || val === '') return ''
    return String(val).trim()
  }).refine((val) => val.length > 0, { message: 'Longitude is required' }),
  priceFrom: z.union([z.string(), z.number()]).transform((val) => {
    if (val === null || val === undefined || val === '') return ''
    return String(val).trim()
  }).refine((val) => val.length > 0, { message: 'Price from is required' }),
  bedroomsFrom: z.union([z.string(), z.number()]).transform((val) => {
    if (val === null || val === undefined || val === '') return ''
    return String(val).trim()
  }).refine((val) => val.length > 0, { message: 'Bedrooms from is required' }),
  bedroomsTo: z.union([z.string(), z.number()]).transform((val) => {
    if (val === null || val === undefined || val === '') return ''
    return String(val).trim()
  }).refine((val) => val.length > 0, { message: 'Bedrooms to is required' }),
  bathroomsFrom: z.union([z.string(), z.number()]).transform((val) => {
    if (val === null || val === undefined || val === '') return ''
    return String(val).trim()
  }).refine((val) => val.length > 0, { message: 'Bathrooms from is required' }),
  bathroomsTo: z.union([z.string(), z.number()]).transform((val) => {
    if (val === null || val === undefined || val === '') return ''
    return String(val).trim()
  }).refine((val) => val.length > 0, { message: 'Bathrooms to is required' }),
  sizeFrom: z.union([z.string(), z.number()]).transform((val) => {
    if (val === null || val === undefined || val === '') return ''
    return String(val).trim()
  }).refine((val) => val.length > 0, { message: 'Size from is required' }),
  sizeTo: z.union([z.string(), z.number()]).transform((val) => {
    if (val === null || val === undefined || val === '') return ''
    return String(val).trim()
  }).refine((val) => val.length > 0, { message: 'Size to is required' }),
  description: z.string().min(1, 'Description is required'),
  facilityIds: z.array(z.string()).optional(),
  developerId: z.string().optional(),
  paymentPlan: z.string().optional(),
})

const secondarySchema = z.object({
  propertyType: z.literal(PropertyType.SECONDARY),
  name: z.string().min(1, 'Name is required'),
  photos: z.array(z.string()).min(1, 'At least one photo is required'),
  countryId: z.string().min(1, 'Country is required'),
  cityId: z.string().min(1, 'City is required'),
  areaId: z.string().min(1, 'Area is required'),
  latitude: z.union([z.string(), z.number()]).transform((val) => {
    if (val === null || val === undefined || val === '') return ''
    return String(val).trim()
  }).refine((val) => val.length > 0, { message: 'Latitude is required' }),
  longitude: z.union([z.string(), z.number()]).transform((val) => {
    if (val === null || val === undefined || val === '') return ''
    return String(val).trim()
  }).refine((val) => val.length > 0, { message: 'Longitude is required' }),
  price: z.union([z.string(), z.number()]).transform((val) => {
    if (val === null || val === undefined || val === '') return ''
    return String(val).trim()
  }).refine((val) => val.length > 0, { message: 'Price is required' }),
  bedrooms: z.union([z.string(), z.number()]).transform((val) => {
    if (val === null || val === undefined || val === '') return ''
    return String(val).trim()
  }).refine((val) => val.length > 0, { message: 'Bedrooms is required' }),
  bathrooms: z.union([z.string(), z.number()]).transform((val) => {
    if (val === null || val === undefined || val === '') return ''
    return String(val).trim()
  }).refine((val) => val.length > 0, { message: 'Bathrooms is required' }),
  size: z.union([z.string(), z.number()]).transform((val) => {
    if (val === null || val === undefined || val === '') return ''
    return String(val).trim()
  }).refine((val) => val.length > 0, { message: 'Size is required' }),
  developerId: z.string().optional(),
})

const propertySchema = z.discriminatedUnion('propertyType', [offPlanSchema, secondarySchema])

type PropertyFormData = z.infer<typeof propertySchema>

interface Country {
  id: string
  nameEn: string
  nameRu: string
  nameAr: string
  cities?: City[]
}

interface City {
  id: string
  nameEn: string
  nameRu: string
  nameAr: string
  areas?: Area[]
}

interface Area {
  id: string
  nameEn: string
  nameRu: string
  nameAr: string
}

interface Developer {
  id: string
  name: string
}

interface Facility {
  id: string
  nameEn: string
  nameRu: string
  nameAr: string
  iconName: string
}

interface Unit {
  unitId: string
  type: UnitType
  planImage?: string
  totalSize: string
  balconySize?: string
  price: string
}

// Conversion utilities - return whole numbers only
const usdToAed = (usd: number) => Math.round(usd * 3.67)
const usdToEur = (usd: number) => Math.round(usd * 0.92)
const sqmToSqft = (sqm: number) => sqm * 10.764

// Format number without decimals, with commas for thousands
const formatNumber = (num: number) => {
  return Math.round(num).toLocaleString('en-US', {
    minimumFractionDigits: 0,
    maximumFractionDigits: 0
  })
}

export default function EditPropertyPage() {
  const router = useRouter()
  const params = useParams()
  const propertyId = params?.id as string
  
  const [loading, setLoading] = useState(false)
  const [loadingProperty, setLoadingProperty] = useState(true)
  const [propertyType, setPropertyType] = useState<PropertyType>(PropertyType.OFF_PLAN)
  const [countries, setCountries] = useState<Country[]>([])
  const [cities, setCities] = useState<City[]>([])
  const [areas, setAreas] = useState<Area[]>([])
  const [developers, setDevelopers] = useState<Developer[]>([])
  const [facilities, setFacilities] = useState<Facility[]>([])
  const [photos, setPhotos] = useState<string[]>([])
  const [units, setUnits] = useState<Unit[]>([])
  
  // Track values for real-time conversion display
  const [priceFromValue, setPriceFromValue] = useState<string>('')
  const [priceValue, setPriceValue] = useState<string>('')
  const [sizeFromValue, setSizeFromValue] = useState<string>('')
  const [sizeToValue, setSizeToValue] = useState<string>('')
  const [sizeValue, setSizeValue] = useState<string>('')

  const {
    register,
    handleSubmit,
    formState: { errors },
    setValue,
    watch,
    reset,
    control,
    trigger,
  } = useForm<PropertyFormData>({
    resolver: zodResolver(propertySchema),
    defaultValues: {
      propertyType: PropertyType.OFF_PLAN,
    },
  })

  useEffect(() => {
    loadInitialData()
    if (propertyId) {
      loadProperty()
    }
  }, [propertyId])

  useEffect(() => {
    // Reset form when property type changes
    reset({
      propertyType: propertyType,
    } as PropertyFormData)
  }, [propertyType, reset])

  const loadInitialData = async () => {
    try {
      const [countriesRes, developersRes, facilitiesRes] = await Promise.all([
        api.get('/settings/countries').catch(() => ({ data: { data: [] } })),
        api.get('/settings/developers').catch(() => ({ data: { data: [] } })),
        api.get('/settings/facilities').catch(() => ({ data: { data: [] } })),
      ])

      setCountries(countriesRes.data.data || [])
      setDevelopers(developersRes.data.data || [])
      setFacilities(facilitiesRes.data.data || [])
    } catch (error) {
      console.error('Error loading initial data:', error)
    }
  }

  const loadProperty = async () => {
    setLoadingProperty(true)
    try {
      const { data } = await api.get(`/properties/${propertyId}`)
      const property = data.data

      // Set property type
      setPropertyType(property.propertyType)
      
      // Load cities and areas based on property location
      if (property.countryId) {
        try {
          const { data: citiesData } = await api.get(`/settings/cities?countryId=${property.countryId}`)
          setCities(citiesData.data || [])
          
          if (property.cityId) {
            const { data: areasData } = await api.get(`/settings/areas?cityId=${property.cityId}`)
            setAreas(areasData.data || [])
          }
        } catch (error) {
          console.error('Error loading cities/areas:', error)
        }
      }

      // Populate form with property data
      reset({
        propertyType: property.propertyType,
        name: property.name || '',
        photos: (property.photos || []).map((photo: any) => {
          if (typeof photo === 'string') return photo;
          if (typeof photo === 'object' && photo !== null && photo.url) return String(photo.url);
          return null;
        }).filter((photo): photo is string => photo !== null),
        countryId: property.countryId || '',
        cityId: property.cityId || '',
        areaId: property.areaId || '',
        latitude: String(property.latitude || ''),
        longitude: String(property.longitude || ''),
        description: property.description || '',
        developerId: property.developerId || '',
        paymentPlan: property.paymentPlan || '',
        ...(property.propertyType === PropertyType.OFF_PLAN
          ? {
              priceFrom: String(property.priceFrom || ''),
              bedroomsFrom: String(property.bedroomsFrom || ''),
              bedroomsTo: String(property.bedroomsTo || ''),
              bathroomsFrom: String(property.bathroomsFrom || ''),
              bathroomsTo: String(property.bathroomsTo || ''),
              sizeFrom: String(property.sizeFrom || ''),
              sizeTo: String(property.sizeTo || ''),
              facilityIds: property.facilities?.map((f: Facility) => f.id) || [],
            }
          : {
              price: String(property.price || ''),
              bedrooms: String(property.bedrooms || ''),
              bathrooms: String(property.bathrooms || ''),
              size: String(property.size || ''),
            }),
      } as PropertyFormData)

      // Set photos - ensure they're strings, not objects
      // Property photos should be reelly URLs (NOT cloudinary - only area images use cloudinary)
      const cleanedPhotos = (property.photos || []).map((photo: any) => {
        if (typeof photo === 'string') return photo;
        if (typeof photo === 'object' && photo !== null && photo.url) return String(photo.url);
        return null;
      }).filter((photo): photo is string => photo !== null);
      setPhotos(cleanedPhotos)
      
      // Set conversion values and update form fields
      if (property.priceFrom) {
        const priceFromStr = String(property.priceFrom)
        setPriceFromValue(priceFromStr)
        // Ensure form field is updated
        setTimeout(() => {
          setValue('priceFrom', priceFromStr, { shouldValidate: false })
        }, 0)
      }
      if (property.price) {
        const priceStr = String(property.price)
        setPriceValue(priceStr)
        setTimeout(() => {
          setValue('price', priceStr, { shouldValidate: false })
        }, 0)
      }
      if (property.sizeFrom !== null && property.sizeFrom !== undefined) {
        const sizeFromStr = String(property.sizeFrom)
        setSizeFromValue(sizeFromStr)
        setTimeout(() => {
          setValue('sizeFrom', sizeFromStr, { shouldValidate: false })
        }, 0)
      }
      if (property.sizeTo !== null && property.sizeTo !== undefined) {
        const sizeToStr = String(property.sizeTo)
        setSizeToValue(sizeToStr)
        setTimeout(() => {
          setValue('sizeTo', sizeToStr, { shouldValidate: false })
        }, 0)
      }
      if (property.size) {
        const sizeStr = String(property.size)
        setSizeValue(sizeStr)
        setTimeout(() => {
          setValue('size', sizeStr, { shouldValidate: false })
        }, 0)
      }
      
      // Ensure facilityIds are set properly - do this after form is reset
      const facilityIds = property.facilities?.map((f: Facility) => f.id) || []
      setTimeout(() => {
        setValue('facilityIds', facilityIds, { shouldValidate: false })
      }, 200)

      // Set units for off-plan
      if (property.propertyType === PropertyType.OFF_PLAN && property.units) {
        setUnits(
          property.units.map((unit: any) => ({
            unitId: unit.unitId || '',
            type: unit.type || UnitType.APARTMENT,
            planImage: unit.planImage || '',
            totalSize: String(unit.totalSize || ''),
            balconySize: String(unit.balconySize || ''),
            price: String(unit.price || ''),
          }))
        )
      }
    } catch (error) {
      console.error('Error loading property:', error)
      alert('Failed to load property. Please try again.')
      router.push('/properties')
    } finally {
      setLoadingProperty(false)
    }
  }

  const handleCountryChange = async (countryId: string) => {
    setValue('countryId', countryId)
    setValue('cityId', '')
    setValue('areaId', '')
    setCities([])
    setAreas([])

    if (countryId) {
      try {
        const { data } = await api.get(`/settings/cities?countryId=${countryId}`)
        setCities(data.data || [])
      } catch (error) {
        console.error('Error loading cities:', error)
      }
    }
  }

  const handleCityChange = async (cityId: string) => {
    setValue('cityId', cityId)
    setValue('areaId', '')
    setAreas([])

    if (cityId) {
      try {
        const { data } = await api.get(`/settings/areas?cityId=${cityId}`)
        setAreas(data.data || [])
      } catch (error) {
        console.error('Error loading areas:', error)
      }
    }
  }

  const handlePhotoUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const files = e.target.files
    if (!files || files.length === 0) return

    try {
      const formData = new FormData()
      Array.from(files).forEach((file) => {
        formData.append('files', file)
      })

      const token = typeof window !== 'undefined' ? localStorage.getItem('token') : null
      const { data } = await axios.post(`${process.env.NEXT_PUBLIC_API_URL || 'http://localhost:4000/api'}/upload/images`, formData, {
        headers: {
          'Content-Type': 'multipart/form-data',
          ...(token && { Authorization: `Bearer ${token}` }),
        },
      })

      const newPhotos = data?.data?.urls || data?.urls || []
      const updatedPhotos = [...photos, ...newPhotos]
      setPhotos(updatedPhotos)
      setValue('photos', updatedPhotos, { shouldValidate: true })
      
      e.target.value = ''
    } catch (error: any) {
      console.error('Error uploading photos:', error)
      alert(error.response?.data?.message || 'Failed to upload photos. Please try again.')
    }
  }

  const removePhoto = (index: number) => {
    const newPhotos = photos.filter((_, i) => i !== index)
    setPhotos(newPhotos)
    setValue('photos', newPhotos, { shouldValidate: true })
  }

  const addUnit = () => {
    setUnits([
      ...units,
      {
        unitId: '',
        type: UnitType.APARTMENT,
        totalSize: '',
        price: '',
      },
    ])
  }

  const removeUnit = (index: number) => {
    setUnits(units.filter((_, i) => i !== index))
  }

  const updateUnit = (index: number, field: keyof Unit, value: string) => {
    const newUnits = [...units]
    newUnits[index] = { ...newUnits[index], [field]: value }
    setUnits(newUnits)
  }

  const handleUnitImageUpload = async (index: number, file: File) => {
    try {
      const formData = new FormData()
      formData.append('file', file)

      const token = typeof window !== 'undefined' ? localStorage.getItem('token') : null
      const { data } = await axios.post(`${process.env.NEXT_PUBLIC_API_URL || 'http://localhost:4000/api'}/upload/image`, formData, {
        headers: {
          'Content-Type': 'multipart/form-data',
          ...(token && { Authorization: `Bearer ${token}` }),
        },
      })

      const imageUrl = data?.data?.url || data?.url || ''
      updateUnit(index, 'planImage', imageUrl)
    } catch (error: any) {
      console.error('Error uploading unit image:', error)
      alert(error.response?.data?.message || 'Failed to upload image. Please try again.')
    }
  }

  const handleDelete = async () => {
    if (!confirm('Are you sure you want to delete this property? This action cannot be undone.')) {
      return
    }

    setLoading(true)
    try {
      await api.delete(`/properties/${propertyId}`)
      alert('Property deleted successfully!')
      router.push('/properties')
    } catch (error: any) {
      console.error('Error deleting property:', error)
      alert(error.response?.data?.message || 'Failed to delete property. Please try again.')
      setLoading(false)
    }
  }

  const onSubmit = async (data: PropertyFormData) => {
    setLoading(true)
    try {
      const payload: any = {
        propertyType: data.propertyType,
        name: data.name,
        photos: photos,
        countryId: data.countryId,
        cityId: data.cityId,
        areaId: data.areaId,
        latitude: parseFloat(data.latitude),
        longitude: parseFloat(data.longitude),
        developerId: data.developerId || undefined,
      }

      if (photos.length > 0) {
        payload.mainPhotoUrl = photos[0]
      }

      if (data.propertyType === PropertyType.OFF_PLAN) {
        payload.priceFrom = parseFloat(data.priceFrom)
        payload.bedroomsFrom = parseInt(data.bedroomsFrom, 10)
        payload.bedroomsTo = parseInt(data.bedroomsTo, 10)
        payload.bathroomsFrom = parseInt(data.bathroomsFrom, 10)
        payload.bathroomsTo = parseInt(data.bathroomsTo, 10)
        payload.sizeFrom = parseFloat(data.sizeFrom)
        payload.sizeTo = parseFloat(data.sizeTo)
        payload.description = data.description
        payload.paymentPlan = data.paymentPlan || undefined
        payload.facilityIds = data.facilityIds || []

        // Add units
        if (units.length > 0) {
          payload.units = units.map((unit) => ({
            unitId: unit.unitId,
            type: unit.type,
            planImage: unit.planImage || undefined,
            totalSize: parseFloat(unit.totalSize),
            balconySize: unit.balconySize ? parseFloat(unit.balconySize) : undefined,
            price: parseFloat(unit.price),
          }))
        }
      } else {
        payload.price = parseFloat(data.price)
        payload.bedrooms = parseInt(data.bedrooms, 10)
        payload.bathrooms = parseInt(data.bathrooms, 10)
        payload.size = parseFloat(data.size)
      }

      // Update property instead of creating
      await api.patch(`/properties/${propertyId}`, payload)
      
      console.log('Property updated successfully')
      alert('Property updated successfully!')
      router.push('/properties')
    } catch (error: any) {
      console.error('Error updating property:', error)
      alert(error.response?.data?.message || 'Failed to update property. Please try again.')
    } finally {
      setLoading(false)
    }
  }

  if (loadingProperty) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <p className="text-gray-500 dark:text-gray-400">Loading property...</p>
      </div>
    )
  }

  const selectedCountryId = watch('countryId')
  const selectedCityId = watch('cityId')
  const selectedFacilities = watch('facilityIds') || []

  const unitTypeOptions = [
    { value: UnitType.APARTMENT, label: 'Apartment' },
    { value: UnitType.VILLA, label: 'Villa' },
    { value: UnitType.PENTHOUSE, label: 'Penthouse' },
    { value: UnitType.TOWNHOUSE, label: 'Townhouse' },
    { value: UnitType.OFFICE, label: 'Office' },
  ]

  // Copy the rest of the JSX from add/page.tsx but change title and button text
  // For brevity, I'll include the key differences - you can copy the full JSX structure from add/page.tsx

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-semibold text-gray-800 dark:text-white">Edit Property</h1>
        <Button variant="outline" onClick={() => router.back()}>
          Cancel
        </Button>
      </div>


      {/* Form - Same as add page */}
      <form onSubmit={handleSubmit(onSubmit)} className="space-y-8">
        <div className="bg-white dark:bg-gray-900 rounded-xl border border-gray-200 dark:border-gray-800 p-6 space-y-6">
          {/* Basic Information */}
          <div>
            <h2 className="text-lg font-semibold text-gray-800 dark:text-white mb-4">
              Basic Information
            </h2>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div className="md:col-span-2">
                <Label htmlFor="name">Name *</Label>
                <Controller
                  name="name"
                  control={control}
                  render={({ field }) => (
                    <Input
                      id="name"
                      {...field}
                      value={field.value || ''}
                      onChange={(e) => {
                        field.onChange(e.target.value)
                      }}
                      placeholder="Enter property name"
                      error={!!(errors as any).name}
                    />
                  )}
                />
                {(errors as any).name && (
                  <p className="mt-1 text-sm text-error-500">{(errors as any).name.message}</p>
                )}
              </div>

              <div>
                <Label htmlFor="countryId">Country *</Label>
                <Select
                  options={countries.map((c) => ({ value: c.id, label: c.nameEn }))}
                  placeholder="Select country"
                  defaultValue={selectedCountryId || ''}
                  onChange={handleCountryChange}
                />
                {(errors as any).countryId && (
                  <p className="mt-1 text-sm text-error-500">{(errors as any).countryId.message}</p>
                )}
              </div>

              <div>
                <Label htmlFor="cityId">City *</Label>
                <Select
                  options={cities.map((c) => ({ value: c.id, label: c.nameEn }))}
                  placeholder="Select city"
                  defaultValue={selectedCityId || ''}
                  onChange={handleCityChange}
                />
                {(errors as any).cityId && (
                  <p className="mt-1 text-sm text-error-500">{(errors as any).cityId.message}</p>
                )}
              </div>

              <div>
                <Label htmlFor="areaId">Area *</Label>
                <Select
                  options={areas.map((a) => ({ value: a.id, label: a.nameEn }))}
                  placeholder="Select area"
                  defaultValue={watch('areaId') || ''}
                  onChange={(value) => setValue('areaId', value)}
                />
                {(errors as any).areaId && (
                  <p className="mt-1 text-sm text-error-500">{(errors as any).areaId.message}</p>
                )}
              </div>

              <div>
                <Label htmlFor="latitude">Latitude *</Label>
                <Controller
                  name="latitude"
                  control={control}
                  render={({ field }) => (
                    <Input
                      id="latitude"
                      type="number"
                      step="0.00000001"
                      {...field}
                      value={field.value || ''}
                      onChange={(e) => {
                        field.onChange(e.target.value)
                      }}
                      placeholder="25.2048"
                      error={!!(errors as any).latitude}
                    />
                  )}
                />
                {(errors as any).latitude && (
                  <p className="mt-1 text-sm text-error-500">{(errors as any).latitude.message}</p>
                )}
              </div>

              <div>
                <Label htmlFor="longitude">Longitude *</Label>
                <Controller
                  name="longitude"
                  control={control}
                  render={({ field }) => (
                    <Input
                      id="longitude"
                      type="number"
                      step="0.00000001"
                      {...field}
                      value={field.value || ''}
                      onChange={(e) => {
                        field.onChange(e.target.value)
                      }}
                      placeholder="55.2708"
                      error={!!(errors as any).longitude}
                    />
                  )}
                />
                {(errors as any).longitude && (
                  <p className="mt-1 text-sm text-error-500">{(errors as any).longitude.message}</p>
                )}
              </div>
            </div>
          </div>

          {/* Photos */}
          <div>
            <h2 className="text-lg font-semibold text-gray-800 dark:text-white mb-4">Photos *</h2>
            <div>
              <input
                type="file"
                multiple
                accept="image/*"
                onChange={handlePhotoUpload}
                className="block w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded-lg file:border-0 file:text-sm file:font-semibold file:bg-brand-50 file:text-brand-700 hover:file:bg-brand-100 dark:file:bg-gray-800 dark:file:text-gray-300"
              />
              {photos.length > 0 && (
                <div className="mt-4">
                  <p className="text-sm text-gray-500 dark:text-gray-400 mb-3">
                    First photo will be set as main photo
                  </p>
                  <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                    {photos.map((photo, index) => (
                      <div key={index} className="relative group">
                        <div className="relative w-full aspect-video overflow-hidden rounded-lg border-2 border-gray-200 dark:border-gray-700">
                          <img
                            src={photo}
                            alt={`Photo ${index + 1}`}
                            className="w-full h-full object-cover"
                          />
                          {index === 0 && (
                            <div className="absolute top-2 left-2 px-2 py-1 bg-brand-500 text-white text-xs font-semibold rounded">
                              Main
                            </div>
                          )}
                          <button
                            type="button"
                            onClick={() => removePhoto(index)}
                            className="absolute top-2 right-2 p-1.5 bg-red-500 text-white rounded-full opacity-0 group-hover:opacity-100 transition-opacity hover:bg-red-600"
                            title="Remove photo"
                          >
                            <svg
                              width="14"
                              height="14"
                              viewBox="0 0 14 14"
                              fill="none"
                              xmlns="http://www.w3.org/2000/svg"
                            >
                              <path
                                d="M10.5 3.5L3.5 10.5M3.5 3.5L10.5 10.5"
                                stroke="currentColor"
                                strokeWidth="2"
                                strokeLinecap="round"
                                strokeLinejoin="round"
                              />
                            </svg>
                          </button>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              )}
              {(errors as any).photos && (
                <p className="mt-1 text-sm text-error-500">{(errors as any).photos.message}</p>
              )}
            </div>
          </div>

          {/* Off-Plan Specific Fields */}
          {propertyType === PropertyType.OFF_PLAN && (
            <>
              <div>
                <h2 className="text-lg font-semibold text-gray-800 dark:text-white mb-4">
                  Pricing & Details
                </h2>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <div>
                    <Label htmlFor="priceFrom">Price From (USD) *</Label>
                    <Controller
                      name="priceFrom"
                      control={control}
                      render={({ field }) => (
                        <Input
                          id="priceFrom"
                          type="number"
                          step="0.01"
                          value={field.value || priceFromValue || ''}
                          onChange={(e) => {
                            const value = e.target.value
                            field.onChange(value)
                            setPriceFromValue(value)
                          }}
                          placeholder="0.00"
                          error={!!(errors as any).priceFrom}
                        />
                      )}
                    />
                    {(errors as any).priceFrom && (
                      <p className="mt-1 text-sm text-error-500">
                        {(errors as any).priceFrom.message}
                      </p>
                    )}
                    {priceFromValue && parseFloat(priceFromValue) > 0 && (
                      <p className="mt-1 text-xs text-gray-500 dark:text-gray-400">
                        ≈ {formatNumber(usdToAed(parseFloat(priceFromValue)))} AED • {formatNumber(usdToEur(parseFloat(priceFromValue)))} EUR
                      </p>
                    )}
                  </div>

                  <div>
                    <Label htmlFor="developerId">Developer</Label>
                    <Select
                      options={developers.map((d) => ({ value: d.id, label: d.name }))}
                      placeholder="Select developer"
                      defaultValue={watch('developerId') || ''}
                      onChange={(value) => setValue('developerId', value)}
                    />
                  </div>

                  <div>
                    <Label htmlFor="bedroomsFrom">Bedrooms From *</Label>
                    <Controller
                      name="bedroomsFrom"
                      control={control}
                      render={({ field }) => (
                        <Input
                          id="bedroomsFrom"
                          type="number"
                          {...field}
                          value={field.value || ''}
                          onChange={(e) => {
                            field.onChange(e.target.value)
                          }}
                          placeholder="0"
                          error={!!(errors as any).bedroomsFrom}
                        />
                      )}
                    />
                    {(errors as any).bedroomsFrom && (
                      <p className="mt-1 text-sm text-error-500">
                        {(errors as any).bedroomsFrom.message}
                      </p>
                    )}
                  </div>

                  <div>
                    <Label htmlFor="bedroomsTo">Bedrooms To *</Label>
                    <Controller
                      name="bedroomsTo"
                      control={control}
                      render={({ field }) => (
                        <Input
                          id="bedroomsTo"
                          type="number"
                          {...field}
                          value={field.value || ''}
                          onChange={(e) => {
                            field.onChange(e.target.value)
                          }}
                          placeholder="0"
                          error={!!(errors as any).bedroomsTo}
                        />
                      )}
                    />
                    {(errors as any).bedroomsTo && (
                      <p className="mt-1 text-sm text-error-500">{(errors as any).bedroomsTo.message}</p>
                    )}
                  </div>

                  <div>
                    <Label htmlFor="bathroomsFrom">Bathrooms From *</Label>
                    <Controller
                      name="bathroomsFrom"
                      control={control}
                      render={({ field }) => (
                        <Input
                          id="bathroomsFrom"
                          type="number"
                          {...field}
                          value={field.value || ''}
                          onChange={(e) => {
                            field.onChange(e.target.value)
                          }}
                          placeholder="0"
                          error={!!(errors as any).bathroomsFrom}
                        />
                      )}
                    />
                    {(errors as any).bathroomsFrom && (
                      <p className="mt-1 text-sm text-error-500">
                        {(errors as any).bathroomsFrom.message}
                      </p>
                    )}
                  </div>

                  <div>
                    <Label htmlFor="bathroomsTo">Bathrooms To *</Label>
                    <Controller
                      name="bathroomsTo"
                      control={control}
                      render={({ field }) => (
                        <Input
                          id="bathroomsTo"
                          type="number"
                          {...field}
                          value={field.value || ''}
                          onChange={(e) => {
                            field.onChange(e.target.value)
                          }}
                          placeholder="0"
                          error={!!(errors as any).bathroomsTo}
                        />
                      )}
                    />
                    {(errors as any).bathroomsTo && (
                      <p className="mt-1 text-sm text-error-500">{(errors as any).bathroomsTo.message}</p>
                    )}
                  </div>

                  <div>
                    <Label htmlFor="sizeFrom">Size From (sq.m) *</Label>
                    <Input
                      id="sizeFrom"
                      type="number"
                      step="0.01"
                      value={watch('sizeFrom') || sizeFromValue || ''}
                      onChange={(e) => {
                        const value = e.target.value
                        setSizeFromValue(value)
                        setValue('sizeFrom', value, { shouldValidate: true })
                      }}
                      placeholder="0.00"
                      error={!!(errors as any).sizeFrom}
                    />
                    {(errors as any).sizeFrom && (
                      <p className="mt-1 text-sm text-error-500">{(errors as any).sizeFrom.message}</p>
                    )}
                    {sizeFromValue && parseFloat(sizeFromValue) > 0 && (
                      <p className="mt-1 text-xs text-gray-500 dark:text-gray-400">
                        ≈ {sqmToSqft(parseFloat(sizeFromValue)).toFixed(2)} sq.ft
                      </p>
                    )}
                  </div>

                  <div>
                    <Label htmlFor="sizeTo">Size To (sq.m) *</Label>
                    <Input
                      id="sizeTo"
                      type="number"
                      step="0.01"
                      value={watch('sizeTo') || sizeToValue || ''}
                      onChange={(e) => {
                        const value = e.target.value
                        setSizeToValue(value)
                        setValue('sizeTo', value, { shouldValidate: true })
                      }}
                      placeholder="0.00"
                      error={!!(errors as any).sizeTo}
                    />
                    {(errors as any).sizeTo && (
                      <p className="mt-1 text-sm text-error-500">{(errors as any).sizeTo.message}</p>
                    )}
                    {sizeToValue && parseFloat(sizeToValue) > 0 && (
                      <p className="mt-1 text-xs text-gray-500 dark:text-gray-400">
                        ≈ {sqmToSqft(parseFloat(sizeToValue)).toFixed(2)} sq.ft
                      </p>
                    )}
                  </div>
                </div>
              </div>

              <div>
                <Label htmlFor="description">Description *</Label>
                <TextArea
                  id="description"
                  rows={6}
                  value={watch('description') || ''}
                  onChange={(value) => setValue('description', value)}
                  placeholder="Enter description"
                />
                {(errors as any).description && (
                  <p className="mt-1 text-sm text-error-500">{(errors as any).description.message}</p>
                )}
              </div>

              <div>
                <Label htmlFor="paymentPlan">Payment Plan</Label>
                <TextArea
                  id="paymentPlan"
                  rows={4}
                  value={watch('paymentPlan') || ''}
                  onChange={(value) => setValue('paymentPlan', value)}
                  placeholder="Enter payment plan details"
                />
              </div>

              {/* Facilities */}
              <div>
                <h2 className="text-lg font-semibold text-gray-800 dark:text-white mb-4">
                  Facilities
                </h2>
                <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                  {facilities.map((facility) => {
                    const facilityName = facility.nameEn || facility.nameRu || facility.nameAr || 'Unnamed Facility'
                    return (
                      <Checkbox
                        key={facility.id}
                        id={`facility-${facility.id}`}
                        label={facilityName}
                        checked={selectedFacilities.includes(facility.id)}
                        onChange={(checked) => {
                          const currentFacilities = watch('facilityIds') || []
                          const newFacilities = checked
                            ? [...currentFacilities, facility.id]
                            : currentFacilities.filter((id) => id !== facility.id)
                          setValue('facilityIds', newFacilities, { shouldValidate: false })
                          // Force re-render
                          trigger('facilityIds')
                        }}
                      />
                    )
                  })}
                </div>
              </div>

              {/* Units */}
              <div>
                <div className="flex items-center justify-between mb-4">
                  <h2 className="text-lg font-semibold text-gray-800 dark:text-white">Units</h2>
                  <Button type="button" variant="outline" size="sm" onClick={addUnit}>
                    Add Unit
                  </Button>
                </div>
                {units.map((unit, index) => (
                  <div
                    key={index}
                    className="border border-gray-200 dark:border-gray-800 rounded-lg p-4 mb-4 space-y-4"
                  >
                    <div className="flex items-center justify-between">
                      <h3 className="font-medium text-gray-800 dark:text-white">
                        Unit {index + 1}
                      </h3>
                      <Button
                        type="button"
                        variant="outline"
                        size="sm"
                        onClick={() => removeUnit(index)}
                      >
                        Remove
                      </Button>
                    </div>
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                      <div>
                        <Label>Unit ID *</Label>
                        <Input
                          value={unit.unitId}
                          onChange={(e) => updateUnit(index, 'unitId', e.target.value)}
                          placeholder="Enter unit ID"
                        />
                      </div>
                      <div>
                        <Label>Type *</Label>
                        <Select
                          options={unitTypeOptions}
                          placeholder="Select type"
                          defaultValue={unit.type}
                          onChange={(value) => updateUnit(index, 'type', value as UnitType)}
                        />
                      </div>
                      <div>
                        <Label>Total Size (sq.m) *</Label>
                        <Input
                          type="number"
                          step="0.01"
                          value={unit.totalSize}
                          onChange={(e) => updateUnit(index, 'totalSize', e.target.value)}
                          placeholder="0.00"
                        />
                        {unit.totalSize && parseFloat(unit.totalSize || '0') > 0 && (
                          <p className="mt-1 text-xs text-gray-500 dark:text-gray-400">
                            ≈ {sqmToSqft(parseFloat(unit.totalSize || '0')).toFixed(2)} sq.ft
                          </p>
                        )}
                      </div>
                      <div>
                        <Label>Balcony Size (sq.m)</Label>
                        <Input
                          type="number"
                          step="0.01"
                          value={unit.balconySize || ''}
                          onChange={(e) => updateUnit(index, 'balconySize', e.target.value)}
                          placeholder="0.00"
                        />
                        {unit.balconySize && parseFloat(unit.balconySize || '0') > 0 && (
                          <p className="mt-1 text-xs text-gray-500 dark:text-gray-400">
                            ≈ {sqmToSqft(parseFloat(unit.balconySize || '0')).toFixed(2)} sq.ft
                          </p>
                        )}
                      </div>
                      <div>
                        <Label>Price (USD) *</Label>
                        <Input
                          type="number"
                          step="0.01"
                          value={unit.price}
                          onChange={(e) => updateUnit(index, 'price', e.target.value)}
                          placeholder="0.00"
                        />
                        {unit.price && parseFloat(unit.price || '0') > 0 && (
                          <p className="mt-1 text-xs text-gray-500 dark:text-gray-400">
                            ≈ {formatNumber(usdToAed(parseFloat(unit.price || '0')))} AED • {formatNumber(usdToEur(parseFloat(unit.price || '0')))} EUR
                          </p>
                        )}
                      </div>
                      <div>
                        <Label>Plan Image</Label>
                        <input
                          type="file"
                          accept="image/*"
                          onChange={(e) => {
                            const file = e.target.files?.[0]
                            if (file) handleUnitImageUpload(index, file)
                          }}
                          className="block w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded-lg file:border-0 file:text-sm file:font-semibold file:bg-brand-50 file:text-brand-700 hover:file:bg-brand-100 dark:file:bg-gray-800 dark:file:text-gray-300"
                        />
                        {unit.planImage && (
                          <img
                            src={unit.planImage}
                            alt="Plan"
                            className="mt-2 w-full h-32 object-contain rounded-lg border border-gray-200 dark:border-gray-800"
                          />
                        )}
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </>
          )}

          {/* Secondary Specific Fields */}
          {propertyType === PropertyType.SECONDARY && (
            <>
              <div>
                <h2 className="text-lg font-semibold text-gray-800 dark:text-white mb-4">
                  Pricing & Details
                </h2>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <div>
                    <Label htmlFor="price">Price (USD) *</Label>
                    <Input
                      id="price"
                      type="number"
                      step="0.01"
                      {...register('price', {
                        valueAsNumber: false,
                        onChange: (e) => {
                          const value = e.target.value
                          setPriceValue(value)
                          setValue('price', value, { shouldValidate: true })
                        }
                      })}
                      placeholder="0.00"
                      error={!!(errors as any).price}
                    />
                    {(errors as any).price && (
                      <p className="mt-1 text-sm text-error-500">{(errors as any).price.message}</p>
                    )}
                    {priceValue && parseFloat(priceValue) > 0 && (
                      <p className="mt-1 text-xs text-gray-500 dark:text-gray-400">
                        ≈ {formatNumber(usdToAed(parseFloat(priceValue)))} AED • {formatNumber(usdToEur(parseFloat(priceValue)))} EUR
                      </p>
                    )}
                  </div>

                  <div>
                    <Label htmlFor="developerId">Developer</Label>
                    <Select
                      options={developers.map((d) => ({ value: d.id, label: d.name }))}
                      placeholder="Select developer"
                      defaultValue={watch('developerId') || ''}
                      onChange={(value) => setValue('developerId', value)}
                    />
                  </div>

                  <div>
                    <Label htmlFor="bedrooms">Bedrooms *</Label>
                    <Controller
                      name="bedrooms"
                      control={control}
                      render={({ field }) => (
                        <Input
                          id="bedrooms"
                          type="number"
                          {...field}
                          value={field.value || ''}
                          onChange={(e) => {
                            field.onChange(e.target.value)
                          }}
                          placeholder="0"
                          error={!!(errors as any).bedrooms}
                        />
                      )}
                    />
                    {(errors as any).bedrooms && (
                      <p className="mt-1 text-sm text-error-500">{(errors as any).bedrooms.message}</p>
                    )}
                  </div>

                  <div>
                    <Label htmlFor="bathrooms">Bathrooms *</Label>
                    <Controller
                      name="bathrooms"
                      control={control}
                      render={({ field }) => (
                        <Input
                          id="bathrooms"
                          type="number"
                          {...field}
                          value={field.value || ''}
                          onChange={(e) => {
                            field.onChange(e.target.value)
                          }}
                          placeholder="0"
                          error={!!(errors as any).bathrooms}
                        />
                      )}
                    />
                    {(errors as any).bathrooms && (
                      <p className="mt-1 text-sm text-error-500">{(errors as any).bathrooms.message}</p>
                    )}
                  </div>

                  <div>
                    <Label htmlFor="size">Size (sq.m) *</Label>
                    <Input
                      id="size"
                      type="number"
                      step="0.01"
                      {...register('size', {
                        valueAsNumber: false,
                        onChange: (e) => {
                          const value = e.target.value
                          setSizeValue(value)
                          setValue('size', value, { shouldValidate: true })
                        }
                      })}
                      placeholder="0.00"
                      error={!!(errors as any).size}
                    />
                    {(errors as any).size && (
                      <p className="mt-1 text-sm text-error-500">{(errors as any).size.message}</p>
                    )}
                    {sizeValue && parseFloat(sizeValue) > 0 && (
                      <p className="mt-1 text-xs text-gray-500 dark:text-gray-400">
                        ≈ {sqmToSqft(parseFloat(sizeValue)).toFixed(2)} sq.ft
                      </p>
                    )}
                  </div>
                </div>
              </div>
            </>
          )}

          {/* Hidden field for propertyType */}
          <input type="hidden" {...register('propertyType')} value={propertyType} />
        </div>

        {/* Form Actions */}
        <div className="flex items-center justify-between gap-4">
          <Button 
            variant="outline" 
            type="button" 
            onClick={handleDelete}
            disabled={loading}
            className="bg-red-50 text-red-600 hover:bg-red-100 dark:bg-red-900/20 dark:text-red-400 dark:hover:bg-red-900/30"
          >
            Delete Property
          </Button>
          <div className="flex items-center gap-4">
            <Button variant="outline" type="button" onClick={() => router.back()} disabled={loading}>
              Cancel
            </Button>
            <Button type="submit" disabled={loading}>
              {loading ? 'Updating...' : 'Update Property'}
            </Button>
          </div>
        </div>
      </form>
    </div>
  )
}
