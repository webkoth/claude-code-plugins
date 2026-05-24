# hr-eval

> Evaluate developer candidates by how they think with an AI agent — live, in one session, fully transparent.

A Claude Code plugin for **live, process-based** technical assessments. Instead of grading the final artefact (did tests pass? did they ship?), `hr-eval` observes the candidate's **interaction with Claude** during the interview and scores it against a 7-signal taxonomy of developer cognition — with HR watching the screen and the candidate seeing the same report.

The premise (after Kirill Mokevnin's 50+ AI-assisted interviews in 2024–2025): when AI can solve algorithmic puzzles in a second, the interview is over before it began. The signal that matters now is **how a candidate thinks** when an AI agent is in the loop with them.

## The model: live, one session, full transparency

- HR and candidate on a video call. Candidate shares screen. Call is recorded.
- Candidate installs the plugin on their own machine on the call.
- `/eval-prepare` — candidate runs it; HR answers questions verbally; together they generate `task.md` + `profile.yaml` (weights + custom flags visible to both).
- `/eval-start` — consent notice, hooks activate, task opens.
- Candidate works with Claude. HR watches via screen share. Every prompt + tool call goes to `log.jsonl`.
- `/eval-report` — analyzer reads the log, applies weights from `profile.yaml`, produces `report.md` with weighted scoring + recommendation. Everyone sees it simultaneously.
- Candidate hands off the zip to HR via drag-and-drop in chat.
- After the call: team lead / lead dev can audit the full log + report.

Everything is on the table from minute one — task, weights, custom flags, log, report. Candidate, HR, and team lead see the same artefacts. This is the whole point of the plugin.

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
┌──────────────────────────────────────────────────────┐
│  Live call: HR + Candidate                           │
│  Recording: ON                                       │
│  Screen share: candidate's machine                   │
├──────────────────────────────────────────────────────┤
│                                                       │
│   /plugin install hr-eval@webkoth                    │
│   ↓                                                   │
│   /eval-prepare                                      │
│   ↓  candidate types, HR answers verbally            │
│   ↓  → task.md + profile.yaml (weights visible)      │
│   ↓                                                   │
│   /eval-start                                        │
│   ↓  consent notice (live transparency)              │
│   ↓  hooks activate, task shown                      │
│   ↓                                                   │
│   Candidate works with Claude.                       │
│   HR watches via screen share.                       │
│   Every prompt + tool call → log.jsonl               │
│   ↓                                                   │
│   /eval-report                                       │
│   ↓  analyzer → report.md (visible to all)           │
│   ↓  weighted scoring + recommendation inline        │
│   ↓  zip packaged, Finder opens                      │
│   ↓                                                   │
│   Candidate drag-and-drops zip to HR in chat         │
│                                                       │
└──────────────────────────────────────────────────────┘
       ↓ after the call
   Team lead / lead dev audits log.jsonl + report.md
```

## Install

```bash
/plugin marketplace add webkoth/claude-code-plugins
/plugin install hr-eval@webkoth
```

## Commands

| Command | When | What it does |
|---------|------|-------------|
| `/eval-prepare` | Start of call | Generate task + profile (weights, flags) from JD + HR's verbal answers. Mandatory first step. |
| `/eval-start` | After prepare | Show consent notice, activate logging hooks, open the task |
| `/eval-report` | End of work | Snap hooks, run LLM analyzer, produce report with weighted scoring + recommendation, package handoff zip |
| `/eval-stop` | Anytime | Abort session without generating a report (files kept for audit) |

`/eval-report` supports `--report-only` flag to package only `report.md` instead of the full session bundle.

## Transparency principle

- The candidate sees a **consent notice** before any logging begins (see [`lib/consent-notice.md`](./lib/consent-notice.md)).
- The plugin **does not log anything by default after install** — hooks activate only when `/eval-start` is run inside an active `/eval-prepare` session.
- Logs are stored locally in `<cwd>/.hr-eval/sessions/<id>/` — no remote upload, no telemetry.
- The candidate sees the final report **at the same time as HR** (via screen share). There is no "candidate-first" buffer — this is a live transparent process.
- `profile.yaml` with weights and custom red/green flags is **visible to the candidate** from the moment it's generated.
- After the call, the full session log (`log.jsonl`) is available for **team lead / lead dev audit** — they can independently verify or challenge the assessment.

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

After scanning the market in May 2026: CodeSignal, HackerRank, Karat, Mercor, Metaview, DevSkiller, Hatchways, Filtered, Cangrade — every existing platform optimises for the artefact or operates as an async take-home. They talk about "AI fluency" without an observable rubric. `hr-eval` scores the **interaction with the AI agent** as the primary signal, with anti-sycophancy and architecture-steering as first-class categories — designed for live, transparent, one-session use where candidate and HR see the same evaluation criteria. See [`lib/INSIGHTS.md`](./lib/INSIGHTS.md) for the full scan.

## File map

```
hr-eval/
├── .claude-plugin/plugin.json    # plugin manifest
├── README.md                     # this file
├── commands/                     # 4 slash commands
│   ├── eval-prepare.md
│   ├── eval-start.md
│   ├── eval-report.md
│   └── eval-stop.md
├── hooks/                        # session loggers (dynamically activated)
│   ├── hooks.json                # intentionally empty; hooks not auto-registered
│   ├── log-event.sh              # core logger
│   ├── log-prompt.sh             # UserPromptSubmit wrapper
│   ├── log-pre-tool.sh           # PreToolUse wrapper
│   └── log-post-tool.sh          # PostToolUse wrapper
├── lib/
│   ├── rubric.md                 # 7-signal taxonomy + anti-patterns
│   ├── analyzer-prompt.md        # LLM instruction: log + profile → report
│   ├── prepare-prompt.md         # LLM instruction: JD + verbal HR → task + profile
│   ├── consent-notice.md         # candidate transparency notice
│   ├── profile-schema.yaml       # job profile structure
│   └── INSIGHTS.md               # research notes (market analogs + sources)
├── skills/hr-eval/
│   └── SKILL.md                  # skill discovery entry-point
├── templates/
│   ├── company-profile.example.yaml
│   └── task-bundle.example/
│       ├── task.md               # example assessment task
│       └── setup.md
└── examples/
    └── sample-report.md          # example of generated report (with weighted scoring)
```

## Status

Working. Expect rough edges in:
- JSON parsing of varied hook payload shapes (we trust Claude Code's contract; if it shifts, the logger gracefully no-ops rather than crashing)
- Cross-platform shell scripts (developed on macOS; Linux should work; Windows users want WSL)
- LLM analyzer report quality on very short or very long sessions

## Roadmap

- Anti-sycophancy probes that HR can plant in `profile.yaml` (specific false premises to test if AI catches them — pass-through to scoring)
- Optional log anonymisation before sharing with external recruiters
- Cursor / Windsurf compatibility (via MCP server adapter)

## Author

[Minas Sarkisyan](https://github.com/webkoth) — building [HubMarket](https://hubmarket.ru) (marketplace seller analytics) and AI-native dev practices.

## License

MIT.
