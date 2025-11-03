'use client'

import { useState, useEffect } from 'react'
import { useRouter } from 'next/navigation'
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

export default function AddPropertyPage() {
  const router = useRouter()
  const [loading, setLoading] = useState(false)
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
  } = useForm<PropertyFormData>({
    resolver: zodResolver(propertySchema),
    defaultValues: {
      propertyType: PropertyType.OFF_PLAN,
    },
  })

  useEffect(() => {
    loadInitialData()
  }, [])

  useEffect(() => {
    // Reset form when property type changes
    reset({
      propertyType: propertyType,
    } as PropertyFormData)
    setPhotos([])
    setUnits([])
    setPriceFromValue('')
    setPriceValue('')
    setSizeFromValue('')
    setSizeToValue('')
    setSizeValue('')
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

      // Use axios directly for multipart/form-data upload
      const token = typeof window !== 'undefined' ? localStorage.getItem('token') : null
      const { data } = await axios.post(`${process.env.NEXT_PUBLIC_API_URL || 'http://localhost:4000/api'}/upload/images`, formData, {
        headers: {
          'Content-Type': 'multipart/form-data',
          ...(token && { Authorization: `Bearer ${token}` }),
        },
      })

      // Response format: { data: { urls: [...] } }
      const newPhotos = data?.data?.urls || data?.urls || []
      const updatedPhotos = [...photos, ...newPhotos]
      setPhotos(updatedPhotos)
      setValue('photos', updatedPhotos, { shouldValidate: true })
      
      // Reset input
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

      // Use axios directly for multipart/form-data upload
      const token = typeof window !== 'undefined' ? localStorage.getItem('token') : null
      const { data } = await axios.post(`${process.env.NEXT_PUBLIC_API_URL || 'http://localhost:4000/api'}/upload/image`, formData, {
        headers: {
          'Content-Type': 'multipart/form-data',
          ...(token && { Authorization: `Bearer ${token}` }),
        },
      })

      // Response format: { data: { url: "..." } }
      const imageUrl = data?.data?.url || data?.url || ''
      updateUnit(index, 'planImage', imageUrl)
    } catch (error: any) {
      console.error('Error uploading unit image:', error)
      alert(error.response?.data?.message || 'Failed to upload image. Please try again.')
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

      // Set first photo as main photo
      if (photos.length > 0) {
        payload.mainPhotoUrl = photos[0]
      }

      if (data.propertyType === PropertyType.OFF_PLAN) {
        payload.priceFrom = parseFloat(data.priceFrom)
        payload.bedroomsFrom = parseInt(data.bedroomsFrom)
        payload.bedroomsTo = parseInt(data.bedroomsTo)
        payload.bathroomsFrom = parseInt(data.bathroomsFrom)
        payload.bathroomsTo = parseInt(data.bathroomsTo)
        payload.sizeFrom = parseFloat(data.sizeFrom)
        payload.sizeTo = parseFloat(data.sizeTo)
        payload.description = data.description
        payload.paymentPlan = data.paymentPlan || undefined
        payload.facilityIds = data.facilityIds || []
        if (units.length > 0) {
          payload.units = units
            .filter((unit) => unit.unitId && unit.totalSize && unit.price)
            .map((unit) => ({
              unitId: unit.unitId,
              type: unit.type,
              planImage: unit.planImage || '',
              totalSize: parseFloat(unit.totalSize),
              balconySize: unit.balconySize ? parseFloat(unit.balconySize) : undefined,
              price: parseFloat(unit.price),
            }))
        }
      } else {
        payload.price = parseFloat(data.price)
        payload.bedrooms = parseInt(data.bedrooms)
        payload.bathrooms = parseInt(data.bathrooms)
        payload.size = parseFloat(data.size)
      }

      const response = await api.post('/properties', payload)
      console.log('Property created successfully:', response.data)
      
      // Show success message
      alert('Property created successfully!')
      
      // Redirect to properties list
      router.push('/properties')
    } catch (error: any) {
      console.error('Error creating property:', error)
      const errorMessage = 
        error.response?.data?.message || 
        error.response?.data?.error || 
        error.message || 
        'Failed to create property. Please check all required fields.'
      alert(errorMessage)
    } finally {
      setLoading(false)
    }
  }

  const unitTypeOptions = [
    { value: UnitType.APARTMENT, label: 'Apartment' },
    { value: UnitType.VILLA, label: 'Villa' },
    { value: UnitType.PENTHOUSE, label: 'Penthouse' },
    { value: UnitType.TOWNHOUSE, label: 'Townhouse' },
    { value: UnitType.OFFICE, label: 'Office' },
  ]

  const selectedCountryId = watch('countryId')
  const selectedCityId = watch('cityId')
  const selectedFacilities = watch('facilityIds') || []

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-semibold text-gray-800 dark:text-white">Add Property</h1>
        <Button variant="outline" onClick={() => router.back()}>
          Cancel
        </Button>
      </div>

      {/* Property Type Selection */}
      <div className="bg-white dark:bg-gray-900 rounded-xl border border-gray-200 dark:border-gray-800 p-6">
        <Label>Property Type *</Label>
        <div className="mt-3 inline-flex rounded-lg border border-gray-200 p-1 dark:border-gray-800 dark:bg-gray-900">
          <button
            type="button"
            onClick={() => setPropertyType(PropertyType.OFF_PLAN)}
            className={`px-4 py-2 rounded-md text-sm font-medium transition-colors ${
              propertyType === PropertyType.OFF_PLAN
                ? 'bg-brand-500 text-white'
                : 'text-gray-700 hover:bg-gray-100 dark:text-gray-400 dark:hover:bg-white/5'
            }`}
          >
            Off-Plan
          </button>
          <button
            type="button"
            onClick={() => setPropertyType(PropertyType.SECONDARY)}
            className={`px-4 py-2 rounded-md text-sm font-medium transition-colors ${
              propertyType === PropertyType.SECONDARY
                ? 'bg-brand-500 text-white'
                : 'text-gray-700 hover:bg-gray-100 dark:text-gray-400 dark:hover:bg-white/5'
            }`}
          >
            Secondary
          </button>
        </div>
      </div>

      {/* Form */}
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
                      error={!!errors.name}
                    />
                  )}
                />
                {errors.name && (
                  <p className="mt-1 text-sm text-error-500">{errors.name.message}</p>
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
                {errors.countryId && (
                  <p className="mt-1 text-sm text-error-500">{errors.countryId.message}</p>
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
                {errors.cityId && (
                  <p className="mt-1 text-sm text-error-500">{errors.cityId.message}</p>
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
                {errors.areaId && (
                  <p className="mt-1 text-sm text-error-500">{errors.areaId.message}</p>
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
                      error={!!errors.latitude}
                    />
                  )}
                />
                {errors.latitude && (
                  <p className="mt-1 text-sm text-error-500">{errors.latitude.message}</p>
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
                      error={!!errors.longitude}
                    />
                  )}
                />
                {errors.longitude && (
                  <p className="mt-1 text-sm text-error-500">{errors.longitude.message}</p>
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
              {errors.photos && (
                <p className="mt-1 text-sm text-error-500">{errors.photos.message}</p>
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
                    <Input
                      id="priceFrom"
                      type="number"
                      step="0.01"
                      {...register('priceFrom', {
                        valueAsNumber: false,
                        onChange: (e) => {
                          const value = e.target.value
                          setPriceFromValue(value)
                          setValue('priceFrom', value, { shouldValidate: true })
                        }
                      })}
                      placeholder="0.00"
                      error={!!(errors as any).priceFrom}
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
                      {...register('sizeFrom', {
                        valueAsNumber: false,
                        onChange: (e) => {
                          const value = e.target.value
                          setSizeFromValue(value)
                          setValue('sizeFrom', value, { shouldValidate: true })
                        }
                      })}
                      placeholder="0.00"
                      error={!!(errors as any).sizeFrom}
                    />
                    {(errors as any).sizeFrom && (
                      <p className="mt-1 text-sm text-error-500">{errors.sizeFrom.message}</p>
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
                      {...register('sizeTo', {
                        valueAsNumber: false,
                        onChange: (e) => {
                          const value = e.target.value
                          setSizeToValue(value)
                          setValue('sizeTo', value, { shouldValidate: true })
                        }
                      })}
                      placeholder="0.00"
                      error={!!(errors as any).sizeTo}
                    />
                    {(errors as any).sizeTo && (
                      <p className="mt-1 text-sm text-error-500">{errors.sizeTo.message}</p>
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
                {errors.description && (
                  <p className="mt-1 text-sm text-error-500">{errors.description.message}</p>
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
                  {facilities.map((facility) => (
                    <Checkbox
                      key={facility.id}
                      id={`facility-${facility.id}`}
                      label={facility.nameEn}
                      checked={selectedFacilities.includes(facility.id)}
                      onChange={(checked) => {
                        const newFacilities = checked
                          ? [...selectedFacilities, facility.id]
                          : selectedFacilities.filter((id) => id !== facility.id)
                        setValue('facilityIds', newFacilities)
                      }}
                    />
                  ))}
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
                      error={!!errors.price}
                    />
                    {errors.price && (
                      <p className="mt-1 text-sm text-error-500">{errors.price.message}</p>
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
                          error={!!errors.bedrooms}
                        />
                      )}
                    />
                    {errors.bedrooms && (
                      <p className="mt-1 text-sm text-error-500">{errors.bedrooms.message}</p>
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
                          error={!!errors.bathrooms}
                        />
                      )}
                    />
                    {errors.bathrooms && (
                      <p className="mt-1 text-sm text-error-500">{errors.bathrooms.message}</p>
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
                      error={!!errors.size}
                    />
                    {errors.size && (
                      <p className="mt-1 text-sm text-error-500">{errors.size.message}</p>
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
        <div className="flex items-center justify-end gap-4">
          <Button variant="outline" type="button" onClick={() => router.back()}>
            Cancel
          </Button>
          <Button type="submit" disabled={loading}>
            {loading ? 'Creating...' : 'Create Property'}
          </Button>
        </div>
      </form>
    </div>
  )
}
