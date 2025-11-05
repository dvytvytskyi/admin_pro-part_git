# Developers API Documentation

## Base URL
```
/api/settings/developers
```

## Authentication
All endpoints require authentication:
- **JWT Token** (via `Authorization: Bearer <token>` header), OR
- **API Key** (via `x-api-key` header)

---

## 📋 Developer Entity Schema

```typescript
{
  id: string;              // UUID (auto-generated)
  name: string;            // Unique developer name (required)
  logo: string | null;     // Logo URL (optional)
  description: string | null;  // Developer description text (optional)
  images: string[] | null; // Array of photo URLs (optional)
  createdAt: Date;         // Auto-generated creation timestamp
}
```

---

## 🔍 Endpoints

### 1. GET `/api/settings/developers`
Get all developers.

**Request:**
```http
GET /api/settings/developers
Authorization: Bearer <token>
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "8315af5e-2d12-4537-9e25-a7fcc29d3619",
      "name": "Maakdream Properties",
      "logo": "https://files.alnair.ae/uploads/2025/7/ad/01/ad01434e1798e1b7a74d23cd662fca8b.jpg",
      "description": "MAAKDREAM is the real estate brand of the future...",
      "images": [
        "https://files.alnair.ae/uploads/2025/7/ad/01/ad01434e1798e1b7a74d23cd662fca8b.jpg",
        "https://files.alnair.ae/uploads/gallery_photo/2025/7/a1/f0/a1f0a3f7b20abd931b9b48ca8befd5e9.png"
      ],
      "createdAt": "2025-11-02T20:37:51.000Z"
    }
  ]
}
```

**Status Codes:**
- `200` - Success
- `401` - Unauthorized
- `403` - Forbidden

---

### 2. POST `/api/settings/developers`
Create a new developer.

**Request:**
```http
POST /api/settings/developers
Authorization: Bearer <token>
Content-Type: application/json

{
  "name": "New Developer Name"
}
```

**Request Body:**
```typescript
{
  name: string;  // Required, unique developer name
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "new-uuid-here",
    "name": "New Developer Name",
    "logo": null,
    "description": null,
    "images": null,
    "createdAt": "2025-11-05T12:00:00.000Z"
  }
}
```

**Status Codes:**
- `200` - Success
- `400` - Bad Request (missing or invalid name)
- `409` - Conflict (developer with this name already exists)
- `401` - Unauthorized
- `500` - Internal Server Error

**Error Response (400):**
```json
{
  "success": false,
  "message": "Developer name is required"
}
```

**Error Response (409):**
```json
{
  "success": false,
  "message": "Developer with this name already exists"
}
```

---

### 3. PUT `/api/settings/developers/:id`
Update an existing developer.

**Request:**
```http
PUT /api/settings/developers/8315af5e-2d12-4537-9e25-a7fcc29d3619
Authorization: Bearer <token>
Content-Type: application/json

{
  "name": "Updated Developer Name",
  "logo": "https://example.com/logo.jpg",
  "description": "Updated description text",
  "images": [
    "https://example.com/photo1.jpg",
    "https://example.com/photo2.jpg"
  ]
}
```

**Request Body:**
```typescript
{
  name?: string;           // Optional, developer name
  logo?: string;           // Optional, logo URL (empty string to clear)
  description?: string;    // Optional, description text (empty string to clear)
  images?: string[];       // Optional, array of photo URLs (empty array to clear)
}
```

**Note:** All fields are optional. Only provided fields will be updated.

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "8315af5e-2d12-4537-9e25-a7fcc29d3619",
    "name": "Updated Developer Name",
    "logo": "https://example.com/logo.jpg",
    "description": "Updated description text",
    "images": [
      "https://example.com/photo1.jpg",
      "https://example.com/photo2.jpg"
    ],
    "createdAt": "2025-11-02T20:37:51.000Z"
  }
}
```

**Status Codes:**
- `200` - Success
- `404` - Developer not found
- `401` - Unauthorized
- `500` - Internal Server Error

**Error Response (404):**
```json
{
  "success": false,
  "message": "Developer not found"
}
```

---

### 4. DELETE `/api/settings/developers/:id`
Delete a developer.

**Request:**
```http
DELETE /api/settings/developers/8315af5e-2d12-4537-9e25-a7fcc29d3619
Authorization: Bearer <token>
```

**Response:**
```json
{
  "success": true,
  "data": null,
  "message": "Developer deleted successfully"
}
```

**Status Codes:**
- `200` - Success
- `404` - Developer not found
- `401` - Unauthorized
- `500` - Internal Server Error

**Error Response (404):**
```json
{
  "success": false,
  "message": "Developer not found"
}
```

---

### 5. POST `/api/settings/developers/cleanup-duplicates`
Remove duplicate developers (keeps only the first occurrence of each name).

**Request:**
```http
POST /api/settings/developers/cleanup-duplicates
Authorization: Bearer <token>
```

**Response:**
```json
{
  "success": true,
  "data": {
    "deleted": 85,
    "kept": 490,
    "totalBefore": 575,
    "totalAfter": 490
  },
  "message": "Removed 85 duplicate developers, kept 490 unique developers"
}
```

**Response Schema:**
```typescript
{
  deleted: number;      // Number of duplicates deleted
  kept: number;         // Number of unique developers kept
  totalBefore: number;  // Total developers before cleanup
  totalAfter: number;   // Total developers after cleanup
}
```

**Status Codes:**
- `200` - Success
- `401` - Unauthorized
- `500` - Internal Server Error

---

## 📝 Examples

### Example 1: Get all developers
```bash
curl -X GET "http://localhost:4000/api/settings/developers" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Example 2: Create a developer
```bash
curl -X POST "http://localhost:4000/api/settings/developers" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "New Developer"
  }'
```

### Example 3: Update a developer
```bash
curl -X PUT "http://localhost:4000/api/settings/developers/8315af5e-2d12-4537-9e25-a7fcc29d3619" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "logo": "https://example.com/logo.jpg",
    "description": "Updated description",
    "images": ["https://example.com/photo1.jpg"]
  }'
```

### Example 4: Delete a developer
```bash
curl -X DELETE "http://localhost:4000/api/settings/developers/8315af5e-2d12-4537-9e25-a7fcc29d3619" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Example 5: Clean up duplicates
```bash
curl -X POST "http://localhost:4000/api/settings/developers/cleanup-duplicates" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

---

## 🔗 Related Endpoints

### Public API - Get Developers
Public endpoint for mobile app (requires API key):

```http
GET /api/public/data
x-api-key: YOUR_API_KEY
```

**Response includes developers in this format:**
```json
{
  "success": true,
  "data": {
    "developers": [
      {
        "id": "8315af5e-2d12-4537-9e25-a7fcc29d3619",
        "name": "Maakdream Properties",
        "logo": "https://...",
        "description": "...",
        "images": ["https://..."]
      }
    ]
  }
}
```

---

## ⚠️ Important Notes

1. **Name Uniqueness**: Developer `name` must be unique. Attempting to create a duplicate will return a `409 Conflict` error.

2. **Images Array**: The `images` field is stored as a PostgreSQL array (`simple-array` in TypeORM). When updating, always provide the full array (not just new items).

3. **Partial Updates**: For `PUT` requests, only include fields you want to update. Omitted fields will remain unchanged.

4. **Empty Values**: To clear a field:
   - `logo`: Set to empty string `""`
   - `description`: Set to empty string `""`
   - `images`: Set to empty array `[]` or `null`

5. **Authentication**: All endpoints require either:
   - JWT token in `Authorization: Bearer <token>` header, OR
   - API key in `x-api-key` header

---

## 📊 Current Statistics

- **Total Developers**: 490
- **Developers with Data**: 489 (have logo, description, or images)
- **All developers are synced with `developer.json`**

