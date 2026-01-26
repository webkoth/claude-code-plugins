---
name: marketplace-api-docs
description: |
  API documentation and testing for Russian marketplaces (Ozon, Wildberries, Yandex Market).
  Use when: finding endpoints, understanding request/response formats, implementing marketplace integrations, debugging API errors, testing endpoints.
  Triggers: "endpoint", "API документация", "формат запроса", "пример response", "интеграция с Ozon", "интеграция с WB", "Wildberries API", "не работает endpoint", "проверить API", "какой эндпоинт", "как получить товары", "как получить остатки", "ошибка API", "пагинация маркетплейса"
---

# Marketplace API Documentation

Active skill for working with Russian marketplace APIs. Provides endpoint documentation, tests APIs when uncertain, and verifies documentation online.

## Quick Reference

### Most Used Endpoints

| Task | Ozon | Wildberries |
|------|------|-------------|
| Validate key | `POST /v4/product/info/limit` | `GET /ping` (common-api) |
| List products | `POST /v3/product/list` | `POST /content/v2/get/cards/list` |
| Product details | `POST /v3/product/info/list` | (included in list) |
| Stocks | `POST /v4/product/info/stocks` | `POST /api/v3/stocks/{warehouse}` |
| Orders (FBS) | `POST /v3/posting/fbs/list` | `GET /api/v1/supplier/orders` |
| Sales | `POST /v3/posting/fbs/list` (status=delivered) | `GET /api/v1/supplier/sales` |
| Warehouses | `POST /v1/warehouse/list` | `GET /api/v3/warehouses` |

### Base URLs

**Ozon:** `https://api-seller.ozon.ru` (all endpoints)

**Wildberries:**
- Common API: `https://common-api.wildberries.ru`
- Content API: `https://content-api.wildberries.ru`
- Marketplace API: `https://marketplace-api.wildberries.ru`
- Statistics API: `https://statistics-api.wildberries.ru`

### Authentication

**Ozon:**
```
Headers:
  Client-Id: {client_id}
  Api-Key: {api_key}
  Content-Type: application/json

Method: POST (always, even for reads)
```

**Wildberries:**
```
Headers:
  Authorization: {api_key}  (no "Bearer" prefix!)
  Content-Type: application/json
```

## Workflows

### 1. Provide Endpoint + Request + Response

1. Search in `references/endpoint-index.md` for task mapping
2. Load appropriate reference file (`references/ozon/` or `references/wildberries/`)
3. Return: URL, method, headers, request body, response example, TypeScript interface

### 2. Test API When Uncertain

When documentation might be outdated or endpoint behavior is unclear:

1. Get API keys (see below)
2. Execute curl request:

**Ozon example:**
```bash
curl -X POST 'https://api-seller.ozon.ru/v3/product/list' \
  -H 'Client-Id: {client_id}' \
  -H 'Api-Key: {api_key}' \
  -H 'Content-Type: application/json' \
  -d '{"filter": {"visibility": "ALL"}, "limit": 10}'
```

**Wildberries example:**
```bash
curl 'https://common-api.wildberries.ru/ping' \
  -H 'Authorization: {api_key}'
```

3. Analyze response structure
4. Compare with documentation
5. Return actual data structure with raw response

### 3. Verify Documentation Online

When API returns unexpected data or errors:

1. Use WebSearch:
   - "Ozon Seller API {endpoint_name} 2025 documentation"
   - "Wildberries API {endpoint_name} изменения"
   - "site:docs.ozon.ru {endpoint_path}"

2. Use WebFetch to read official docs:
   - https://docs.ozon.ru/api/seller/
   - https://dev.wildberries.ru/

3. Compare with local references
4. Update references/ if found changes

### 4. Debug Non-Working Endpoint

When endpoint returns error or wrong data:

1. Check endpoint version (v3 vs v4 vs v5 - Ozon often changes!)
2. Verify authentication headers
3. Test with minimal request body
4. Check rate limits (see common-patterns.md)
5. Search online for recent API changes
6. Return working variant with raw data example

## Getting API Keys

1. First, check project .env file:
```bash
grep -E "(OZON|WB|WILDBERRIES|CLIENT_ID|API_KEY)" .env
```

2. Expected variables:
   - `OZON_CLIENT_ID`, `OZON_API_KEY`
   - `WB_API_KEY` or `WILDBERRIES_API_KEY`

3. If not found, ask user:
   "Need API key to test this endpoint. Provide temporarily? (not stored)"

## Existing Project Resources

**API Clients (use as reference for patterns):**
- `lib/api/ozon.ts` - Ozon client with types
- `lib/api/wildberries.ts` - WB client with types
- `lib/api/marketplace.ts` - Unified adapter interface

**Full Ozon Documentation:**
- `docs/ozon-api/*.md` - 33 files with detailed endpoint docs
- Use Grep to search: `Grep "{endpoint}" docs/ozon-api/`

**Normalized Types:**
- `NormalizedProduct`, `NormalizedStock`, `NormalizedOrder`, `NormalizedSale`
- Defined in `lib/api/marketplace.ts`

## When to Load References

| Situation | Load |
|-----------|------|
| Find endpoint by task | `references/endpoint-index.md` |
| Implement Ozon endpoint | `references/ozon/{category}.md` |
| Implement WB endpoint | `references/wildberries/{category}.md` |
| Pagination / errors | `references/common-patterns.md` |
| Full Ozon API details | `docs/ozon-api/*.md` (project folder) |

## Rate Limits (Critical!)

**Ozon:**
- General: 300 requests/minute
- Stocks update: 1 per 2 minutes per warehouse
- Products info: 1000 items per request max

**Wildberries:**
- Content API: 100 requests/minute
- Statistics API: **1 request/minute!** (very strict)
- Stocks: by warehouse, max 1000 SKUs per request
