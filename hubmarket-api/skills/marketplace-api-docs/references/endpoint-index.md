# Endpoint Index

Quick lookup table for finding the right endpoint by task.

## Products

| Task | Ozon Endpoint | Wildberries Endpoint |
|------|---------------|---------------------|
| Get list of products (IDs) | `POST /v3/product/list` | `POST /content/v2/get/cards/list` |
| Get product details | `POST /v3/product/info/list` | (included in list response) |
| Create product | `POST /v3/product/import` | `POST /content/v2/cards/upload` |
| Update product | `POST /v3/product/import` | `POST /content/v2/cards/update` |
| Archive product | `POST /v1/product/archive` | - |
| Get product attributes | `POST /v1/description-category/attribute` | `POST /content/v2/object/charcs` |

## Stocks & Prices

| Task | Ozon Endpoint | Wildberries Endpoint |
|------|---------------|---------------------|
| Get stocks | `POST /v4/product/info/stocks` | `POST /api/v3/stocks/{warehouseId}` |
| Update stocks | `POST /v2/products/stocks` | `PUT /api/v3/stocks/{warehouseId}` |
| Get prices | `POST /v5/product/info/prices` | (included in product list) |
| Update prices | `POST /v1/product/import/prices` | `POST /public/api/v1/prices` |

**Important Notes:**
- Ozon: Use v4 for stocks (v3 returns 404!)
- Ozon: Max 80 requests/min for stock updates
- WB: Need warehouseId, get from `/api/v3/warehouses`

## Warehouses

| Task | Ozon Endpoint | Wildberries Endpoint |
|------|---------------|---------------------|
| List warehouses | `POST /v1/warehouse/list` | `GET /api/v3/warehouses` |
| Get warehouse info | `POST /v1/warehouse/list` (filter by id) | `GET /api/v3/warehouses` |

## Orders

| Task | Ozon Endpoint | Wildberries Endpoint |
|------|---------------|---------------------|
| Get orders (FBS) | `POST /v3/posting/fbs/list` | `GET /api/v1/supplier/orders?dateFrom=` |
| Get order details | `POST /v3/posting/fbs/get` | (included in list) |
| Get sales (delivered) | `POST /v3/posting/fbs/list` (status=delivered) | `GET /api/v1/supplier/sales?dateFrom=` |
| Get FBO orders | `POST /v2/posting/fbo/list` | - |
| Confirm order | `POST /v3/posting/fbs/ship` | - |
| Cancel order | `POST /v2/posting/fbs/cancel` | - |

**Important Notes:**
- Ozon: Use `with: {financial_data: true}` to get commission/payout
- WB Statistics API: **1 request/minute limit!**

## Reports & Analytics

| Task | Ozon Endpoint | Wildberries Endpoint |
|------|---------------|---------------------|
| Financial report | `POST /v1/finance/realization` | `GET /api/v5/supplier/reportDetailByPeriod` |
| Product analytics | `POST /v1/analytics/data` | - |
| Stock movement | `POST /v1/report/stocks/movement` | - |

## Validation

| Task | Ozon Endpoint | Wildberries Endpoint |
|------|---------------|---------------------|
| Validate API key | `POST /v4/product/info/limit` | `GET /ping` (common-api) |
| Check rate limits | `POST /v4/product/info/limit` | - |

## Ozon-Specific

| Task | Endpoint |
|------|----------|
| Get categories | `POST /v1/description-category/tree` |
| Get category attributes | `POST /v1/description-category/attribute` |
| Get promotions | `POST /v1/actions` |
| Upload images | `POST /v1/product/pictures/import` |

## Wildberries-Specific

| Task | Endpoint | Base URL |
|------|----------|----------|
| Ping/validate | `GET /ping` | common-api |
| Get product cards | `POST /content/v2/get/cards/list` | content-api |
| Get warehouses | `GET /api/v3/warehouses` | marketplace-api |
| Get stocks | `POST /api/v3/stocks/{id}` | marketplace-api |
| Get orders | `GET /api/v1/supplier/orders` | statistics-api |
| Get sales | `GET /api/v1/supplier/sales` | statistics-api |
