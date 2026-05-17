---
name: hr-eval
description: Evaluate developer candidates by how they think with an AI agent during a transparent interview session. Triggers when the user is preparing or running a technical interview that uses Claude Code / Cursor, when asked to "оценить кандидата", "evaluate candidate", "interview a developer with AI", or when the user mentions terms like AI-assisted hiring, AI fluency assessment, или process-based interview scoring. Provides 5 slash commands (/eval-prepare, /eval-start, /eval-report, /eval-stop, /eval-grade) and a 7-signal cognition rubric.
---

# hr-eval — Developer Cognition Assessment

Process-based assessment plugin. Logs candidate's interaction with Claude (prompts + tool calls + edits) during an interview and produces a structured report against 7 signals of developer thinking.

## When to use

- **HR/manager** preparing a technical interview that allows AI tools: use `/eval-prepare` to generate a task and profile from a JD.
- **Candidate** starting an AI-assisted interview: use `/eval-start` to begin a logged session with transparency notice.
- **Candidate** finished interview: use `/eval-report` to generate the cognition report locally.
- **HR** after receiving candidate's report: use `/eval-grade` to apply private weights + custom flags and compute final % fit.
- Emergency abort: `/eval-stop`.

## What it measures (7 categories)

See `lib/rubric.md` for the full taxonomy. Scores 0..5 per category, with `null` allowed when signal is insufficient.

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

- `commands/` — 5 slash commands
- `hooks/` — shell scripts that log prompts/tool calls (activated dynamically by `/eval-start`, NOT registered by default)
- `lib/rubric.md` — taxonomy of 7 signals + cross-cutting anti-patterns
- `lib/analyzer-prompt.md` — instruction for LLM to convert log → report
- `lib/prepare-prompt.md` — instruction for LLM to convert JD → task + profile
- `lib/consent-notice.md` — text shown to candidate before logging starts
- `lib/profile-schema.yaml` — company profile structure (public + private parts)
- `lib/INSIGHTS.md` — background research: market analogs + signal taxonomy sources
- `templates/` — example profile + example task-bundle
- `examples/sample-report.md` — example of a generated report

## Transparency principle

Logging is **never silent**. `/eval-start` always shows the consent notice from `lib/consent-notice.md`. The candidate sees the final report before HR. Hooks are only active for the duration of an explicit session — installing the plugin does NOT enable logging on the user's machine.

## Storage

- **HR side** (job-bundle): `~/.hr-eval/jobs/<job-slug>/` — task, setup, public+private profiles, SHARE.md
- **Candidate side** (sessions): `<cwd>/.hr-eval/sessions/<session-id>/` — log.jsonl, task.md, meta.json, report.md
- No remote upload, no telemetry. Reports are shared manually via email/gist/chat.

## Research foundation

See `lib/INSIGHTS.md` for the market scan (CodeSignal, HackerRank, Karat, Mercor, Metaview, DevSkiller etc.) and academic basis (Wing's computational thinking; Soloway/Spohrer programmer cognition; Microsoft/GitHub Copilot productivity studies; 2024–2025 work on AI sycophancy and human-AI collaboration patterns). The 7-signal rubric is grounded in this literature and validated against Kirill Mokevnin's observations from 50–60 AI-assisted technical interviews (2024–2025).
