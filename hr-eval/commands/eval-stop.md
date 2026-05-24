---
description: Abort the current session without generating a report. Keeps all files for audit.
allowed-tools: Read, Write, Bash, Glob
---

# /eval-stop — Abort Session

Досрочно завершает активную сессию **без** генерации отчёта. Полезно если что-то пошло не так и нужно почистить hooks, или если HR/кандидат решили прервать собеседование.

Файлы сессии **не удаляются** — они остаются для возможного аудита team lead'ом (это часть transparency контракта).

## Process

1. **Найди активную session.**
   - Прочитай `.hr-eval/sessions/*/meta.json`
   - Возьми ту со `status: "active"` (или "prepared" если кандидат хочет отменить и до старта)

2. **Сними hooks** (см. `/eval-report` шаг 2).

3. **Обнови meta.**
   - `status: "aborted"`, `ended_at: <ISO>`

4. **Подтверди:**
   - "Сессия остановлена. Hooks сняты. Файлы остались в `.hr-eval/sessions/<id>/` (для аудита). Можешь запустить `/eval-prepare` → `/eval-start` снова если нужно."

## Notes

- Если активной сессии нет — всё равно проверь `.claude/settings.local.json` и убери hr-eval hooks если они остались (защитный механизм).
- Удаление логов **не предлагается** — это противоречит модели прозрачности (team lead должен иметь доступ ко всем сессиям при ревью найма). Если кандидат хочет удалить — пусть удаляет вручную через `rm`, осознанно.
