---
description: Stop logging, analyze the session, produce a transparent evaluation report (with weighted scoring + recommendation), and package the handoff for HR.
argument-hint: "[--report-only]"
allowed-tools: Read, Write, Bash, Glob
---

# /eval-report — Generate Report + Package Handoff

Запускается **кандидатом** в конце live-собеседования. Снимает hooks, читает session log, генерирует отчёт по 7 категориям с применением весов из `profile.yaml`, и упаковывает всё для передачи HR в звонке.

HR смотрит на экран через screen share — отчёт появляется одновременно у обоих.

## Flags

- `--report-only` — упаковать только `report.md`, без `log.jsonl` и остальных файлов. По умолчанию пакуется всё (для team lead аудита).

## Process

1. **Найди активную сессию.**
   - Прочитай `.hr-eval/sessions/*/meta.json` в cwd
   - Возьми ту, у которой `status: active` (если несколько — самую свежую)
   - Если нет ни одной active — скажи "нет активной сессии. Запусти `/eval-prepare` → `/eval-start`"

2. **Сними hooks.**
   - Прочитай `.claude/settings.local.json`
   - Удали три hooks с командами `${CLAUDE_PLUGIN_ROOT}/hooks/log-prompt.sh|log-pre-tool.sh|log-post-tool.sh`
   - Сохрани файл обратно
   - Если осталось `{ "hooks": {} }` или `{}` — оставь как есть

3. **Обнови meta.**
   - `status: "completed"`, `ended_at: <ISO>`

4. **Проанализируй log.**
   - Прочитай `${CLAUDE_PLUGIN_ROOT}/lib/analyzer-prompt.md` — твоя инструкция
   - Прочитай `${CLAUDE_PLUGIN_ROOT}/lib/rubric.md` — таксономия 7 категорий
   - Прочитай `.hr-eval/sessions/<session-id>/log.jsonl` целиком
   - Прочитай `.hr-eval/sessions/<session-id>/task.md`
   - Прочитай `.hr-eval/sessions/<session-id>/profile.yaml` — для весов, critical caps, custom flags
   - Если `profile.yaml` отсутствует — дефолтные веса 1.0 ко всем категориям, пометь "no profile applied"

5. **Сгенерируй report по структуре из analyzer-prompt.md.**

   Критические правила (повтор):
   - Только цитаты из лога с timestamps
   - Не путать скорость с качеством
   - Score `null` валиден
   - Не суди финальный код
   - Тон конструктивный — кандидат, HR и потом team lead будут это читать
   - Подсвети anti-sycophancy моменты если были
   - Включи Weighted scoring таблицу + Custom flag matches + Critical caps + Overall % + Recommendation tier inline (не отдельным шагом)

6. **Сохрани в `.hr-eval/sessions/<session-id>/report.md`** и **покажи полный текст отчёта inline** — HR видит через screen share одновременно с кандидатом.

7. **Упакуй handoff.**

   По умолчанию (без `--report-only`):
   ```bash
   cd .hr-eval/sessions
   zip -r <session-id>.zip <session-id>/
   open .
   ```
   В zip попадает всё: `report.md`, `log.jsonl`, `task.md`, `setup.md`, `profile.yaml`, `meta.json`, `jd.txt`.

   С `--report-only`:
   ```bash
   open .hr-eval/sessions/<session-id>/report.md
   ```
   Открывает только `report.md` в дефолтном просмотрщике.

   Скажи кандидату: "Папка открыта в Finder. Перетащи zip (или report.md) в чат звонка / Telegram / email HR-у."

8. **Подскажи как удалить плагин.**

   После того как пакет ушёл HR, плагин больше не нужен. Скажи кандидату:

   > "Спасибо за сессию. Если плагин тебе больше не пригодится — удали его командой:
   >
   > ```
   > /plugin uninstall hr-eval@webkoth
   > ```
   >
   > Файлы сессии в `.hr-eval/sessions/<session-id>/` останутся локально на твоей машине — можешь сохранить или удалить вручную."

## Raw stats для отчёта

Вычисли из log.jsonl и включи в "Raw stats" секцию:

```bash
# Total user prompts
grep '"type":"user_prompt"' .hr-eval/sessions/<id>/log.jsonl | wc -l

# Tool call counts
grep '"type":"tool_pre"' .hr-eval/sessions/<id>/log.jsonl | jq -r '.raw.tool_name // .raw.tool // "unknown"' | sort | uniq -c

# Session duration = (last event ts - first event ts)
# Time to first edit = (first tool_pre where tool=Edit/Write) - (first user_prompt)
```

Время "stuck" — если два подряд user_prompts с похожим содержанием (same error message, same approach) разделены > 5 минут — это stuck period. Суммируй.

## Notes

- Если `log.jsonl` пустой или меньше 5 событий — пиши "недостаточно данных для оценки" вместо галлюцинированного отчёта (но всё равно собери handoff пакет — лог пригодится для аудита).
- Файлы остаются локально у кандидата. Скилл ничего никуда автоматически не отправляет — только готовит пакет.
- `--report-only` уместен если HR хочет только summary без полного лога; полная прозрачность подразумевает дефолт (весь пакет включая `log.jsonl`).
