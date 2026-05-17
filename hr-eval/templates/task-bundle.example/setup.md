# Setup

## Prerequisites

- Node 20.x
- Docker (for Postgres)
- `git`

## Get the code

```bash
git clone https://gist.github.com/<HR-replace-with-real-gist>.git marketplace-sync
cd marketplace-sync
npm install
```

## Run the database

```bash
docker compose up -d
# wait ~5s for Postgres to be ready
npm run migrate
```

## Run the sync job

```bash
npm run sync -- --payloads ./sample-payloads
```

## Run tests

```bash
npm test
```

## Useful

- `psql postgres://app:app@localhost:5432/marketplace` — direct DB access
- `src/ingest.ts:42` — the main sync loop (look here first if you suspect the loop)
- `sample-payloads/README.md` — what's in each payload (some have edge cases)

## When done

```bash
git add -A
git commit -m "fix: marketplace order sync drop"
# show your work — branch ready for review
```

If you get stuck on setup (Docker, Node version) — that's part of the task. We don't expect you to memorize commands; we expect you to figure them out.
