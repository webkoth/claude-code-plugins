# Common Patterns

Shared patterns for working with marketplace APIs.

## Pagination

### Ozon - Cursor-based (last_id)

```typescript
async function getAllOzonProducts(client: OzonClient): Promise<OzonProduct[]> {
  const allProducts: OzonProduct[] = []
  let lastId: string | undefined

  while (true) {
    const { items, lastId: nextLastId } = await client.getProducts(1000, lastId)
    allProducts.push(...items)

    if (!nextLastId || items.length === 0) break
    lastId = nextLastId
  }

  return allProducts
}
```

### Ozon - Offset-based (orders)

```typescript
async function getAllOzonOrders(client: OzonClient, dateFrom: Date): Promise<OzonPosting[]> {
  const allPostings: OzonPosting[] = []
  let offset = 0
  const limit = 1000

  while (true) {
    const { postings, hasNext } = await client.getOrders(dateFrom, undefined, limit, offset)
    allPostings.push(...postings)

    if (!hasNext || postings.length === 0) break
    offset += limit
  }

  return allPostings
}
```

### Wildberries - Cursor-based (updatedAt + nmID)

```typescript
async function getAllWBProducts(client: WBClient): Promise<WBProduct[]> {
  const allProducts: WBProduct[] = []
  let cursor: { updatedAt?: string; nmID?: number } | undefined

  while (true) {
    const { cards, cursor: nextCursor } = await client.getProducts(100, cursor)
    allProducts.push(...cards)

    if (!nextCursor || cards.length === 0) break
    cursor = nextCursor
  }

  return allProducts
}
```

---

## Error Handling

### Retry with Exponential Backoff

```typescript
async function fetchWithRetry<T>(
  fn: () => Promise<T>,
  maxRetries = 3,
  baseDelay = 1000
): Promise<T> {
  for (let i = 0; i < maxRetries; i++) {
    try {
      return await fn()
    } catch (error) {
      if (i === maxRetries - 1) throw error

      const delay = baseDelay * Math.pow(2, i)
      console.log(`Retry ${i + 1}/${maxRetries} after ${delay}ms`)
      await new Promise(resolve => setTimeout(resolve, delay))
    }
  }
  throw new Error('Max retries exceeded')
}
```

### Handle Rate Limits

```typescript
async function handleRateLimit<T>(fn: () => Promise<T>): Promise<T> {
  try {
    return await fn()
  } catch (error) {
    if (error.message.includes('429') || error.message.includes('TOO_MANY_REQUESTS')) {
      console.log('Rate limited, waiting 60 seconds...')
      await new Promise(resolve => setTimeout(resolve, 60000))
      return fn()
    }
    throw error
  }
}
```

---

## Rate Limits Summary

| Marketplace | API | Limit |
|-------------|-----|-------|
| Ozon | General | 300 req/min |
| Ozon | Stock update | 1 per warehouse per 2 min |
| Wildberries | Content/Marketplace | 100 req/min |
| **Wildberries** | **Statistics** | **1 req/min** |

---

## Normalized Types

From `lib/api/marketplace.ts`:

```typescript
interface NormalizedProduct {
  externalId: string       // nmID (WB) or product_id (Ozon)
  vendorCode: string       // Seller's SKU
  name: string
  brand: string | null
  category: string | null
  photoUrl: string | null
  price: number
  priceBeforeDiscount: number | null
  discount: number
  barcode: string | null
}

interface NormalizedStock {
  productExternalId: string
  warehouse: string
  warehouseId: string
  quantity: number
}

interface NormalizedOrder {
  externalId: string
  productExternalId: string
  status: 'NEW' | 'CONFIRMED' | 'ASSEMBLED' | 'DELIVERING' | 'DELIVERED' | 'RETURNED' | 'CANCELLED'
  totalPrice: number
  commission: number
  logistics: number
  orderedAt: Date
  deliveredAt: Date | null
  quantity: number
}

interface NormalizedSale {
  externalId: string
  productExternalId: string
  price: number
  payout: number  // Amount after commission
  date: Date
}
```

---

## Marketplace Client Interface

```typescript
interface MarketplaceClient {
  validateKey(): Promise<boolean>
  getAllProducts(): Promise<NormalizedProduct[]>
  getAllStocks(): Promise<NormalizedStock[]>
  getOrders(dateFrom: Date): Promise<NormalizedOrder[]>
  getSales(dateFrom: Date): Promise<NormalizedSale[]>
}
```

Use `createMarketplaceClient(marketplace, credentials)` factory:

```typescript
import { createMarketplaceClient } from '@/lib/api/marketplace'

const client = createMarketplaceClient('OZON', 'clientId:apiKey')
const products = await client.getAllProducts()
```

---

## Testing Endpoints

### Quick Test with curl

**Ozon:**
```bash
curl -X POST 'https://api-seller.ozon.ru/v4/product/info/limit' \
  -H 'Client-Id: {client_id}' \
  -H 'Api-Key: {api_key}' \
  -H 'Content-Type: application/json' \
  -d '{}'
```

**Wildberries:**
```bash
curl 'https://common-api.wildberries.ru/ping' \
  -H 'Authorization: {api_key}'
```

### Check Endpoint Version

Ozon frequently deprecates versions. If getting 404:
1. Try v4 instead of v3
2. Try v5 instead of v4
3. Search online for current version

---

## Common Pitfalls

| Issue | Marketplace | Solution |
|-------|-------------|----------|
| 404 on stocks | Ozon | Use v4, not v3 |
| Empty response | Ozon | Check product_id is array of strings |
| Rate limit | WB Statistics | Wait 60 seconds between requests |
| No auth header | WB | No "Bearer" prefix, just raw key |
| Wrong method | Ozon | Always POST, even for reads |

---

## Project Integration

**Existing clients:**
- `lib/api/ozon.ts` - OzonClient class
- `lib/api/wildberries.ts` - WildberriesClient class
- `lib/api/marketplace.ts` - Unified MarketplaceClient adapter

**Usage:**
```typescript
import { createOzonClient } from '@/lib/api/ozon'
import { createWildberriesClient } from '@/lib/api/wildberries'
import { createMarketplaceClient } from '@/lib/api/marketplace'
```
