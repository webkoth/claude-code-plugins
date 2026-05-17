---
description: Candidate command. Stop logging, analyze the session, and produce an evaluation report.
allowed-tools: Read, Write, Bash, Glob
---

# /eval-report — Generate Evaluation Report

Используется **кандидатом** в конце собеседования. Снимает hooks, читает session log, генерирует отчёт по 7 категориям мышления.

## Process

1. **Найди активную session.**
   - Прочитай `.hr-eval/sessions/*/meta.json` в cwd
   - Возьми ту, у которой `status: active` (если их несколько — самую свежую)
   - Если нет ни одной — скажи "нет активной сессии, запусти /eval-start"

2. **Сними hooks.**
   - Прочитай `.claude/settings.local.json`
   - Удали три hooks с командами `${CLAUDE_PLUGIN_ROOT}/hooks/log-prompt.sh|log-pre-tool.sh|log-post-tool.sh`
   - Сохрани файл обратно
   - Если файл стал `{ "hooks": {} }` или `{}` — оставь как есть

3. **Обнови meta.**
   - Установи `status: "completed"`, `ended_at: <ISO>`

4. **Проанализируй log.**
   - Прочитай `${CLAUDE_PLUGIN_ROOT}/lib/analyzer-prompt.md` — это твоя инструкция как ревьюера
   - Прочитай `${CLAUDE_PLUGIN_ROOT}/lib/rubric.md` — таксономия 7 категорий
   - Прочитай `.hr-eval/sessions/<session-id>/log.jsonl` целиком
   - Прочитай `.hr-eval/sessions/<session-id>/task.md`
   - Если есть `profile-public.yaml` — прочитай и его

5. **Сгенерируй report по структуре из analyzer-prompt.md.**

   Критические правила (повтор из analyzer-prompt):
   - Только цитаты из лога с timestamps
   - Не путать скорость с качеством
   - score `null` валиден (недостаточно сигналов)
   - Не суди финальный код
   - Тон конструктивный — кандидат увидит этот отчёт первым
   - Подсвети anti-sycophancy моменты если они были

6. **Сохрани в `.hr-eval/sessions/<session-id>/report.md`** и покажи кандидату:
   - Short summary (TL;DR блок)
   - Per-category scores (одной строкой)
   - Путь к полному файлу
   - Напоминание: "Этот отчёт у тебя. Ты решаешь отправлять ли HR-у."

## Raw stats для отчёта

Вычисли из log.jsonl и включи в Raw stats секцию отчёта:

```bash
# Total user prompts
grep '"type":"user_prompt"' .hr-eval/sessions/<id>/log.jsonl | wc -l

# Tool call counts
grep '"type":"tool_call"' .hr-eval/sessions/<id>/log.jsonl | jq -r '.tool' | sort | uniq -c

# Session duration
# = (last event ts - first event ts)

# Time to first edit
# = (first tool_call where tool=Edit/Write) - (first user_prompt)
```

Время "stuck" — если найдёшь два подряд user_prompts с похожим содержанием (same error message, same approach) разделённых > 5 минут — это часть stuck periods. Суммируй.

## Notes

- Если log.jsonl пустой или меньше 5 событий — пиши "недостаточно данных для оценки" вместо галлюцинированного отчёта.
- Файл report.md остаётся локально у кандидата. Скилл не отправляет его никуда автоматически.
