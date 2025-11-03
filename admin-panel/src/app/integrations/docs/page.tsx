'use client'
import { useState } from 'react'

interface Endpoint {
  method: string
  path: string
  description: string
  auth: 'JWT' | 'API Key' | 'Both'
  queryParams?: { name: string; type: string; description: string; required: boolean }[]
  bodyParams?: { name: string; type: string; description: string; required: boolean }[]
  responseSchema: string
  exampleResponse: any
}

const endpoints: { [key: string]: Endpoint[] } = {
  properties: [
    {
      method: 'GET',
      path: '/api/properties',
      description: 'Get list of all properties with optional filters',
      auth: 'Both',
      queryParams: [
        { name: 'propertyType', type: 'string', description: 'Filter by property type: "off-plan" or "secondary"', required: false },
        { name: 'developerId', type: 'string', description: 'Filter by developer ID (UUID)', required: false },
        { name: 'cityId', type: 'string', description: 'Filter by city ID (UUID)', required: false },
      ],
      responseSchema: `{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "propertyType": "off-plan" | "secondary",
      "name": "string",
      "description": "string",
      "photos": ["string (URLs)"],
      "country": { "id": "uuid", "nameEn": "string", "nameRu": "string", "nameAr": "string", "code": "string" },
      "city": { "id": "uuid", "nameEn": "string", "nameRu": "string", "nameAr": "string" },
      "area": { "id": "uuid", "nameEn": "string", "nameRu": "string", "nameAr": "string" },
      "developer": { "id": "uuid", "name": "string" },
      "facilities": [{ "id": "uuid", "nameEn": "string", "nameRu": "string", "nameAr": "string", "iconName": "string" }],
      "units": [{ "id": "uuid", "unitId": "string", "type": "apartment" | "villa" | "penthouse" | "townhouse" | "office", "price": "number", "totalSize": "number", "balconySize": "number", "planImage": "string" }],
      "paymentPlan": "string (for off-plan)",
      "price": "number (for secondary)",
      "priceFrom": "number (for off-plan)",
      "priceAED": "number",
      "priceFromAED": "number",
      "size": "number",
      "sizeFrom": "number",
      "sizeTo": "number",
      "sizeSqft": "number",
      "sizeFromSqft": "number",
      "sizeToSqft": "number",
      "bedrooms": "number",
      "bedroomsFrom": "number",
      "bedroomsTo": "number",
      "bathrooms": "number",
      "latitude": "number",
      "longitude": "number",
      "createdAt": "ISO date",
      "updatedAt": "ISO date"
    }
  ]
}`,
      exampleResponse: {
        success: true,
        data: [
          {
            id: '123e4567-e89b-12d3-a456-426614174000',
            propertyType: 'off-plan',
            name: 'Example Property',
            description: 'Beautiful property description',
            photos: ['https://example.com/photo1.jpg'],
            country: {
              id: '123e4567-e89b-12d3-a456-426614174001',
              nameEn: 'United Arab Emirates',
              nameRu: 'Объединенные Арабские Эмираты',
              nameAr: 'الإمارات العربية المتحدة',
              code: 'UAE',
            },
            city: {
              id: '123e4567-e89b-12d3-a456-426614174002',
              nameEn: 'Dubai',
              nameRu: 'Дубай',
              nameAr: 'دبي',
            },
            area: {
              id: '123e4567-e89b-12d3-a456-426614174003',
              nameEn: 'Downtown Dubai',
              nameRu: 'Даунтаун Дубай',
              nameAr: 'دبي مارينا',
            },
            developer: {
              id: '123e4567-e89b-12d3-a456-426614174004',
              name: 'Emaar Properties',
            },
            facilities: [
              {
                id: '123e4567-e89b-12d3-a456-426614174005',
                nameEn: 'Swimming Pool',
                nameRu: 'Бассейн',
                nameAr: 'مسبح',
                iconName: 'pool',
              },
            ],
            units: [
              {
                id: '123e4567-e89b-12d3-a456-426614174006',
                unitId: 'APT-101',
                type: 'apartment',
                price: 500000,
                totalSize: 120.5,
                balconySize: 15.2,
                planImage: 'https://example.com/plan.jpg',
              },
            ],
            priceFrom: 500000,
            paymentPlan: '70/30 payment plan',
            priceFromAED: 1836500,
            sizeFrom: 80,
            sizeTo: 200,
            sizeFromSqft: 861.12,
            sizeToSqft: 2152.78,
            bedroomsFrom: 1,
            bedroomsTo: 3,
            bathroomsFrom: 1,
            bathroomsTo: 2,
            latitude: 25.2048,
            longitude: 55.2708,
            createdAt: '2024-01-15T10:00:00.000Z',
            updatedAt: '2024-01-15T10:00:00.000Z',
          },
        ],
      },
    },
    {
      method: 'GET',
      path: '/api/properties/:id',
      description: 'Get a single property by ID',
      auth: 'Both',
      responseSchema: 'Same as GET /api/properties, but returns single object instead of array',
      exampleResponse: {
        success: true,
        data: {
          id: '123e4567-e89b-12d3-a456-426614174000',
          propertyType: 'off-plan',
          name: 'Example Property',
          // ... same structure as above
        },
      },
    },
  ],
  users: [
    {
      method: 'GET',
      path: '/api/users',
      description: 'Get list of all users (password hash is excluded)',
      auth: 'Both',
      responseSchema: `{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "firstName": "string",
      "lastName": "string",
      "email": "string",
      "phone": "string",
      "role": "CLIENT" | "BROKER" | "INVESTOR" | "ADMIN",
      "status": "PENDING" | "ACTIVE" | "BLOCKED" | "REJECTED",
      "avatar": "string (URL)",
      "licenseNumber": "string",
      "createdAt": "ISO date",
      "updatedAt": "ISO date"
    }
  ]
}`,
      exampleResponse: {
        success: true,
        data: [
          {
            id: '123e4567-e89b-12d3-a456-426614174000',
            firstName: 'John',
            lastName: 'Doe',
            email: 'john.doe@example.com',
            phone: '+971501234567',
            role: 'BROKER',
            status: 'ACTIVE',
            avatar: 'https://example.com/avatar.jpg',
            licenseNumber: 'RERA-12345',
            createdAt: '2024-01-15T10:00:00.000Z',
            updatedAt: '2024-01-15T10:00:00.000Z',
          },
        ],
      },
    },
    {
      method: 'GET',
      path: '/api/users/:id',
      description: 'Get a single user by ID',
      auth: 'Both',
      responseSchema: 'Same as GET /api/users, but returns single object',
      exampleResponse: {
        success: true,
        data: {
          id: '123e4567-e89b-12d3-a456-426614174000',
          firstName: 'John',
          lastName: 'Doe',
          // ... same structure as above
        },
      },
    },
  ],
  news: [
    {
      method: 'GET',
      path: '/api/news',
      description: 'Get list of all news articles',
      auth: 'Both',
      responseSchema: `{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "title": "string",
      "description": "string",
      "imageUrl": "string (URL)",
      "isPublished": "boolean",
      "publishedAt": "ISO date",
      "contents": [
        {
          "id": "uuid",
          "language": "en" | "ru" | "ar",
          "title": "string",
          "content": "string"
        }
      ],
      "createdAt": "ISO date",
      "updatedAt": "ISO date"
    }
  ]
}`,
      exampleResponse: {
        success: true,
        data: [
          {
            id: '123e4567-e89b-12d3-a456-426614174000',
            title: 'Real Estate Market Update',
            description: 'Latest updates on Dubai real estate',
            imageUrl: 'https://example.com/news.jpg',
            isPublished: true,
            publishedAt: '2024-01-15T10:00:00.000Z',
            contents: [
              {
                id: '123e4567-e89b-12d3-a456-426614174001',
                language: 'en',
                title: 'Real Estate Market Update',
                content: 'Full article content...',
              },
            ],
            createdAt: '2024-01-15T10:00:00.000Z',
            updatedAt: '2024-01-15T10:00:00.000Z',
          },
        ],
      },
    },
    {
      method: 'GET',
      path: '/api/news/:id',
      description: 'Get a single news article by ID',
      auth: 'Both',
      responseSchema: 'Same as GET /api/news, but returns single object',
      exampleResponse: {
        success: true,
        data: {
          id: '123e4567-e89b-12d3-a456-426614174000',
          title: 'Real Estate Market Update',
          // ... same structure as above
        },
      },
    },
  ],
  'knowledge-base': [
    {
      method: 'GET',
      path: '/api/courses',
      description: 'Get list of all courses (knowledge base articles)',
      auth: 'Both',
      responseSchema: `{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "title": "string",
      "description": "string",
      "order": "number",
      "contents": [
        {
          "id": "uuid",
          "language": "en" | "ru" | "ar",
          "title": "string",
          "content": "string"
        }
      ],
      "links": [
        {
          "id": "uuid",
          "title": "string",
          "url": "string",
          "description": "string"
        }
      ],
      "createdAt": "ISO date",
      "updatedAt": "ISO date"
    }
  ]
}`,
      exampleResponse: {
        success: true,
        data: [
          {
            id: '123e4567-e89b-12d3-a456-426614174000',
            title: 'Real Estate Guide',
            description: 'Complete guide to real estate',
            order: 1,
            contents: [
              {
                id: '123e4567-e89b-12d3-a456-426614174001',
                language: 'en',
                title: 'Introduction',
                content: 'Course content...',
              },
            ],
            links: [
              {
                id: '123e4567-e89b-12d3-a456-426614174002',
                title: 'External Resource',
                url: 'https://example.com/resource',
                description: 'Helpful resource',
              },
            ],
            createdAt: '2024-01-15T10:00:00.000Z',
            updatedAt: '2024-01-15T10:00:00.000Z',
          },
        ],
      },
    },
    {
      method: 'GET',
      path: '/api/courses/:id',
      description: 'Get a single course by ID',
      auth: 'Both',
      responseSchema: 'Same as GET /api/courses, but returns single object',
      exampleResponse: {
        success: true,
        data: {
          id: '123e4567-e89b-12d3-a456-426614174000',
          title: 'Real Estate Guide',
          // ... same structure as above
        },
      },
    },
  ],
  settings: [
    {
      method: 'GET',
      path: '/api/settings/locations',
      description: 'Get all locations (countries, cities, areas) in one response',
      auth: 'Both',
      responseSchema: `{
  "success": true,
  "data": {
    "countries": [
      {
        "id": "uuid",
        "nameEn": "string",
        "nameRu": "string",
        "nameAr": "string",
        "code": "string",
        "cities": [{ "id": "uuid", "nameEn": "string", ... }]
      }
    ],
    "cities": [
      {
        "id": "uuid",
        "nameEn": "string",
        "nameRu": "string",
        "nameAr": "string",
        "countryId": "uuid",
        "areas": [{ "id": "uuid", "nameEn": "string", ... }]
      }
    ],
    "areas": [
      {
        "id": "uuid",
        "nameEn": "string",
        "nameRu": "string",
        "nameAr": "string",
        "cityId": "uuid"
      }
    ]
  }
}`,
      exampleResponse: {
        success: true,
        data: {
          countries: [
            {
              id: '123e4567-e89b-12d3-a456-426614174000',
              nameEn: 'United Arab Emirates',
              nameRu: 'Объединенные Арабские Эмираты',
              nameAr: 'الإمارات العربية المتحدة',
              code: 'UAE',
              cities: [],
            },
          ],
          cities: [
            {
              id: '123e4567-e89b-12d3-a456-426614174001',
              nameEn: 'Dubai',
              nameRu: 'Дубай',
              nameAr: 'دبي',
              countryId: '123e4567-e89b-12d3-a456-426614174000',
              areas: [],
            },
          ],
          areas: [
            {
              id: '123e4567-e89b-12d3-a456-426614174002',
              nameEn: 'Downtown Dubai',
              nameRu: 'Даунтаун Дубай',
              nameAr: 'دبي مارينا',
              cityId: '123e4567-e89b-12d3-a456-426614174001',
            },
          ],
        },
      },
    },
    {
      method: 'GET',
      path: '/api/settings/countries',
      description: 'Get list of all countries',
      auth: 'Both',
      responseSchema: `{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "nameEn": "string",
      "nameRu": "string",
      "nameAr": "string",
      "code": "string",
      "cities": [{ "id": "uuid", "nameEn": "string", ... }]
    }
  ]
}`,
      exampleResponse: {
        success: true,
        data: [
          {
            id: '123e4567-e89b-12d3-a456-426614174000',
            nameEn: 'United Arab Emirates',
            nameRu: 'Объединенные Арабские Эмираты',
            nameAr: 'الإمارات العربية المتحدة',
            code: 'UAE',
            cities: [],
          },
        ],
      },
    },
    {
      method: 'GET',
      path: '/api/settings/cities',
      description: 'Get list of all cities, optionally filtered by countryId',
      auth: 'Both',
      queryParams: [
        { name: 'countryId', type: 'string', description: 'Filter cities by country ID (UUID)', required: false },
      ],
      responseSchema: `{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "nameEn": "string",
      "nameRu": "string",
      "nameAr": "string",
      "countryId": "uuid",
      "areas": [{ "id": "uuid", "nameEn": "string", ... }]
    }
  ]
}`,
      exampleResponse: {
        success: true,
        data: [
          {
            id: '123e4567-e89b-12d3-a456-426614174001',
            nameEn: 'Dubai',
            nameRu: 'Дубай',
            nameAr: 'دبي',
            countryId: '123e4567-e89b-12d3-a456-426614174000',
            areas: [],
          },
        ],
      },
    },
    {
      method: 'GET',
      path: '/api/settings/areas',
      description: 'Get list of all areas, optionally filtered by cityId',
      auth: 'Both',
      queryParams: [
        { name: 'cityId', type: 'string', description: 'Filter areas by city ID (UUID)', required: false },
      ],
      responseSchema: `{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "nameEn": "string",
      "nameRu": "string",
      "nameAr": "string",
      "cityId": "uuid"
    }
  ]
}`,
      exampleResponse: {
        success: true,
        data: [
          {
            id: '123e4567-e89b-12d3-a456-426614174002',
            nameEn: 'Downtown Dubai',
            nameRu: 'Даунтаун Дубай',
            nameAr: 'دبي مارينا',
            cityId: '123e4567-e89b-12d3-a456-426614174001',
          },
        ],
      },
    },
    {
      method: 'GET',
      path: '/api/settings/developers',
      description: 'Get list of all developers',
      auth: 'Both',
      responseSchema: `{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "name": "string",
      "logo": "string (URL)",
      "description": "string",
      "createdAt": "ISO date"
    }
  ]
}`,
      exampleResponse: {
        success: true,
        data: [
          {
            id: '123e4567-e89b-12d3-a456-426614174000',
            name: 'Emaar Properties',
            logo: 'https://example.com/logo.jpg',
            description: 'Leading real estate developer',
            createdAt: '2024-01-15T10:00:00.000Z',
          },
        ],
      },
    },
    {
      method: 'GET',
      path: '/api/settings/facilities',
      description: 'Get list of all facilities (amenities)',
      auth: 'Both',
      responseSchema: `{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "nameEn": "string",
      "nameRu": "string",
      "nameAr": "string",
      "iconName": "string",
      "createdAt": "ISO date"
    }
  ]
}`,
      exampleResponse: {
        success: true,
        data: [
          {
            id: '123e4567-e89b-12d3-a456-426614174000',
            nameEn: 'Swimming Pool',
            nameRu: 'Бассейн',
            nameAr: 'مسبح',
            iconName: 'pool',
            createdAt: '2024-01-15T10:00:00.000Z',
          },
        ],
      },
    },
  ],
}

export default function APIDocumentationPage() {
  const [activeSection, setActiveSection] = useState<string>('properties')
  const [copiedEndpoint, setCopiedEndpoint] = useState<string | null>(null)

  const copyToClipboard = (text: string, endpointPath: string) => {
    navigator.clipboard.writeText(text)
    setCopiedEndpoint(endpointPath)
    setTimeout(() => setCopiedEndpoint(null), 2000)
  }

  const getAuthHeader = (authType: string) => {
    if (authType === 'JWT') {
      return 'Authorization: Bearer <your_jwt_token>'
    }
    if (authType === 'API Key') {
      return 'X-API-Key: <your_api_key>\nX-API-Secret: <your_api_secret>'
    }
    return 'Authorization: Bearer <your_jwt_token>\n// OR\nX-API-Key: <your_api_key>\nX-API-Secret: <your_api_secret>'
  }

  // Використовуємо правильний API URL з env або автоматично визначаємо
  const baseUrl = typeof window !== 'undefined' 
    ? (process.env.NEXT_PUBLIC_API_URL || window.location.origin + '/api')
    : (process.env.NEXT_PUBLIC_API_URL || 'http://localhost:4000/api')
  
  // Використовуємо правильний baseUrl
  // Якщо NEXT_PUBLIC_API_URL вже містить /api, використовуємо як є
  // Інакше додаємо /api

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-semibold text-gray-900 dark:text-white mb-2">
          API Documentation
        </h1>
        <p className="text-sm text-gray-500 dark:text-gray-400">
          Complete API reference for all available endpoints
        </p>
        
        {/* Backend Technology Info */}
        <div className="mt-4 rounded-lg border border-gray-200 bg-gray-50 dark:border-gray-700 dark:bg-gray-800/50 p-4">
          <p className="text-xs font-medium text-gray-700 dark:text-gray-300 mb-1">
            Технологія бекенду:
          </p>
          <p className="text-xs text-gray-600 dark:text-gray-400">
            Express.js 5.1 • Node.js • TypeScript • TypeORM • PostgreSQL
          </p>
        </div>
      </div>

      {/* Navigation */}
      <div className="rounded-xl border border-gray-200 bg-white p-6 dark:border-gray-800 dark:bg-gray-900">
        <div className="flex flex-wrap gap-2">
          {Object.keys(endpoints).map((section) => (
            <button
              key={section}
              onClick={() => setActiveSection(section)}
              className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors ${
                activeSection === section
                  ? 'bg-blue-600 text-white'
                  : 'bg-gray-100 text-gray-700 hover:bg-gray-200 dark:bg-gray-800 dark:text-gray-300 dark:hover:bg-gray-700'
              }`}
            >
              {section.charAt(0).toUpperCase() + section.slice(1).replace('-', ' ')}
            </button>
          ))}
        </div>
      </div>

      {/* Endpoints List */}
      <div className="space-y-6">
        {endpoints[activeSection]?.map((endpoint, index) => (
          <div
            key={index}
            className="rounded-xl border border-gray-200 bg-white p-6 dark:border-gray-800 dark:bg-gray-900"
          >
            <div className="flex items-start justify-between mb-4">
              <div className="flex-1">
                <div className="flex items-center gap-3 mb-2">
                  <span
                    className={`px-3 py-1 rounded text-sm font-medium ${
                      endpoint.method === 'GET'
                        ? 'bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-400'
                        : endpoint.method === 'POST'
                        ? 'bg-blue-100 text-blue-800 dark:bg-blue-900/30 dark:text-blue-400'
                        : endpoint.method === 'PATCH'
                        ? 'bg-yellow-100 text-yellow-800 dark:bg-yellow-900/30 dark:text-yellow-400'
                        : 'bg-red-100 text-red-800 dark:bg-red-900/30 dark:text-red-400'
                    }`}
                  >
                    {endpoint.method}
                  </span>
                  <code className="text-lg font-mono text-gray-900 dark:text-white">
                    {endpoint.path}
                  </code>
                  <span className="px-2 py-1 rounded text-xs font-medium bg-gray-100 text-gray-700 dark:bg-gray-800 dark:text-gray-300">
                    {endpoint.auth}
                  </span>
                </div>
                <p className="text-gray-600 dark:text-gray-400">{endpoint.description}</p>
              </div>
              <button
                onClick={() => copyToClipboard(`${baseUrl}${endpoint.path}`, `${endpoint.method} ${endpoint.path}`)}
                className="px-3 py-1.5 text-sm text-blue-600 hover:text-blue-700 dark:text-blue-400 dark:hover:text-blue-300 hover:bg-blue-50 dark:hover:bg-blue-900/20 rounded-lg transition-colors"
                title="Copy endpoint URL"
              >
                {copiedEndpoint === `${endpoint.method} ${endpoint.path}` ? (
                  <span className="text-green-600 dark:text-green-400">✓ Copied</span>
                ) : (
                  <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z" />
                  </svg>
                )}
              </button>
            </div>

            {/* Query Parameters */}
            {endpoint.queryParams && endpoint.queryParams.length > 0 && (
              <div className="mb-4">
                <h4 className="text-sm font-semibold text-gray-700 dark:text-gray-300 mb-2">Query Parameters</h4>
                <div className="overflow-x-auto">
                  <table className="w-full text-sm">
                    <thead>
                      <tr className="border-b border-gray-200 dark:border-gray-700">
                        <th className="text-left py-2 px-3 text-gray-600 dark:text-gray-400">Name</th>
                        <th className="text-left py-2 px-3 text-gray-600 dark:text-gray-400">Type</th>
                        <th className="text-left py-2 px-3 text-gray-600 dark:text-gray-400">Required</th>
                        <th className="text-left py-2 px-3 text-gray-600 dark:text-gray-400">Description</th>
                      </tr>
                    </thead>
                    <tbody>
                      {endpoint.queryParams.map((param, idx) => (
                        <tr key={idx} className="border-b border-gray-100 dark:border-gray-800">
                          <td className="py-2 px-3 font-mono text-gray-900 dark:text-white">{param.name}</td>
                          <td className="py-2 px-3 text-gray-600 dark:text-gray-400">{param.type}</td>
                          <td className="py-2 px-3">
                            <span className={`px-2 py-0.5 rounded text-xs ${param.required ? 'bg-red-100 text-red-800 dark:bg-red-900/30 dark:text-red-400' : 'bg-gray-100 text-gray-600 dark:bg-gray-800 dark:text-gray-400'}`}>
                              {param.required ? 'Yes' : 'No'}
                            </span>
                          </td>
                          <td className="py-2 px-3 text-gray-600 dark:text-gray-400">{param.description}</td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              </div>
            )}

            {/* Request Example */}
            <div className="mb-4">
              <h4 className="text-sm font-semibold text-gray-700 dark:text-gray-300 mb-2">Request Example</h4>
              <div className="bg-gray-50 dark:bg-gray-800 rounded-lg p-4 border border-gray-200 dark:border-gray-700">
                <div className="flex items-center justify-between mb-2">
                  <span className="text-xs text-gray-500 dark:text-gray-400">cURL</span>
                  <button
                    onClick={() => {
                      const curlCommand = `curl -X ${endpoint.method} "${baseUrl}${endpoint.path}${endpoint.queryParams?.find(p => p.name === 'propertyType') ? '?propertyType=off-plan' : ''}" \\
  -H "Content-Type: application/json" \\
  -H "${getAuthHeader(endpoint.auth).split('\n')[0]}"`
                      copyToClipboard(curlCommand, `curl-${endpoint.method}-${endpoint.path}`)
                    }}
                    className="text-xs text-blue-600 hover:text-blue-700 dark:text-blue-400"
                  >
                    Copy
                  </button>
                </div>
                <pre className="text-xs font-mono text-gray-800 dark:text-gray-200 overflow-x-auto">
                  {`curl -X ${endpoint.method} "${baseUrl}${endpoint.path}${endpoint.queryParams?.find(p => p.name === 'propertyType') ? '?propertyType=off-plan' : ''}" \\
  -H "Content-Type: application/json" \\
  -H "${getAuthHeader(endpoint.auth).split('\n')[0]}"`}
                </pre>
              </div>
            </div>

            {/* Response Schema */}
            <div className="mb-4">
              <h4 className="text-sm font-semibold text-gray-700 dark:text-gray-300 mb-2">Response Schema</h4>
              <div className="bg-gray-50 dark:bg-gray-800 rounded-lg p-4 border border-gray-200 dark:border-gray-700">
                <div className="flex items-center justify-between mb-2">
                  <span className="text-xs text-gray-500 dark:text-gray-400">JSON Schema</span>
                  <button
                    onClick={() => copyToClipboard(JSON.stringify(endpoint.exampleResponse, null, 2), `schema-${endpoint.method}-${endpoint.path}`)}
                    className="text-xs text-blue-600 hover:text-blue-700 dark:text-blue-400"
                  >
                    Copy
                  </button>
                </div>
                <pre className="text-xs font-mono text-gray-800 dark:text-gray-200 overflow-x-auto whitespace-pre-wrap">
                  {endpoint.responseSchema}
                </pre>
              </div>
            </div>

            {/* Example Response */}
            <div>
              <h4 className="text-sm font-semibold text-gray-700 dark:text-gray-300 mb-2">Example Response</h4>
              <div className="bg-gray-50 dark:bg-gray-800 rounded-lg p-4 border border-gray-200 dark:border-gray-700">
                <div className="flex items-center justify-between mb-2">
                  <span className="text-xs text-gray-500 dark:text-gray-400">JSON</span>
                  <button
                    onClick={() => copyToClipboard(JSON.stringify(endpoint.exampleResponse, null, 2), `example-${endpoint.method}-${endpoint.path}`)}
                    className="text-xs text-blue-600 hover:text-blue-700 dark:text-blue-400"
                  >
                    Copy
                  </button>
                </div>
                <pre className="text-xs font-mono text-gray-800 dark:text-gray-200 overflow-x-auto max-h-96 overflow-y-auto">
                  {JSON.stringify(endpoint.exampleResponse, null, 2)}
                </pre>
              </div>
            </div>
          </div>
        ))}
      </div>

      {/* Public API Info */}
      <div className="rounded-xl border border-blue-200 bg-blue-50 dark:border-blue-900 dark:bg-blue-900/20 p-6">
        <h3 className="text-lg font-semibold text-blue-900 dark:text-blue-400 mb-2">
          Public API Endpoint
        </h3>
        <p className="text-sm text-blue-800 dark:text-blue-300 mb-4">
          For fetching all data in one request, use the public endpoint:
        </p>
        <div className="bg-white dark:bg-gray-900 rounded-lg p-4 border border-blue-200 dark:border-blue-800">
          <code className="block text-sm font-mono text-gray-900 dark:text-gray-100 mb-2">
            GET {baseUrl}/api/public/data
          </code>
          <p className="text-xs text-blue-700 dark:text-blue-400 mb-2">Headers:</p>
          <code className="block text-xs font-mono text-gray-900 dark:text-gray-100">
            X-API-Key: your_api_key<br />
            X-API-Secret: your_api_secret
          </code>
          <p className="text-xs text-blue-700 dark:text-blue-400 mt-3">
            Returns all properties, countries, cities, areas, developers, and facilities with conversions (AED, sqft).
          </p>
        </div>
      </div>
    </div>
  )
}

