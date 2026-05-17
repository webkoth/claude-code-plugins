---
description: Candidate command. Abort the current session without generating a report.
allowed-tools: Read, Write, Bash, Glob
---

# /eval-stop — Abort Session

Досрочно завершает активную сессию **без** генерации отчёта. Полезно если кандидат хочет прервать собеседование, или если что-то пошло не так и нужно почистить hooks.

## Process

1. **Найди активную session** (см. /eval-report шаг 1).

2. **Сними hooks** (см. /eval-report шаг 2).

3. **Обнови meta.**
   - `status: "aborted"`, `ended_at: <ISO>`

4. **Спроси кандидата:**
   - "Сессия остановлена. Удалить логи (`log.jsonl`) или оставить для повторного анализа позже?"
   - Если "удалить" — `rm .hr-eval/sessions/<id>/log.jsonl`
   - Иначе оставить.

5. **Подтверди:** "Готово. Hooks сняты. Можешь запустить /eval-start снова если нужно."

## Notes

- Если активной сессии нет — просто проверь settings.local.json и убери hr-eval hooks если они остались (защитный механизм).
