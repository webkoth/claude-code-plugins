# Wildberries Orders & Sales API (Statistics API)

Base URL: `https://statistics-api.wildberries.ru`

**CRITICAL:** Statistics API has **1 request per minute** rate limit!

## GET /api/v1/supplier/orders - Get Orders

Get all orders from a specific date.

**Query Parameters:**
- `dateFrom` - Start date (YYYY-MM-DD format)

**Request:** GET (no body)

**Response:**
```json
[
  {
    "srid": "unique_order_id_123",
    "date": "2025-01-20T10:30:00Z",
    "lastChangeDate": "2025-01-21T14:00:00Z",
    "totalPrice": 1500,
    "discountPercent": 20,
    "nmId": 123456789,
    "isCancel": false,
    "cancelDate": null,
    "finishedPrice": 1200,
    "warehouseName": "Moscow",
    "regionName": "Moscow Oblast",
    "orderType": "ClientOrder"
  }
]
```

**TypeScript Interface:**
```typescript
interface WBOrder {
  srid: string                // Unique order ID
  date: string               // Order creation date
  lastChangeDate: string     // Last status change
  totalPrice: number         // Price before discount
  discountPercent: number    // Discount percentage
  nmId: number               // Product nmID
  isCancel: boolean          // Is cancelled
  cancelDate?: string        // Cancellation date
  finishedPrice?: number     // Final price after discount
  warehouseName?: string     // Warehouse name
  regionName?: string        // Delivery region
  orderType?: string         // Order type
}
```

**Notes:**
- Returns ALL orders from dateFrom, including cancelled
- Filter cancelled orders by `isCancel: true`
- `finishedPrice` is what customer paid

---

## GET /api/v1/supplier/sales - Get Sales

Get confirmed sales (delivered orders).

**Query Parameters:**
- `dateFrom` - Start date (YYYY-MM-DD format)

**Response:**
```json
[
  {
    "srid": "unique_sale_id_456",
    "date": "2025-01-22T16:45:00Z",
    "nmId": 123456789,
    "finishedPrice": 1200,
    "forPay": 1020
  }
]
```

**TypeScript Interface:**
```typescript
interface WBSale {
  srid: string         // Unique sale ID
  date: string        // Sale date
  nmId: number        // Product nmID
  finishedPrice: number  // Price customer paid
  forPay: number      // Amount seller receives (after commission)
}
```

**Notes:**
- Only confirmed/delivered sales
- `forPay` = amount after WB commission
- Commission = `finishedPrice - forPay`

---

## GET /api/v5/supplier/reportDetailByPeriod - Detailed Report

Get detailed financial report by period.

**Query Parameters:**
- `dateFrom` - Start date (YYYY-MM-DD)
- `dateTo` - End date (YYYY-MM-DD)

**Response:**
```json
[
  {
    "nm_id": 123456789,
    "retail_price": 1500,
    "commission_percent": 15,
    "delivery_rub": 100,
    "storage_fee": 50,
    "ppvz_for_pay": 1020
  }
]
```

**TypeScript Interface:**
```typescript
interface WBReportDetail {
  nm_id: number
  retail_price: number
  commission_percent: number
  delivery_rub: number
  storage_fee: number
  ppvz_for_pay: number  // Payout to seller
}
```

---

## Rate Limits

**VERY IMPORTANT:**
- Statistics API: **1 request per minute!**
- Implement delays between requests
- Cache results when possible

```typescript
// Example with rate limit handling
async function getOrdersWithRateLimit(dateFrom: Date) {
  await delay(60000) // Wait 1 minute between requests
  return client.getOrders(dateFrom)
}
```

---

## Curl Examples

**Get orders:**
```bash
curl 'https://statistics-api.wildberries.ru/api/v1/supplier/orders?dateFrom=2025-01-01' \
  -H 'Authorization: {api_key}'
```

**Get sales:**
```bash
curl 'https://statistics-api.wildberries.ru/api/v1/supplier/sales?dateFrom=2025-01-01' \
  -H 'Authorization: {api_key}'
```

**Get detailed report:**
```bash
curl 'https://statistics-api.wildberries.ru/api/v5/supplier/reportDetailByPeriod?dateFrom=2025-01-01&dateTo=2025-01-26' \
  -H 'Authorization: {api_key}'
```

---

## Mapping to Normalized Types

```typescript
// Convert WB order to normalized format
function normalizeOrder(order: WBOrder): NormalizedOrder {
  return {
    externalId: order.srid,
    productExternalId: String(order.nmId),
    status: order.isCancel ? 'CANCELLED' : 'DELIVERED',
    totalPrice: order.finishedPrice || order.totalPrice,
    commission: 0, // Calculate from sales data
    logistics: 0,
    orderedAt: new Date(order.date),
    deliveredAt: order.isCancel ? null : new Date(order.lastChangeDate),
    quantity: 1
  }
}
```
