---
name: hr-eval
description: Live, fully transparent one-session technical interview assessment. HR and candidate on a video call together — candidate runs all commands on their machine, HR helps verbally, everyone sees the same task / weights / report. Triggers when the user is preparing or running a live technical interview that uses Claude Code, when asked to "оценить кандидата", "evaluate candidate", "interview a developer with AI", or when the user mentions terms like AI-assisted hiring, AI fluency assessment, transparent process-based interview scoring. Provides 4 slash commands (/eval-prepare, /eval-start, /eval-report, /eval-stop) and a 7-signal cognition rubric with inline weighted scoring.
---

# hr-eval — Developer Cognition Assessment (Live, Transparent)

Process-based assessment plugin for **live one-session** technical interviews where AI tools are allowed. Logs candidate's interaction with Claude (prompts + tool calls + edits) during the interview and produces a structured report against 7 signals of developer thinking — with weighted scoring + recommendation applied inline.

## When to use

- **Live technical interview** on a video call with screen share + recording, where the candidate uses Claude Code on their machine.
- Candidate runs `/eval-prepare` (with HR's verbal input), then `/eval-start`, works the task, then `/eval-report`.
- `/eval-stop` is the emergency abort.

Everything happens on the candidate's screen with HR watching live.

## What it measures (7 categories)

See `lib/rubric.md` for the full taxonomy. Scores 0..5 per category, with `null` allowed when signal is insufficient. Weighted overall % and recommendation tier (STRONG HIRE / HIRE / NEEDS DEEPER INTERVIEW / NO HIRE) are computed in `/eval-report` using the `profile.yaml` generated in `/eval-prepare`.

1. **Promptcraft** — quality and specificity of prompts
2. **Critical Reception** — does the candidate verify / push back / accept blindly
3. **Verification & Testing** — tests, repro cases, hypothesis verification
4. **Debugging Methodology** — bisection vs random guessing, "hypnotising the error" anti-pattern
5. **Architecture Steering** — anti-sycophancy, push-back on AI overengineering
6. **Environment & Tooling** — git, terminal, package managers, reading docs
7. **Metacognition** — naming hypotheses, recognising dead-ends, "I don't know"

## What it does NOT measure

- Final code correctness (did tests pass?)
- Time to completion (slower can be better)
- Knowledge of specific frameworks (that's screening, not cognition)
- Personality / cultural fit

## Architecture

- `commands/` — 4 slash commands
- `hooks/` — shell scripts that log prompts/tool calls (activated dynamically by `/eval-start`, NOT registered by default)
- `lib/rubric.md` — taxonomy of 7 signals + cross-cutting anti-patterns
- `lib/analyzer-prompt.md` — instruction for LLM to convert log + profile → report
- `lib/prepare-prompt.md` — instruction for LLM to convert JD + verbal HR answers → task + profile
- `lib/consent-notice.md` — text shown to candidate before logging starts
- `lib/profile-schema.yaml` — job profile structure (position, weights, custom flags)
- `lib/INSIGHTS.md` — background research: market analogs + signal taxonomy sources
- `templates/` — example profile + example task-bundle
- `examples/sample-report.md` — example of a generated report

## Transparency principle

Logging is **fully transparent and visible to all participants in real time**. HR watches via screen share during the call. The candidate sees their own report appear on screen at the same moment as HR. Team lead / lead dev can audit the full `log.jsonl` after the call. Installing the plugin does NOT enable logging — hooks activate only inside an active `/eval-start` session.

The `profile.yaml` (with weights, custom green/red flags, critical caps) is generated in front of the candidate during `/eval-prepare`. They see the same evaluation criteria as HR throughout the session.

## Storage

- All session artefacts: `<cwd>/.hr-eval/sessions/<session-id>/`
  - `task.md`, `setup.md`, `profile.yaml`, `meta.json`, `jd.txt` (from `/eval-prepare`)
  - `log.jsonl` (accumulated during `/eval-start` → work)
  - `report.md` and `<session-id>.zip` (from `/eval-report`)
- No remote upload, no telemetry. The candidate hands the zip to HR via drag-and-drop in the call's chat.

## Research foundation

See `lib/INSIGHTS.md` for the market scan (CodeSignal, HackerRank, Karat, Mercor, Metaview, DevSkiller etc.) and academic basis (Wing's computational thinking; Soloway/Spohrer programmer cognition; Microsoft/GitHub Copilot productivity studies; 2024–2025 work on AI sycophancy and human-AI collaboration patterns). The 7-signal rubric is grounded in this literature and validated against Kirill Mokevnin's observations from 50–60 AI-assisted technical interviews (2024–2025).
