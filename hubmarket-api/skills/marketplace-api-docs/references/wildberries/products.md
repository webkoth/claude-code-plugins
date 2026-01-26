# Wildberries Products API (Content API)

Base URL: `https://content-api.wildberries.ru`

## POST /content/v2/get/cards/list - Get Product Cards

Main endpoint for getting all products with details.

**Request:**
```json
{
  "settings": {
    "cursor": {
      "limit": 100,
      "updatedAt": "",
      "nmID": 0
    },
    "filter": {
      "withPhoto": -1
    }
  }
}
```

**Filter options:**
- `withPhoto`: `-1` (all), `0` (without photo), `1` (with photo)

**Response:**
```json
{
  "cards": [
    {
      "nmID": 123456789,
      "vendorCode": "ART-001",
      "brand": "Brand Name",
      "title": "Product Title",
      "subjectName": "Category",
      "photos": [
        { "big": "https://..." }
      ],
      "sizes": [
        {
          "price": 1500,
          "discountedPrice": 1200,
          "skus": ["sku123", "sku124"]
        }
      ]
    }
  ],
  "cursor": {
    "updatedAt": "2025-01-26T10:00:00Z",
    "nmID": 123456789
  }
}
```

**TypeScript Interface:**
```typescript
interface WBProduct {
  nmID: number
  vendorCode: string
  brand: string
  title: string
  subjectName?: string
  photos: { big: string }[]
  sizes: {
    price: number
    discountedPrice: number
    skus: string[]
  }[]
}
```

**Pagination:** Cursor-based via `updatedAt` + `nmID`

**Important:**
- `nmID` is the unique product identifier
- `vendorCode` is seller's SKU (артикул)
- `skus` are barcodes/SKUs for stock operations
- Prices are in kopecks (divide by 100 for rubles)

---

## Pagination Pattern

```typescript
async function getAllProducts(client: WBClient): Promise<WBProduct[]> {
  const all: WBProduct[] = []
  let cursor: { updatedAt?: string; nmID?: number } | undefined

  while (true) {
    const { cards, cursor: next } = await client.getProducts(100, cursor)
    all.push(...cards)

    if (!next || cards.length === 0) break
    cursor = next
  }

  return all
}
```

---

## Curl Example

```bash
curl -X POST 'https://content-api.wildberries.ru/content/v2/get/cards/list' \
  -H 'Authorization: {api_key}' \
  -H 'Content-Type: application/json' \
  -d '{
    "settings": {
      "cursor": {"limit": 10},
      "filter": {"withPhoto": -1}
    }
  }'
```

---

## Related Endpoints

| Operation | Endpoint |
|-----------|----------|
| Create cards | `POST /content/v2/cards/upload` |
| Update cards | `POST /content/v2/cards/update` |
| Get card by nmID | `POST /content/v2/get/cards/list` (filter) |
| Get categories | `GET /content/v2/object/all` |
| Get characteristics | `POST /content/v2/object/charcs` |
