# hr-eval — Research Insights

Background research for an HR evaluation plugin that scores developer candidates by analysing their interaction logs with a Claude agent during a live interview.

## 1. Market analogs — state of the art (2025–2026)

### What the major platforms actually measure

| Platform | What it captures | Process vs. outcome | LLM-driven analysis | AI-collaboration signal |
|---|---|---|---|---|
| **CodeSignal** (Codessa / Interviewer Agents, 2025) | Voice + code + screen during agentic-tool sessions; candidate builds with AI and then explains trade-offs to a human reviewer. Adaptive follow-ups. | Both — explicitly "captures not just *what* they solve, but *how*". | Yes — rubric scoring of communication, requirement interpretation, decision justification. | Partial — talks about "iterating on AI output instead of writing from scratch" but rubric is generic (clarity, requirements, role fit). |
| **HackerRank** (AI-Assisted IDE, CodePair 2025) | Full IDE telemetry, AI-copilot transcripts, typing dynamics, prompt history. Scorecard Assist auto-fills rubric from transcripts. | Process visible, scoring still leans on test-pass + code quality + plagiarism red flags. | Yes — LLM grades prompt clarity, iteration depth, partial credit for "good problem-solving approach". | Best-in-class on the **prompt-engineering axis**. Weak on hallucination-resistance and critical reception. |
| **Karat NextGen** (Dec 2025) | Human-led live interview + AI-native simulations. Benchmarks against engineer ratings. | Process-heavy (judgement, adaptability, AI fluency). | Used to scaffold the human reviewer, not to score directly. | "AI fluency" — but undefined operationally. |
| **Mercor** | AI interviewer, voice-first, talent-marketplace screening. | Mostly outcome + behavioural. | Yes (summary + scoring). | Almost none — generic interview, not coding-specific. |
| **Metaview** | Interview transcription + thematic analytics. Hiring-ops layer, not coding-specific. | Process (qualitative). | Yes (themes, summaries). | None. |
| **DevSkiller / Hatchways / Filtered / Cangrade** | "RealLifeTesting" — GitHub repo tasks, take-home style. Cangrade has *Jules* AI copilot; Hatchways added ChatGPT-task variants. | Outcome-first (test results, static analysis). | Limited — mostly summarisation. | Very weak — detect *that* AI was used (plagiarism signal), don't grade *how well*. |

### Where the market is blind

1. **Outcome bias still dominates.** Even "AI-aware" platforms ultimately score the artefact and treat the process log as colour for human reviewers, not as a primary signal.
2. **No taxonomy of cognition under AI.** Vendors talk about "AI fluency" / "AI collaboration" without an observable rubric.
3. **No detection of AI sycophancy traps.** Nothing on the market probes whether the candidate notices when the model agrees with a wrong premise.
4. **No reward for steering / hallucination correction.** A candidate pushing back on a wrong AI suggestion looks identical to one blindly accepting — as long as both end with green tests.
5. **Prompt-craft graded shallowly.** HackerRank scores prompt clarity, but not minimum-sufficient context + iteration on *the prompt* vs. on the *output*.
6. **No metacognition signal.** Nothing flags self-correction, scope re-negotiation, or "I don't know — let me verify" behaviour.

**Our niche:** a rubric-first scorer of the *interaction* with an AI coding agent, independent of whether the final code passes tests, focused on signals that matter when a senior developer collaborates with an LLM daily.

## 2. Taxonomy of developer-cognition signals in AI-assisted sessions

Synthesised from Wing (computational thinking — decomposition, abstraction, pattern recognition, systematic testing), Soloway/Spohrer programmer-cognition tradition (plans, schemas, deviation from canonical solutions), Microsoft/GitHub Copilot productivity studies (Ziegler et al. 2022; Peng et al. 2023 — speedup + over-trust), and 2024–2025 research on metacognition with collaborative AI (Tandfonline 2025 — structured-regulation cluster outperforms exploratory cluster on transfer; AI sycophancy literature; DORA 2025 — AI increases code instability ~10%).

For each category: **What to observe → green / red signals → detector phrases.**

### 2.1 Promptcraft (Качество промптов)
- **Observe:** prompt length, presence of constraints/acceptance criteria, references to files/symbols, follow-up edits to the prompt vs. to the output.
- **Green:** specifies inputs, outputs, edge cases, non-goals; attaches relevant code/path; iterates the *prompt* when the first answer was off.
- **Red:** one-liners ("fix this", "make it work"); pastes huge dumps with no question; re-runs the same prompt hoping for a better answer.
- **Detectors:** `"given X, must satisfy Y, ignore Z"`, `"in file <path>, function <name>"`, prompt edits within 60 s of a bad answer.

### 2.2 Critical Reception (Критическое восприятие ответов AI)
- **Observe:** time between AI response and next user action; explicit verification before adoption; pushback on incorrect output.
- **Green:** "this doesn't match our schema — show me the source", asks for citations, runs a quick sanity check before applying.
- **Red:** copy-paste-accept within seconds; thanks the model and proceeds; doubles down when the AI invents an API.
- **Detectors:** `"are you sure"`, `"does this function actually exist in <lib>"`, vs. immediate `accept_edit` after a long generation.

### 2.3 Verification & Testing (Верификация и тестирование)
- **Observe:** does the candidate write/extend tests before relying on AI output? Does a `Bash` run / `pytest` / type-check follow generation?
- **Green:** asks AI to draft a failing test first, then implementation; runs the test; reads the failure.
- **Red:** zero test runs; eyeballs diff and moves on; only runs the happy-path script.
- **Detectors:** sequence `Edit → Bash(test) → Edit`; prompts containing `"write a failing test for"`.

### 2.4 Debugging Methodology (Методология отладки)
- **Observe:** hypothesis-formation language, binary search through code, instrumenting before guessing.
- **Green:** "my hypothesis is X — let's print/log to confirm"; isolates the failing layer before asking AI to fix.
- **Red:** "this is broken, fix it"; loops the AI on the same stack trace; deletes code instead of understanding it.
- **Detectors:** `"I think the issue is"`, `"let's add a log here"`, repeated identical error pastes (red).

### 2.5 Architecture Steering / Anti-sycophancy (Архитектурное лидерство)
- **Observe:** who is making decisions — candidate or AI? Does the candidate reject confidently-wrong suggestions? Does the candidate plant a false premise to see if the AI corrects them (advanced)?
- **Green:** "no, we're not adding a new dependency — refactor existing util"; pushes back on hallucinated APIs; sets non-negotiables up front.
- **Red:** silently accepts unjustified abstractions; lets AI scope-creep into rewrites; agrees with the AI even after it flips its own answer.
- **Detectors:** explicit `"don't"` / `"keep using"` / `"that's wrong because"`; rejection of an edit after careful reading (timestamp gap > read-time threshold).

### 2.6 Environment & Tooling (Окружение и инструменты)
- **Observe:** competent use of grep / file-reads / git / package managers; provides the AI with the right context before asking for changes.
- **Green:** reads the relevant file before prompting; uses `Grep`/`Glob` to locate; gives AI a tight working set.
- **Red:** asks AI to "find the function" instead of grepping; never reads files; lets the agent guess paths.
- **Detectors:** ratio of `Read`/`Grep` to `Edit` calls; mentions of `git diff`, `git log`, package-manager invocations.

### 2.7 Metacognition (Метакогниция)
- **Observe:** explicit self-monitoring — "I'm not sure", scope renegotiation, recognising when to stop and re-plan.
- **Green:** "let me re-read the problem", "actually this approach won't scale — let me back up", asks for clarification of ambiguous requirements.
- **Red:** sunk-cost continuation; never re-reads the prompt; doesn't notice when the AI silently changed assumptions.
- **Detectors:** `"wait"`, `"actually"`, `"let me re-check the requirement"`, mid-task plan revisions.

### Additional signals worth tracking (out of v1 scoring, surface in report when observed)
- **2.8 Decomposition & Planning (Декомпозиция).** Plan/checklist before edits. Green: short ordered plan. Red: dives in, loses thread.
- **2.9 Context Hygiene (Гигиена контекста).** Green: clears unused buffers, summarises long threads, references specific symbols. Red: paste-everything, never cleans up.
- **2.10 Risk & Reversibility (Риск и обратимость).** Green: commits before destructive ops, dry-runs, asks "what could this break?". Red: `rm -rf`, accepts destructive AI suggestions blindly.
- **2.11 Communication & Justification (Объяснение решений).** Green: rationales accompany decisions; meaningful commit messages. Red: silent acceptance; commit = "fix".
- **2.12 Knowledge Boundaries (Границы знания).** Green: "I don't remember the exact signature — let me check the docs". Red: confidently parrots an AI hallucination; never says "I don't know".

## What is critical to ship in the MVP rubric

1. **Promptcraft** — specificity + iteration on the prompt vs. on the output. Easiest to detect, highest SNR.
2. **Critical Reception** — accept-latency, verification before accept, pushback on wrong AI output. Directly addresses the market blind spot of AI-sycophancy.
3. **Verification & Testing** — test-run frequency and test-before-code patterns. Observable in tool-call sequence, hard to fake.
4. **Architecture Steering** — rejection of unjustified suggestions, holding non-negotiables, anti-sycophancy probes. Biggest differentiator vs. CodeSignal/HackerRank.
5. **Debugging Methodology** — hypothesis-driven language, isolation before fix. Soloway/Spohrer-style cognitive signal, robust to outcome noise.
6. **Metacognition** — self-correction, scope renegotiation, "I don't know". Strongest predictor of senior-level work with LLMs per 2024–2025 research.
7. **Tool-use Hygiene** — Read/Grep before Edit, env literacy. Cheap to compute from tool-call counts and ordering; surfaces juniors who let the agent drive blindly.

Out of scope for v1 but worth wiring collection for: Decomposition & Planning, Context Hygiene, Risk & Reversibility, Communication & Justification, Knowledge Boundaries.

## Sources
- CodeSignal — AI Interviewer: https://codesignal.com/ai-interviewer/
- CodeSignal — Introducing AI-Assisted Coding Assessments: https://codesignal.com/blog/introducing-ai-assisted-coding-assessments-interviews/
- CodeSignal Launches Interviewer Agents (2025): https://www.prnewswire.com/news-releases/codesignal-launches-interviewer-agents-agentic-interviewers-that-scale-with-your-hiring-plans-302526966.html
- HackerRank — Designing AI-Integrated Coding Assessments (2025): https://www.hackerrank.com/writing/designing-ai-integrated-coding-assessments-real-world-work-2025-guide
- HackerRank — Prompt Engineering Questions (2025): https://www.hackerrank.com/writing/prompt-engineering-questions-hackerrank-coding-interview-tests-2025-practice-guide
- HackerRank — AI-Assisted Interviews (KB): https://support.hackerrank.com/articles/5821380141-ai-assisted-interviews
- Karat — NextGen Interviews launch: https://karat.com/karat-launches-nextgen-interviews-the-first-human-led-ai-enabled-talent-evaluation-solution/
- Karat — Engineering Interview Trends 2026: https://karat.com/engineering-interview-trends-2026/
- Metaview — Candidate scoring: https://www.metaview.ai/resources/blog/candidate-scoring
- Mercor — AI Interview docs: https://talent.docs.mercor.com/support/ai-interview
- DevSkiller alternatives 2025: https://codesignal.com/blog/tech-recruiting/devskiller-alternatives-for-technical-skill-assessments-in-2025/
- Cangrade — talent-assessment comparison: https://www.cangrade.com/blog/hr-strategy/talent-assessment-solutions-a-comprehensive-comparison/
- Ziegler et al. — Productivity Assessment of Neural Code Completion (arXiv 2205.06537): https://arxiv.org/pdf/2205.06537
- Peng et al. — The Impact of AI on Developer Productivity (arXiv 2302.06590): https://arxiv.org/pdf/2302.06590
- GitHub Blog — Quantifying Copilot's impact: https://github.blog/news-insights/research/research-quantifying-github-copilots-impact-on-developer-productivity-and-happiness/
- Wing — Computational Thinking (CACM 2006): https://www.cs.cmu.edu/~15110-s13/Wing06-ct.pdf
- Wing — Computational thinking and thinking about computing (2008): https://www.cs.cmu.edu/~wing/publications/Wing08a.pdf
- Generative AI in Human-AI Collaboration (Tandfonline 2025): https://www.tandfonline.com/doi/full/10.1080/10447318.2025.2543997
- Impact of Human-AI Interaction Patterns on Problem Solving (ICAIR 2025): https://papers.academic-conferences.org/index.php/icair/article/view/4276
- Beyond Functional Correctness — Hallucinations in LLM-Generated Code (arXiv 2404.00971): https://arxiv.org/pdf/2404.00971
- A Survey of Bugs in AI-Generated Code (arXiv 2512.05239): https://arxiv.org/html/2512.05239v1
- Intuition to Evidence — Measuring AI's True Impact (arXiv 2509.19708): https://arxiv.org/html/2509.19708v1
- Rubric Is All You Need (ACM ICER 2025): https://dl.acm.org/doi/10.1145/3702652.3744220
- Sierra — The AI-native interview: https://sierra.ai/blog/the-ai-native-interview
