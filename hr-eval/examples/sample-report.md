# Evaluation Report

**Session:** 20260518-141207-a3f9c2d1
**Task:** Marketplace Order Sync Bug
**Position:** Senior Fullstack TypeScript Developer
**Date:** 2026-05-18
**Duration:** 58 min
**Total prompts:** 23
**Total tool calls:** 71

---

## TL;DR

Кандидат локализовал баг (race condition в idempotency check) системно через hypothesis-driven debugging, отверг два неверных AI-предложения, написал failing test до фикса. Слабая зона — низкое внимание к terminal hygiene (4 раза просил AI "найди файл" вместо `rg`/`grep`). Сильный кандидат на Senior, без серьёзных red flags.

---

## Per-category scores

### 1. Promptcraft — `4`

**Обоснование:** Промпты структурированы, всегда с указанием файла и контекста. Дважды пересматривал prompt после неудачного ответа — изменял формулировку, не запускал AI снова с тем же текстом.

**Green signals observed:**
- Specifies file + constraint — лог `[14:14:32]: "В src/ingest.ts:42 в цикле обработки — нужно понять как обрабатывается дубликат. Не меняй код, только объясни логику."`
- Prompt iteration after off response — лог `[14:22:11]: "Не то — я не про SQL, я про логику цикла."`

**Red signals observed:**
- One wall-of-text prompt без структуры в начале — лог `[14:08:42]: "<350 слов одним абзацем без markdown>"`

### 2. Critical Reception — `5`

**Обоснование:** Дважды отверг AI-предложения с обоснованием. Один раз заметил что AI выдумал поведение API (`onConflict: 'rollback'` — несуществующая опция), проверил через docs. Это сигнал прямо в нашу red-flag критерию для роли.

**Green signals observed:**
- Verifies third-party method exists — лог `[14:31:08]: "Это правда есть в pg или ты выдумал? Покажи документацию."` Custom green flag matched: "verifies third-party API method exists in docs before using"
- Rejects unnecessary dep — лог `[14:43:55]: "Не надо bullmq добавлять — у нас Postgres, можно advisory lock. Просто и достаточно."` Custom green flag matched: "rejects unnecessary new dependency suggested by AI"

**Red signals observed:** Ничего значимого.

### 3. Verification & Testing — `5`

**Обоснование:** Написал failing test **до** фикса. Запускал `npm test` после каждого значимого изменения. Каждый раз читал output, цитировал test name в обсуждении с AI.

**Green signals observed:**
- Test-before-fix — лог `[14:35:22]: "Прежде чем чинить, напишу test который воспроизводит. Дай тест для случая два concurrent инсерта с одним order_id."` Custom green flag matched: "asks AI to write a failing test before fix"
- Runs tests after edits — Bash `npm test` появляется 7 раз в логе с интервалом 4-12 мин

### 4. Debugging Methodology — `4`

**Обоснование:** Hypothesis-driven подход: озвучивал гипотезу → проверял → отвергал/принимал. Один эпизод stuck (~12 мин) на race condition пока не догадался про advisory locks — но в этот период попытки были разные, не "hypnotising".

**Green signals observed:**
- Hypothesis formation — лог `[14:25:40]: "Гипотеза: drop происходит на дубликатах. Проверю — запущу два раза подряд один payload."`
- Bisection — закомментировал секции `ingest.ts` чтобы изолировать виновную функцию `[14:29:17]`

**Red signals observed:**
- 12-min stuck без новых гипотез — лог `[14:45:10]..[14:57:23]` повторял варианты "может это SELECT FOR UPDATE поможет?" пять раз с минорными вариациями. Не критично, но это близко к "hypnotising" pattern.

### 5. Architecture Steering — `4`

**Обоснование:** Дважды push back на overengineering (отверг bullmq и Redis-based lock). Объяснил AI существующую архитектуру. Без custom-green-flag "uses advisory locks instead of new dep" - это явный матч.

**Green signals observed:**
- Steers AI to simpler solution — лог `[14:43:55]: "Не надо bullmq..."` (см. Critical Reception)
- Explains existing arch — лог `[14:21:08]: "У нас одна Postgres, один воркер. Не Kubernetes, не horizontal scaling. Решай в этой реальности."`

**Red signals observed:** Нет.

### 6. Environment & Tooling — `2`

**Обоснование:** Главная слабая зона. 4 раза просил AI "find a file containing X" вместо использования `rg`/`grep`/`find`. Git использовал базово, не делал `git diff` до commit. Setup прошёл быстро (хороший знак).

**Green signals observed:**
- Quick setup — за 6 мин запустил `docker compose up`, `npm install`, `npm run migrate`, без stuck
- Read README first — лог `[14:09:03]: Read README.md`

**Red signals observed:**
- Asks AI instead of grep — лог `[14:18:55]: "Найди где обрабатывается idempotency"` — на этот момент кандидат не открыл ни одного файла кроме `ingest.ts`. Эту операцию `rg "idempotency"` выполнил бы за 2 секунды.
- No `git diff` before commit — лог `[14:58:14]: Bash git commit -am "fix"` без предварительного `git status` или `git diff`

### 7. Metacognition — `4`

**Обоснование:** Дважды признал тупик и сменил подход. Один раз признал что не знает Postgres advisory locks и попросил AI объяснить (а не делать вид что знает).

**Green signals observed:**
- "Не знаю — давай проверю" — лог `[14:39:11]: "Не помню синтаксис advisory lock — нужны два аргумента или один?"`
- Scope renegotiation — лог `[14:46:50]: "Этот подход не работает третий раз. Откатываю и попробую через unique constraint."`

**Red signals observed:** Нет.

---

## Cross-cutting anti-patterns

Близкий к "Hypnotising the error" момент `[14:45:10]..[14:57:23]` (12 мин на race condition с похожими попытками), но **не дотянул** до anti-pattern — попытки имели вариации, кандидат в итоге сам сменил вектор. Упоминаем как watch-point.

---

## Additional signals observed

- **Decomposition & Planning** — короткий план в комментариях в начале (`// 1. reproduce 2. find root 3. fix 4. test`) перед codingом
- **Risk & Reversibility** — закомментировал секции для bisection вместо удаления; легко откатывал

---

## Top 3 green moments

1. **Caught AI hallucination of `pg` option** — `[14:31:08]` AI предложил несуществующую опцию `onConflict: 'rollback'`. Кандидат запросил доказательство из docs. Это паттерн который защищает прод от silent bugs.
2. **Test before fix** — `[14:35:22]` написал failing test до фикса. Этот тест действительно падает на main и проходит после фикса — ровно то что просили в задании.
3. **Architecture push-back** — `[14:43:55]` отверг bullmq как избыточное; выбрал advisory lock — встроенный в Postgres, ноль новых зависимостей.

## Top 3 red moments

1. **No grep, ask AI** — `[14:18:55]` "найди где обрабатывается idempotency" вместо `rg "idempotency"`. Это base-layer hygiene, нужно поправить.
2. **No `git diff` pre-commit** — `[14:58:14]` коммит без проверки diff. Если бы AI закинул случайные изменения — попало бы в коммит.
3. **Drift к "hypnotising"** — `[14:45:10]..[14:57:23]` 12 минут на race condition с похожими попытками. В этом конкретном случае выбрался сам, но в более сложной задаче это могло перерасти в час.

---

## Notes for HR

- Senior-уровень мышления подтверждён сигналами 2, 3, 4, 5. Critical reception особенно сильный — это ключевая защита от prod-багов в нашей роли.
- На live follow-up стоит спросить: как ты обычно навигируешься по большому неизвестному репо? Хочу понять компенсирует ли он слабую terminal hygiene другими методами (хорошие IDE-поиски, etc.) или это реальный gap.
- Опционально: дать вторую задачу с большим scope чтобы посмотреть как масштабируется decomposition. 60-min формат не показал предела.
- Watch-point: 12-минутный "стук" в race condition. На пайплайнах где stuck = downtime — стоит дать paired задачу или обсудить технику escape.

---

## Raw stats (для аудита)

- Total user prompts: 23
- Avg prompt length (words): 28 (median 24)
- Tool call mix: Read=12, Edit=18, Bash=29, Grep=2, Write=4, Glob=0
- Tests run: 7
- Commits: 1
- Time to first edit: 14 min
- Longest "stuck" period: 12 min (race condition debug)
