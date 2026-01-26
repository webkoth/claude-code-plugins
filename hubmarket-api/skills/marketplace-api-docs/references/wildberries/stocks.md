# Wildberries Stocks API (Marketplace API)

Base URL: `https://marketplace-api.wildberries.ru`

## GET /api/v3/warehouses - Get Warehouses

Get list of seller's FBS warehouses.

**Request:** GET (no body)

**Response:**
```json
[
  {
    "id": 123456,
    "name": "My Warehouse",
    "officeId": 789
  }
]
```

**TypeScript Interface:**
```typescript
interface WBWarehouse {
  id: number
  name: string
  officeId: number
}
```

**Curl:**
```bash
curl 'https://marketplace-api.wildberries.ru/api/v3/warehouses' \
  -H 'Authorization: {api_key}'
```

---

## POST /api/v3/stocks/{warehouseId} - Get Stocks

Get stock quantities for specific SKUs at a warehouse.

**Path Parameter:** `warehouseId` - from /api/v3/warehouses

**Request:**
```json
{
  "skus": ["sku123", "sku124", "sku125"]
}
```

**Response:**
```json
{
  "stocks": [
    { "sku": "sku123", "amount": 50 },
    { "sku": "sku124", "amount": 0 },
    { "sku": "sku125", "amount": 100 }
  ]
}
```

**TypeScript Interface:**
```typescript
interface WBStock {
  sku: string
  amount: number
}
```

**Limit:** Max 1000 SKUs per request

---

## PUT /api/v3/stocks/{warehouseId} - Update Stocks

Update stock quantities at a warehouse.

**Request:**
```json
{
  "stocks": [
    { "sku": "sku123", "amount": 75 },
    { "sku": "sku124", "amount": 25 }
  ]
}
```

**Response:** 204 No Content (success)

---

## Getting All Stocks (Workflow)

1. Get all warehouses
2. Get all products (to extract SKUs)
3. For each warehouse, get stocks for all SKUs

```typescript
async function getAllStocks(client: WBClient) {
  const warehouses = await client.getWarehouses()
  const products = await client.getAllProducts()

  // Extract all SKUs from products
  const allSkus: string[] = []
  for (const product of products) {
    for (const size of product.sizes || []) {
      allSkus.push(...(size.skus || []))
    }
  }

  const uniqueSkus = [...new Set(allSkus)]

  // Get stocks per warehouse
  const result = []
  for (const warehouse of warehouses) {
    const stocks = await client.getStocks(warehouse.id, uniqueSkus)
    result.push({
      warehouseId: warehouse.id,
      warehouseName: warehouse.name,
      stocks
    })
  }

  return result
}
```

---

## Curl Examples

**Get warehouses:**
```bash
curl 'https://marketplace-api.wildberries.ru/api/v3/warehouses' \
  -H 'Authorization: {api_key}'
```

**Get stocks:**
```bash
curl -X POST 'https://marketplace-api.wildberries.ru/api/v3/stocks/123456' \
  -H 'Authorization: {api_key}' \
  -H 'Content-Type: application/json' \
  -d '{"skus": ["sku123", "sku124"]}'
```

**Update stocks:**
```bash
curl -X PUT 'https://marketplace-api.wildberries.ru/api/v3/stocks/123456' \
  -H 'Authorization: {api_key}' \
  -H 'Content-Type: application/json' \
  -d '{"stocks": [{"sku": "sku123", "amount": 50}]}'
```

---

## Important Notes

- SKUs come from product sizes (`sizes[].skus[]`)
- Stock is per warehouse - need to query each separately
- `amount` is total available (not reserved)
- Empty response for SKUs means 0 stock
