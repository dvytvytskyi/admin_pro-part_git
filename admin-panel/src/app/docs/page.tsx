'use client'
import { useState } from 'react'

interface Endpoint {
  method: string
  path: string
  description: string
  auth: 'Public' | 'API Key'
  queryParams?: { name: string; type: string; description: string; required: boolean }[]
  responseSchema: string
  exampleResponse: any
}

const endpoints: Endpoint[] = [
  {
    method: 'GET',
    path: '/api/public/data',
    description: 'Get all off-plan properties with locations, developers, and facilities in one request',
    auth: 'API Key',
    responseSchema: `{
  "success": true,
  "data": {
    "properties": [
      {
        "id": "uuid",
        "propertyType": "off-plan",
        "name": "string",
        "description": "string",
        "photos": ["string (URLs)"],
        "country": { "id": "uuid", "nameEn": "string", "nameRu": "string", "nameAr": "string", "code": "string" },
        "city": { "id": "uuid", "nameEn": "string", "nameRu": "string", "nameAr": "string" },
        "area": { "id": "uuid", "nameEn": "string", "nameRu": "string", "nameAr": "string" },
        "developer": { "id": "uuid", "name": "string", "logo": "string", "description": "string" },
        "facilities": [{ "id": "uuid", "nameEn": "string", "nameRu": "string", "nameAr": "string", "iconName": "string" }],
        "units": [{ "id": "uuid", "unitId": "string", "type": "apartment" | "villa" | "penthouse" | "townhouse", "price": "number", "totalSize": "number", "balconySize": "number", "planImage": "string" }],
        "priceFrom": "number",
        "priceFromAED": "number",
        "sizeFrom": "number",
        "sizeTo": "number",
        "sizeFromSqft": "number",
        "sizeToSqft": "number",
        "bedroomsFrom": "number",
        "bedroomsTo": "number",
        "bathroomsFrom": "number",
        "bathroomsTo": "number",
        "paymentPlan": "string",
        "latitude": "number",
        "longitude": "number",
        "createdAt": "ISO date",
        "updatedAt": "ISO date"
      }
    ],
    "countries": [...],
    "cities": [...],
    "areas": [...],
    "developers": [...],
    "facilities": [...]
  }
}`,
    exampleResponse: {
      success: true,
      data: {
        properties: [
          {
            id: '123e4567-e89b-12d3-a456-426614174000',
            propertyType: 'off-plan',
            name: 'Farm Grove The Valley',
            description: 'Beautiful off-plan property description',
            photos: ['https://example.com/photo1.jpg'],
            country: {
              id: '123e4567-e89b-12d3-a456-426614174001',
              nameEn: 'United Arab Emirates',
              nameRu: 'Объединенные Арабские Эмираты',
              nameAr: 'الإمارات العربية المتحدة',
              code: 'AE',
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
              logo: 'https://example.com/logo.jpg',
              description: 'Leading real estate developer',
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
            priceFromAED: 1836500,
            sizeFrom: 80,
            sizeTo: 200,
            sizeFromSqft: 861.12,
            sizeToSqft: 2152.78,
            bedroomsFrom: 1,
            bedroomsTo: 3,
            bathroomsFrom: 1,
            bathroomsTo: 2,
            paymentPlan: '70/30 payment plan',
            latitude: 25.2048,
            longitude: 55.2708,
            createdAt: '2024-01-15T10:00:00.000Z',
            updatedAt: '2024-01-15T10:00:00.000Z',
          },
        ],
        countries: [],
        cities: [],
        areas: [],
        developers: [],
        facilities: [],
      },
    },
  },
  {
    method: 'GET',
    path: '/api/public/areas',
    description: 'Get all areas with off-plan property counts',
    auth: 'Public',
    responseSchema: `{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "nameEn": "string",
      "nameRu": "string",
      "nameAr": "string",
      "cityId": "uuid",
      "offPlanCount": "number"
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
          offPlanCount: 45,
        },
      ],
    },
  },
  {
    method: 'GET',
    path: '/api/public/developers',
    description: 'Get all developers with off-plan property counts',
    auth: 'Public',
    responseSchema: `{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "name": "string",
      "logo": "string (URL)",
      "description": "string",
      "offPlanCount": "number"
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
          offPlanCount: 120,
        },
      ],
    },
  },
]

export default function PublicAPIDocumentationPage() {
  const [copiedEndpoint, setCopiedEndpoint] = useState<string | null>(null)

  const copyToClipboard = (text: string, endpointPath: string) => {
    navigator.clipboard.writeText(text)
    setCopiedEndpoint(endpointPath)
    setTimeout(() => setCopiedEndpoint(null), 2000)
  }

  const baseUrl = typeof window !== 'undefined' 
    ? 'https://admin.pro-part.online/api'
    : 'https://admin.pro-part.online/api'

  return (
    <div className="min-h-screen bg-gray-50 dark:bg-gray-900">
      <div className="max-w-6xl mx-auto px-4 py-12">
        <div className="mb-8">
          <h1 className="text-4xl font-bold text-gray-900 dark:text-white mb-4">
            Off-Plan Properties API Documentation
          </h1>
          <p className="text-lg text-gray-600 dark:text-gray-400 mb-6">
            Public API для отримання даних про off-plan нерухомість. Документація включає тільки endpoints для off-plan properties.
          </p>
          
          {/* Backend Technology Info */}
          <div className="rounded-lg border border-gray-200 bg-gray-50 dark:border-gray-700 dark:bg-gray-800/50 p-4">
            <p className="text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
              Технологія бекенду:
            </p>
            <p className="text-sm text-gray-600 dark:text-gray-400">
              Express.js 5.1 • Node.js • TypeScript • TypeORM • PostgreSQL
            </p>
          </div>
        </div>

        {/* Endpoints List */}
        <div className="space-y-8">
          {endpoints.map((endpoint, index) => (
            <div
              key={index}
              className="rounded-xl border border-gray-200 bg-white p-6 dark:border-gray-800 dark:bg-gray-900 shadow-sm"
            >
              <div className="flex items-start justify-between mb-4">
                <div className="flex-1">
                  <div className="flex items-center gap-3 mb-2">
                    <span className="px-3 py-1 rounded text-sm font-medium bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-400">
                      {endpoint.method}
                    </span>
                    <code className="text-lg font-mono text-gray-900 dark:text-white">
                      {endpoint.path}
                    </code>
                    <span className="px-2 py-1 rounded text-xs font-medium bg-blue-100 text-blue-700 dark:bg-blue-900/30 dark:text-blue-400">
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
                        const authHeader = endpoint.auth === 'API Key' 
                          ? 'X-API-Key: your_api_key\nX-API-Secret: your_api_secret'
                          : ''
                        const curlCommand = `curl -X ${endpoint.method} "${baseUrl}${endpoint.path}" \\
  -H "Content-Type: application/json"${authHeader ? ` \\\n  -H "${authHeader.split('\n')[0]}" \\\n  -H "${authHeader.split('\n')[1]}"` : ''}`
                        copyToClipboard(curlCommand, `curl-${endpoint.method}-${endpoint.path}`)
                      }}
                      className="text-xs text-blue-600 hover:text-blue-700 dark:text-blue-400"
                    >
                      Copy
                    </button>
                  </div>
                  <pre className="text-xs font-mono text-gray-800 dark:text-gray-200 overflow-x-auto">
                    {endpoint.auth === 'API Key' 
                      ? `curl -X ${endpoint.method} "${baseUrl}${endpoint.path}" \\
  -H "Content-Type: application/json" \\
  -H "X-API-Key: your_api_key" \\
  -H "X-API-Secret: your_api_secret"`
                      : `curl -X ${endpoint.method} "${baseUrl}${endpoint.path}" \\
  -H "Content-Type: application/json"`}
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
                      onClick={() => copyToClipboard(endpoint.responseSchema, `schema-${endpoint.method}-${endpoint.path}`)}
                      className="text-xs text-blue-600 hover:text-blue-700 dark:text-blue-400"
                    >
                      Copy
                    </button>
                  </div>
                  <pre className="text-xs font-mono text-gray-800 dark:text-gray-200 overflow-x-auto whitespace-pre-wrap max-h-96 overflow-y-auto">
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

        {/* API Key Info */}
        <div className="mt-8 rounded-xl border border-blue-200 bg-blue-50 dark:border-blue-900 dark:bg-blue-900/20 p-6">
          <h3 className="text-lg font-semibold text-blue-900 dark:text-blue-400 mb-2">
            🔑 API Key Authentication
          </h3>
          <p className="text-sm text-blue-800 dark:text-blue-300 mb-4">
            Для використання API endpoints, які потребують авторизації, вам потрібен API Key та API Secret.
            Зверніться до адміністратора для отримання доступу.
          </p>
          <div className="bg-white dark:bg-gray-900 rounded-lg p-4 border border-blue-200 dark:border-blue-800">
            <code className="block text-sm font-mono text-gray-900 dark:text-gray-100">
              X-API-Key: your_api_key<br />
              X-API-Secret: your_api_secret
            </code>
          </div>
        </div>

        {/* Base URL Info */}
        <div className="mt-6 rounded-xl border border-gray-200 bg-white dark:border-gray-800 dark:bg-gray-900 p-6">
          <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-2">
            🌐 Base URL
          </h3>
          <code className="block text-lg font-mono text-gray-900 dark:text-gray-100">
            {baseUrl}
          </code>
        </div>
      </div>
    </div>
  )
}

