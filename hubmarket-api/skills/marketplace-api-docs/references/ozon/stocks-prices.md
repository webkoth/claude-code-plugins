# Ozon Stocks & Prices API

Base URL: `https://api-seller.ozon.ru`

## Stocks

### POST /v4/product/info/stocks - Get Stock Info

**IMPORTANT:** Use v4, NOT v3 (v3 returns 404!)

**Request:**
```json
{
  "filter": {
    "product_id": ["788898745"],
    "visibility": "ALL"
  },
  "last_id": "",
  "limit": 1000
}
```

**Response:**
```json
{
  "result": {
    "items": [
      {
        "offer_id": "SKU-001",
        "product_id": 123456,
        "fbs_sku": 789,
        "fbo_sku": 790,
        "warehouse_id": 22142605386000,
        "warehouse_name": "FBS Warehouse",
        "present": 100,
        "reserved": 5
      }
    ],
    "last_id": "abc123"
  }
}
```

**TypeScript Interface:**
```typescript
interface OzonStock {
  offer_id: string
  product_id: number
  fbs_sku: number
  fbo_sku: number
  warehouse_id: number
  warehouse_name: string
  present: number
  reserved: number
}
```

**Pagination:** Cursor-based via `last_id`

---

### POST /v2/products/stocks - Update Stocks

Update stock quantities on warehouses.

**Request:**
```json
{
  "stocks": [
    {
      "offer_id": "SKU-001",
      "product_id": 313455276,
      "stock": 100,
      "warehouse_id": 22142605386000
    }
  ]
}
```

**Rate Limits:**
- Max 100 products per request
- Max 80 requests per minute
- **1 update per warehouse per 2 minutes!** (TOO_MANY_REQUESTS error otherwise)

**Prerequisites:**
- Product status must be `price_sent`
- Use correct warehouse_id for product size (regular vs oversized)

---

## Prices

### POST /v5/product/info/prices - Get Price Info

**Request:**
```json
{
  "filter": {
    "offer_id": ["356792"],
    "product_id": ["243686911"],
    "visibility": "ALL"
  },
  "limit": 1000,
  "cursor": ""
}
```

**Response:**
```json
{
  "result": {
    "items": [
      {
        "product_id": 123456,
        "offer_id": "SKU-001",
        "price": {
          "price": "1500.00",
          "old_price": "2000.00",
          "marketing_price": "1200.00",
          "min_price": "800.00",
          "currency_code": "RUB"
        },
        "commissions": {
          "sales_percent": 15,
          "fbo_fulfillment_amount": 50,
          "fbs_fulfillment_amount": 30
        }
      }
    ]
  }
}
```

**Limit:** Max 1000 products per request

---

### POST /v1/product/import/prices - Update Prices

**Request:**
```json
{
  "prices": [
    {
      "product_id": 1386,
      "offer_id": "SKU-001",
      "price": "1448",
      "old_price": "1800",
      "min_price": "800",
      "currency_code": "RUB",
      "auto_action_enabled": "UNKNOWN",
      "vat": "0"
    }
  ]
}
```

**Notes:**
- Set `old_price: "0"` to remove strikethrough price
- `min_price` affects auto-promo participation
- `auto_action_enabled`: `ENABLED`, `DISABLED`, `UNKNOWN`

**Limit:** Max 1000 products per request

---

## Common Errors

| Code | Error | Cause | Solution |
|------|-------|-------|----------|
| 404 | Not Found | Using v3 for stocks | Use v4 endpoint |
| 429 | TOO_MANY_REQUESTS | Stock update too frequent | Wait 2 min between updates per warehouse |
| 400 | action_price_enabled_min_price_missing | Auto-promo conflict | Disable auto-promo first, then update min_price |

## Curl Examples

**Get stocks:**
```bash
curl -X POST 'https://api-seller.ozon.ru/v4/product/info/stocks' \
  -H 'Client-Id: {client_id}' \
  -H 'Api-Key: {api_key}' \
  -H 'Content-Type: application/json' \
  -d '{"filter": {"visibility": "ALL"}, "limit": 10}'
```

**Update stock:**
```bash
curl -X POST 'https://api-seller.ozon.ru/v2/products/stocks' \
  -H 'Client-Id: {client_id}' \
  -H 'Api-Key: {api_key}' \
  -H 'Content-Type: application/json' \
  -d '{"stocks": [{"product_id": 123, "stock": 50, "warehouse_id": 456}]}'
```
