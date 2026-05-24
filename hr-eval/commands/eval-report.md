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

4. **Integrity check.**
   - Прочитай `meta.json`, возьми `task_sha256` и `profile_sha256`.
   - Пересчитай хеши файлов сейчас:
     ```bash
     shasum -a 256 .hr-eval/sessions/<id>/task.md | awk '{print $1}'
     shasum -a 256 .hr-eval/sessions/<id>/profile.yaml | awk '{print $1}'
     ```
   - Сравни с сохранёнными. Если хоть один не совпал — установи флаг `integrity_violation: true` и сохрани детали (`task_modified` / `profile_modified`) для передачи в analyzer.
   - Сессия **не отказывается** идти — отчёт всё равно генерируется, но в нём будет прозрачный INTEGRITY WARNING блок наверху (см. analyzer-prompt.md).

5. **Scan sibling sessions** в той же `<cwd>/.hr-eval/sessions/`:
   - `ls -t .hr-eval/sessions/*/meta.json` — найди все meta.json в cwd
   - Для каждой собери `(session_id, status, prepared_at, ended_at)`
   - Текущую сессию исключи. Остальные — список "previous attempts" с их статусами для передачи в analyzer.
   - Если есть >0 sibling сессий (особенно со status `aborted`) — это retry pattern, обязательно подсветить в отчёте.

6. **Проанализируй log.**
   - Прочитай `${CLAUDE_PLUGIN_ROOT}/lib/analyzer-prompt.md` — твоя инструкция
   - Прочитай `${CLAUDE_PLUGIN_ROOT}/lib/rubric.md` — таксономия 7 категорий
   - Прочитай `.hr-eval/sessions/<session-id>/log.jsonl` целиком
   - Прочитай `.hr-eval/sessions/<session-id>/task.md`
   - Прочитай `.hr-eval/sessions/<session-id>/profile.yaml` — для весов, critical caps, custom flags
   - Если `profile.yaml` отсутствует — дефолтные веса 1.0 ко всем категориям, пометь "no profile applied"
   - **Передай в analyzer** integrity result из шага 4 и sibling sessions list из шага 5 — они обязаны попасть в отчёт.

7. **Сгенерируй report по структуре из analyzer-prompt.md.**

   Критические правила (повтор):
   - Только цитаты из лога с timestamps
   - Не путать скорость с качеством
   - Score `null` валиден
   - Не суди финальный код
   - Тон конструктивный — кандидат, HR и потом team lead будут это читать
   - Подсвети anti-sycophancy моменты если были
   - Включи Weighted scoring таблицу + Custom flag matches + Critical caps + Overall % + Recommendation tier inline
   - Если `integrity_violation: true` — INTEGRITY WARNING блок наверху отчёта (сразу после metadata)
   - Если есть sibling sessions — Session attempts блок (см. analyzer-prompt.md report structure)

8. **Сохрани в `.hr-eval/sessions/<session-id>/report.md`** и **покажи полный текст отчёта inline** — HR видит через screen share одновременно с кандидатом.

9. **Упакуй handoff.**

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

10. **Подскажи как удалить плагин.**

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
