# Ozon Products API

Base URL: `https://api-seller.ozon.ru`

## POST /v3/product/list - Get Product IDs

Returns list of product IDs for further operations.

**Request:**
```json
{
  "filter": { "visibility": "ALL" },
  "last_id": "",
  "limit": 1000
}
```

**Response:**
```json
{
  "result": {
    "items": [
      { "product_id": 123456, "offer_id": "SKU-001", "is_fbo_visible": true, "is_fbs_visible": true }
    ],
    "total": 150,
    "last_id": "abc123"
  }
}
```

**TypeScript Interface:**
```typescript
interface OzonProductListItem {
  product_id: number
  offer_id: string
  is_fbo_visible: boolean
  is_fbs_visible: boolean
}
```

**Pagination:** Cursor-based via `last_id`
**Limit:** Max 1000 items per request

---

## POST /v3/product/info/list - Get Product Details

Get detailed info for specific products by ID.

**Request:**
```json
{
  "product_id": ["123456", "123457"]
}
```

**Note:** product_id must be array of **strings**, not numbers!

**Response:**
```json
{
  "result": {
    "items": [
      {
        "id": 123456,
        "product_id": 123456,
        "offer_id": "SKU-001",
        "name": "Product Name",
        "barcode": "4600000000001",
        "primary_image": "https://...",
        "price": "1500",
        "old_price": "2000",
        "marketing_price": "1200",
        "currency_code": "RUB",
        "fbo_sku": 789,
        "fbs_sku": 790,
        "stocks": { "coming": 0, "present": 10, "reserved": 2 }
      }
    ]
  }
}
```

**TypeScript Interface:**
```typescript
interface OzonProduct {
  id?: number
  product_id: number
  offer_id: string
  name: string
  barcode?: string
  barcodes?: string[]
  category_id?: number
  created_at?: string
  images?: string[]
  primary_image?: string
  marketing_price?: string
  min_price?: string
  old_price?: string
  price?: string
  currency_code?: string
  sku?: number
  fbo_sku?: number
  fbs_sku?: number
  sources?: { source: string; sku: number }[]
  stocks?: { coming: number; present: number; reserved: number }
}
```

**Limit:** Max 1000 products per request

---

## POST /v3/product/import - Create/Update Products

Create new products or update existing ones.

**Request:**
```json
{
  "items": [
    {
      "description": "Product description",
      "name": "Product Name",
      "offer_id": "SKU-001",
      "currency_code": "RUB",
      "price": "1500",
      "old_price": "2000",
      "vat": "0",
      "dimension_unit": "mm",
      "weight_unit": "g",
      "weight": 500,
      "height": 100,
      "width": 100,
      "depth": 100,
      "description_category_id": 12345,
      "images": ["https://..."],
      "attributes": [
        { "complex_id": 0, "id": 8229, "values": [{ "value": "Brand Name" }] }
      ]
    }
  ]
}
```

**Response:**
```json
{
  "result": {
    "task_id": 123456789
  }
}
```

Check import status with `/v1/product/import/info`

---

## Common Errors

| Code | Message | Solution |
|------|---------|----------|
| 400 | `NOT_FOUND_ERROR` | Check product_id exists |
| 400 | `INVALID_ARGUMENT` | Check request body format |
| 429 | `RESOURCE_EXHAUSTED` | Rate limit hit, wait and retry |
