# Wildberries API Common

## Base URLs

Wildberries uses **different base URLs** for different API groups:

| API | Base URL | Purpose |
|-----|----------|---------|
| Common | `https://common-api.wildberries.ru` | Ping, validation |
| Content | `https://content-api.wildberries.ru` | Products, cards |
| Marketplace | `https://marketplace-api.wildberries.ru` | Warehouses, stocks |
| Statistics | `https://statistics-api.wildberries.ru` | Orders, sales |

**Future APIs (not yet implemented):**
- Supplies: `https://supplies-api.wildberries.ru`
- Analytics: `https://seller-analytics-api.wildberries.ru`

---

## Authentication

**Header (required for all requests):**
```
Authorization: {api_key}
```

**Important:** No "Bearer" prefix! Just the raw API key.

**Curl template:**
```bash
curl '{base_url}{endpoint}' \
  -H 'Authorization: {api_key}' \
  -H 'Content-Type: application/json'
```

---

## Validate API Key

**Endpoint:** `GET https://common-api.wildberries.ru/ping`

**Response (success):**
```json
{
  "TS": "2025-01-26T10:00:00Z",
  "Status": "OK"
}
```

**Curl:**
```bash
curl 'https://common-api.wildberries.ru/ping' \
  -H 'Authorization: {api_key}'
```

---

## Rate Limits

| API | Limit | Notes |
|-----|-------|-------|
| Content API | 100 req/min | Products, cards |
| Marketplace API | 100 req/min | Stocks, warehouses |
| **Statistics API** | **1 req/min** | Orders, sales - VERY STRICT! |

**Handling Statistics API:**
```typescript
// Always add delay between Statistics API calls
async function getSalesWithDelay(dateFrom: Date) {
  await new Promise(resolve => setTimeout(resolve, 60000))
  return fetch(`${STATISTICS_API}/api/v1/supplier/sales?dateFrom=${format(dateFrom)}`)
}
```

---

## Error Responses

**401 Unauthorized:**
```json
{
  "error": "Unauthorized"
}
```
Cause: Invalid or missing API key

**429 Too Many Requests:**
```json
{
  "error": "rate limit exceeded"
}
```
Cause: Rate limit hit, wait before retry

**400 Bad Request:**
```json
{
  "error": "invalid request body"
}
```
Cause: Malformed JSON or invalid parameters

---

## Key Identifiers

| ID Type | Description | Where to find |
|---------|-------------|---------------|
| `nmID` | Unique product ID | Products list |
| `vendorCode` | Seller's article (SKU) | Products list |
| `sku` | Barcode for stock operations | Product sizes |
| `srid` | Unique order/sale ID | Orders, sales |
| `warehouseId` | FBS warehouse ID | Warehouses list |

---

## Request Methods

| API | Method | Body |
|-----|--------|------|
| Ping | GET | - |
| Products list | POST | JSON |
| Warehouses | GET | - |
| Stocks get | POST | JSON (skus array) |
| Stocks update | PUT | JSON |
| Orders | GET | Query params |
| Sales | GET | Query params |

---

## Date Formats

- Query params: `YYYY-MM-DD` (e.g., `2025-01-26`)
- Response dates: ISO 8601 (e.g., `2025-01-26T10:30:00Z`)

---

## Pagination (Content API)

Cursor-based using `updatedAt` + `nmID`:

**Request:**
```json
{
  "settings": {
    "cursor": {
      "limit": 100,
      "updatedAt": "2025-01-20T10:00:00Z",
      "nmID": 123456789
    }
  }
}
```

**Response includes next cursor:**
```json
{
  "cards": [...],
  "cursor": {
    "updatedAt": "2025-01-26T10:00:00Z",
    "nmID": 987654321
  }
}
```

---

## Official Documentation

- Main: https://dev.wildberries.ru/
- API Reference: https://dev.wildberries.ru/openapi/

Use WebFetch to check for updates when endpoint behavior differs from documentation.
