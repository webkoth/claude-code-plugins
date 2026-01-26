# Ozon Orders API

Base URL: `https://api-seller.ozon.ru`

## POST /v3/posting/fbs/list - Get FBS Orders

Main endpoint for getting orders (postings) with full financial data.

**Request:**
```json
{
  "dir": "DESC",
  "filter": {
    "since": "2025-01-01T00:00:00Z",
    "to": "2025-01-26T23:59:59Z",
    "status": ""
  },
  "limit": 1000,
  "offset": 0,
  "with": {
    "analytics_data": true,
    "financial_data": true
  }
}
```

**Filter by status:**
- `""` (empty) - all statuses
- `awaiting_packaging` - awaiting assembly
- `awaiting_deliver` - awaiting shipment
- `delivering` - in delivery
- `delivered` - delivered (use for sales)
- `cancelled` - cancelled

**Response:**
```json
{
  "result": {
    "postings": [
      {
        "posting_number": "12345678-0001",
        "order_id": 12345678,
        "order_number": "12345678",
        "status": "delivered",
        "substatus": "",
        "in_process_at": "2025-01-20T10:00:00Z",
        "shipment_date": "2025-01-21T00:00:00Z",
        "delivering_date": "2025-01-23T14:30:00Z",
        "products": [
          {
            "sku": 789,
            "name": "Product Name",
            "quantity": 2,
            "offer_id": "SKU-001",
            "price": "1500.00",
            "currency_code": "RUB"
          }
        ],
        "analytics_data": {
          "region": "Moscow Oblast",
          "city": "Moscow",
          "delivery_type": "PVZ",
          "is_premium": false,
          "warehouse_id": 456,
          "warehouse": "FBS Warehouse"
        },
        "financial_data": {
          "products": [
            {
              "product_id": 123,
              "price": 1500,
              "old_price": 2000,
              "commission_amount": 225,
              "commission_percent": 15,
              "payout": 1275,
              "quantity": 2,
              "total_discount_value": 500,
              "total_discount_percent": 25,
              "item_services": {
                "marketplace_service_item_fulfillment": 50,
                "marketplace_service_item_deliv_to_customer": 100,
                "marketplace_service_item_return_flow_trans": 0
              }
            }
          ],
          "posting_services": {
            "marketplace_service_item_fulfillment": 50,
            "marketplace_service_item_deliv_to_customer": 100
          }
        },
        "cancellation": {
          "cancel_reason_id": 0,
          "cancel_reason": "",
          "cancellation_type": "",
          "cancelled_after_ship": false,
          "cancellation_initiator": ""
        }
      }
    ],
    "has_next": true
  }
}
```

**TypeScript Interface:**
```typescript
interface OzonPosting {
  posting_number: string
  order_id: number
  order_number: string
  status: string
  substatus: string
  in_process_at: string
  shipment_date: string
  delivering_date: string | null
  products: {
    sku: number
    name: string
    quantity: number
    offer_id: string
    price: string
    currency_code: string
  }[]
  analytics_data: {
    region: string
    city: string
    delivery_type: string
    is_premium: boolean
    warehouse_id: number
    warehouse: string
  } | null
  financial_data: {
    products: OzonFinancialProduct[]
    posting_services: OzonPostingServices
  } | null
  cancellation: OzonCancellation
}

interface OzonFinancialProduct {
  product_id: number
  price: number
  old_price: number
  commission_amount: number
  commission_percent: number
  payout: number
  quantity: number
  total_discount_value: number
  total_discount_percent: number
  item_services: OzonItemServices
}
```

**Pagination:** Offset-based (offset + limit)
**Limit:** Max 1000 postings per request

---

## POST /v2/posting/fbo/list - Get FBO Orders

Similar to FBS but for Fulfillment by Ozon orders.

**Request:**
```json
{
  "dir": "DESC",
  "filter": {
    "since": "2025-01-01T00:00:00Z",
    "to": "2025-01-26T23:59:59Z"
  },
  "limit": 1000,
  "offset": 0,
  "with": {
    "analytics_data": true,
    "financial_data": true
  }
}
```

---

## Key Financial Fields Explained

| Field | Description |
|-------|-------------|
| `price` | Final price customer paid |
| `old_price` | Price before discount |
| `commission_amount` | Ozon commission (RUB) |
| `commission_percent` | Commission rate (%) |
| `payout` | Amount seller receives |
| `total_discount_value` | Total discount applied |
| `marketplace_service_item_fulfillment` | Fulfillment fee |
| `marketplace_service_item_deliv_to_customer` | Delivery fee |
| `marketplace_service_item_return_flow_trans` | Return logistics fee |

---

## Order Status Flow

```
awaiting_packaging → awaiting_deliver → delivering → delivered
                                                  ↘ cancelled
```

---

## Curl Example

**Get orders with financial data:**
```bash
curl -X POST 'https://api-seller.ozon.ru/v3/posting/fbs/list' \
  -H 'Client-Id: {client_id}' \
  -H 'Api-Key: {api_key}' \
  -H 'Content-Type: application/json' \
  -d '{
    "filter": {
      "since": "2025-01-01T00:00:00Z",
      "to": "2025-01-26T23:59:59Z"
    },
    "limit": 10,
    "with": {"analytics_data": true, "financial_data": true}
  }'
```

**Get delivered orders (sales):**
```bash
curl -X POST 'https://api-seller.ozon.ru/v3/posting/fbs/list' \
  -H 'Client-Id: {client_id}' \
  -H 'Api-Key: {api_key}' \
  -H 'Content-Type: application/json' \
  -d '{
    "filter": {
      "since": "2025-01-01T00:00:00Z",
      "to": "2025-01-26T23:59:59Z",
      "status": "delivered"
    },
    "limit": 100,
    "with": {"financial_data": true}
  }'
```
