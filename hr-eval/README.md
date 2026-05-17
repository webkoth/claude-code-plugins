# hr-eval

> Evaluate developer candidates by how they think with an AI agent — not by whether tests pass.

A Claude Code plugin for **process-based** technical assessments. Instead of grading the final artefact (did tests pass? did they ship?), `hr-eval` observes the candidate's **interaction with Claude** during the interview and scores it against a 7-signal taxonomy of developer cognition.

The premise (after Kirill Mokevnin's 50+ AI-assisted interviews in 2024–2025): when AI can solve algorithmic puzzles in a second, the interview is over before it began. The signal that matters now is **how a candidate thinks** when an AI agent is in the loop with them.

## What it scores (7 categories)

| # | Category | What it captures |
|---|----------|------------------|
| 1 | **Promptcraft** | Specificity, context, iteration on the prompt vs. on the output |
| 2 | **Critical Reception** | Push-back on AI, verification, anti-sycophancy |
| 3 | **Verification & Testing** | Tests, repro cases, hypothesis verification |
| 4 | **Debugging Methodology** | Bisection vs random guessing, "hypnotising the error" |
| 5 | **Architecture Steering** | Resisting overengineering, holding non-negotiables |
| 6 | **Environment & Tooling** | git, terminal, grep-before-ask, reading docs |
| 7 | **Metacognition** | "I don't know — let me check", scope re-negotiation |

Full taxonomy with green/red signals: [`lib/rubric.md`](./lib/rubric.md). Research background: [`lib/INSIGHTS.md`](./lib/INSIGHTS.md).

## How it works

```
┌────────────────────────┐         ┌───────────────────────────┐
│  HR (Claude Code)      │         │  Candidate (Claude Code)  │
├────────────────────────┤         ├───────────────────────────┤
│  /eval-prepare         │         │                           │
│  ↓                     │         │                           │
│  Reads JD, asks 3-5 Qs │         │                           │
│  ↓                     │         │                           │
│  Generates:            │         │                           │
│  • task.md             │ ──────► │  /eval-start              │
│  • profile-public.yaml │   send  │  ↓ shows consent notice   │
│  • profile-private.yaml│         │  ↓ activates 3 hooks      │
│  • SHARE.md            │         │  ↓ shows task             │
│                        │         │  ↓                        │
│                        │         │  Candidate works with     │
│                        │         │  Claude as normal.        │
│                        │         │  Every prompt, tool call, │
│                        │         │  edit → JSONL log.        │
│                        │         │  ↓                        │
│                        │         │  /eval-report             │
│                        │         │  ↓ snaps hooks            │
│                        │         │  ↓ LLM analyzer reads log │
│                        │         │  ↓ + rubric → report.md   │
│                        │         │  ↓                        │
│                        │ ◄────── │  Candidate sees report    │
│                        │  share  │  FIRST. Sends to HR.      │
│  /eval-grade           │         │                           │
│  ↓ applies private     │         │                           │
│  weights + custom flags│         │                           │
│  ↓ computes % fit      │         │                           │
│  ↓ recommendation      │         │                           │
└────────────────────────┘         └───────────────────────────┘
```

## Install

```bash
/plugin marketplace add webkoth/claude-code-plugins
/plugin install hr-eval@webkoth
```

## Commands

| Command | Role | What it does |
|---------|------|-------------|
| `/eval-prepare` | HR | From a job description, generate task + public profile + private profile + paste-ready candidate message |
| `/eval-start` | Candidate | Show transparency notice, activate logging hooks, open the task |
| `/eval-report` | Candidate | Snap hooks, run LLM analyzer over the session log, produce report against the 7-signal rubric |
| `/eval-stop` | Candidate | Abort the session without generating a report (always available) |
| `/eval-grade` | HR | Apply the private profile (weights + custom flags) to a candidate report; compute final % fit + recommendation |

## Transparency

- The candidate sees a **consent notice** before any logging begins (see [`lib/consent-notice.md`](./lib/consent-notice.md)).
- The plugin **does not log anything by default after install** — hooks activate only when `/eval-start` is run.
- Logs are stored locally in `<cwd>/.hr-eval/sessions/<id>/` — no remote upload, no telemetry.
- The candidate sees the final report **before** anyone else. They decide whether to share it with HR.
- The `profile-private.yaml` with weights and red/green flags is **never** sent to the candidate — it stays with HR for `/eval-grade`.

## What it does NOT do

- Score whether tests passed (that's outcome, not cognition)
- Score code quality (linters and PR review do that)
- Score completion speed (slower thinking is often better)
- Detect plagiarism / "did they actually use AI" (that question is obsolete — AI use is assumed)
- Cultural fit / behavioral interviews (use other tools for that)

## Anti-patterns the rubric explicitly catches

- **Hypnotising the error** — 15+ minutes on the same failure with no new hypothesis (Mokevnin)
- **Galloping galaxy-brain** — actively co-engineering complexity with the AI
- **AI-only operator** — never reads diffs, blindly accepts edits
- **Sycophancy unawareness** — AI flipped its position to match a wrong premise and the candidate didn't notice
- **Silent confusion** — paste-the-same-prompt loop when stuck

## Niche

After scanning the market in May 2026: CodeSignal, HackerRank, Karat, Mercor, Metaview, DevSkiller, Hatchways, Filtered, Cangrade — every existing platform still ultimately optimises for the artefact. They talk about "AI fluency" without an observable rubric. `hr-eval` is the first plugin to score the **interaction with the AI agent** as the primary signal, with anti-sycophancy and architecture-steering as first-class categories. See [`lib/INSIGHTS.md`](./lib/INSIGHTS.md) for the full scan.

## File map

```
hr-eval/
├── .claude-plugin/plugin.json    # plugin manifest
├── README.md                     # this file
├── commands/                     # 5 slash commands
│   ├── eval-prepare.md
│   ├── eval-start.md
│   ├── eval-report.md
│   ├── eval-stop.md
│   └── eval-grade.md
├── hooks/                        # session loggers (dynamically activated)
│   ├── hooks.json                # intentionally empty; hooks not auto-registered
│   ├── log-event.sh              # core logger
│   ├── log-prompt.sh             # UserPromptSubmit wrapper
│   ├── log-pre-tool.sh           # PreToolUse wrapper
│   └── log-post-tool.sh          # PostToolUse wrapper
├── lib/
│   ├── rubric.md                 # 7-signal taxonomy + anti-patterns
│   ├── analyzer-prompt.md        # LLM instruction: log → report
│   ├── prepare-prompt.md         # LLM instruction: JD → task + profile
│   ├── consent-notice.md         # candidate transparency notice
│   ├── profile-schema.yaml       # company profile structure
│   └── INSIGHTS.md               # research notes (market analogs + sources)
├── skills/hr-eval/
│   └── SKILL.md                  # skill discovery entry-point
├── templates/
│   ├── company-profile.example.yaml
│   └── task-bundle.example/
│       ├── task.md               # example assessment task
│       └── setup.md
└── examples/
    └── sample-report.md          # example of generated report
```

## Status

**v0.1.0 — Working MVP.** Built for self-dogfooding first. Expect rough edges in:
- JSON parsing of varied hook payload shapes (we trust Claude Code's contract; if it shifts, the logger gracefully no-ops rather than crashing)
- Cross-platform shell scripts (developed on macOS; Linux should work; Windows users want WSL)
- LLM analyzer report quality on very short or very long sessions

## Roadmap

- v0.2: anti-sycophancy probes that HR can plant in `profile-private` (specific false premises to test if AI catches them — pass-through to scoring)
- v0.2: batch `/eval-grade` for multiple candidates on one role
- v0.3: optional anonymisation of session logs before sharing
- v0.3: Cursor / Windsurf compatibility (via MCP server adapter)

## Author

[Minas Sarkisyan](https://github.com/webkoth) — building [HubMarket](https://hubmarket.ru) (marketplace seller analytics) and AI-native dev practices.

## License

MIT.
