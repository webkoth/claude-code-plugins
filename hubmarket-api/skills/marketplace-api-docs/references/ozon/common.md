# Ozon API Common

## Base URL

```
https://api-seller.ozon.ru
```

All endpoints use this single base URL.

## Authentication

**Headers (required for all requests):**
```
Client-Id: {your_client_id}
Api-Key: {your_api_key}
Content-Type: application/json
```

**Method:** All requests are POST, even for read operations!

**Curl template:**
```bash
curl -X POST 'https://api-seller.ozon.ru/{endpoint}' \
  -H 'Client-Id: {client_id}' \
  -H 'Api-Key: {api_key}' \
  -H 'Content-Type: application/json' \
  -d '{request_body}'
```

## Validate API Key

**Endpoint:** `POST /v4/product/info/limit`

**Request:** `{}`

**Response (success):**
```json
{
  "daily_create": { "limit": 1000, "reset_at": "...", "usage": 5 },
  "daily_update": { "limit": 10000, "reset_at": "...", "usage": 100 }
}
```

---

## Warehouses

**Endpoint:** `POST /v1/warehouse/list`

**Request:** `{}`

**Response:**
```json
{
  "result": [
    {
      "warehouse_id": 22142605386000,
      "name": "My FBS Warehouse",
      "is_rfbs": false
    }
  ]
}
```

**TypeScript Interface:**
```typescript
interface OzonWarehouse {
  warehouse_id: number
  name: string
  is_rfbs: boolean
}
```

---

## Rate Limits

| Operation | Limit |
|-----------|-------|
| General API | 300 requests/minute |
| Product import | Based on /v4/product/info/limit |
| Stock update | 80 requests/minute, 1 per warehouse per 2 min |
| Price update | 1000 items per request |

---

## Error Codes

| HTTP Code | Error Type | Cause | Solution |
|-----------|------------|-------|----------|
| 400 | `INVALID_ARGUMENT` | Malformed request | Check JSON structure |
| 400 | `NOT_FOUND_ERROR` | Resource not found | Verify IDs exist |
| 401 | `UNAUTHENTICATED` | Invalid credentials | Check Client-Id and Api-Key |
| 403 | `PERMISSION_DENIED` | No access to method | Check API key permissions |
| 404 | Not Found | Wrong endpoint version | Check v3 vs v4 vs v5 |
| 429 | `RESOURCE_EXHAUSTED` | Rate limit exceeded | Wait and retry |
| 429 | `TOO_MANY_REQUESTS` | Stock update too frequent | Wait 2 min (per warehouse) |
| 500 | `INTERNAL` | Server error | Retry later |

---

## Error Response Format

```json
{
  "code": 3,
  "message": "INVALID_ARGUMENT: offer_id: value is required",
  "details": []
}
```

---

## Pagination Patterns

### Cursor-based (most endpoints)

**Request:**
```json
{
  "last_id": "",
  "limit": 1000
}
```

**Response:**
```json
{
  "result": {
    "items": [...],
    "last_id": "abc123"
  }
}
```

**Loop:**
```typescript
let lastId = ''
while (true) {
  const { items, last_id } = await getItems(lastId)
  allItems.push(...items)
  if (!last_id || items.length === 0) break
  lastId = last_id
}
```

### Offset-based (orders)

**Request:**
```json
{
  "offset": 0,
  "limit": 1000
}
```

**Response:**
```json
{
  "result": {
    "postings": [...],
    "has_next": true
  }
}
```

---

## Official Documentation

- Main: https://docs.ozon.ru/api/seller/
- Full endpoint list: https://docs.ozon.ru/api/seller/#tag/Introduction
- API changes: https://docs.ozon.ru/api/seller/changelog/

Use WebFetch to check for updates when endpoint behavior differs from documentation.
