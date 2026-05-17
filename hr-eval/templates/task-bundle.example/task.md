# Task: Marketplace Order Sync Bug

## Context

You're joining a small team that runs an analytics platform for marketplace sellers (think Wildberries/Ozon/Amazon style). One of the daily ingestion jobs syncs orders from a 3rd-party marketplace API into our Postgres `orders` table. The job ran fine for months, but a week ago it started silently dropping a portion of orders — about 8% per run, but not the same ones each time. No errors are thrown.

Engineering needs you to find the bug, fix it, and add coverage so this class of regression can't recur.

## What you have

A small repo:
- `src/ingest.ts` — the order sync job (~150 lines)
- `src/marketplace-client.ts` — wrapper around the 3rd-party API
- `src/db.ts` — Postgres client + a few helpers
- `package.json` with `npm test` (runs Vitest)
- A `docker-compose.yml` with Postgres for local testing
- A `sample-payloads/` folder with 50 anonymized marketplace API responses you can replay

(Setup repo: `git clone <gist-url>` — see `setup.md`)

## What we want from you

1. **Reproduce the drop.** Run the sync against the sample payloads. Confirm you see fewer rows in `orders` than the payloads imply.
2. **Find the root cause.** Don't guess — verify.
3. **Fix it.** Smallest reasonable change.
4. **Cover it.** Add a test that would have caught this regression before it shipped.
5. **Write 3-5 lines** at the top of `FINDINGS.md` explaining what was wrong and why.

## Acceptance

- `npm test` passes on your branch
- Re-running the sync against `sample-payloads/` results in 100% of expected orders in `orders` table
- The added test fails on `main` (without your fix) and passes after

## Constraints

- Time: ~60 min. Aim for the smallest correct fix, not a refactor.
- Don't introduce new dependencies unless they are absolutely necessary — and justify if you do.
- Don't rewrite the architecture. This is a bugfix, not a redesign.

## How to work with AI

This task is designed to be solved with AI assistance — use Claude Code as you normally would. We're not evaluating whether you use AI; we're observing **how you think while you do**. Things that count:

- Stating hypotheses before testing them
- Verifying what AI tells you (especially about 3rd-party API behavior)
- Writing failing tests before fixes
- Saying "I don't know" or "let me check" when appropriate

You don't need to perform. Work naturally. Good luck.
