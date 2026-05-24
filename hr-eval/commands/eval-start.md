---
description: Begin the logged interview session. Requires /eval-prepare to have been run first.
allowed-tools: Read, Write, Bash, Glob
---

# /eval-start — Begin Interview Session

Запускается **кандидатом** после того, как `/eval-prepare` сгенерировал task + profile в live-режиме с HR-ом на звонке.

Показывает consent notice, активирует logging hooks, открывает task.

## Process

1. **Найди prepared-сессию.**
   - Прочитай `.hr-eval/sessions/*/meta.json` в cwd
   - Возьми ту, у которой `status: "prepared"` (если несколько — самую свежую)
   - Если нет ни одной — откажись стартовать:
     > "Сначала запусти `/eval-prepare`. Это часть transparency контракта — task и веса должны быть сгенерированы у тебя на экране в присутствии HR. Без этого `/eval-start` не запускается."
   - Если уже есть `status: "active"` — спроси: продолжить ту, или завершить (`/eval-stop`) и стартовать новую (придётся сначала `/eval-prepare`).

2. **Покажи consent notice.**
   - Прочитай `${CLAUDE_PLUGIN_ROOT}/lib/consent-notice.md`
   - Покажи кандидату полностью (HR видит через screen share)
   - Дождись подтверждения ("да", "ok", "согласен", "go" или явное согласие)
   - Если кандидат отказывается — не активируй hooks, оставь meta как есть, выйди gracefully

3. **Активируй hooks.**
   - Прочитай существующий `.claude/settings.local.json` (если есть)
   - Резолви `${CLAUDE_PLUGIN_ROOT}` в абсолютный путь **до** записи в settings (через Bash `echo $CLAUDE_PLUGIN_ROOT`) — placeholder в самом JSON не разворачивается
   - Резолви абсолютный cwd через `pwd`
   - Добавь (или создай) секцию `hooks` с тремя hook'ами:

   ```json
   {
     "hooks": {
       "UserPromptSubmit": [
         {
           "matcher": "*",
           "hooks": [
             {
               "type": "command",
               "command": "<absolute-CLAUDE_PLUGIN_ROOT>/hooks/log-prompt.sh",
               "env": { "HR_EVAL_SESSION": "<session-id>", "HR_EVAL_CWD": "<absolute-cwd>" }
             }
           ]
         }
       ],
       "PreToolUse": [
         {
           "matcher": "*",
           "hooks": [
             {
               "type": "command",
               "command": "<absolute-CLAUDE_PLUGIN_ROOT>/hooks/log-pre-tool.sh",
               "env": { "HR_EVAL_SESSION": "<session-id>", "HR_EVAL_CWD": "<absolute-cwd>" }
             }
           ]
         }
       ],
       "PostToolUse": [
         {
           "matcher": "*",
           "hooks": [
             {
               "type": "command",
               "command": "<absolute-CLAUDE_PLUGIN_ROOT>/hooks/log-post-tool.sh",
               "env": { "HR_EVAL_SESSION": "<session-id>", "HR_EVAL_CWD": "<absolute-cwd>" }
             }
           ]
         }
       ]
     }
   }
   ```

4. **Обнови meta.**
   - `status: "active"`, `started_at: <ISO>`, `consent_given_at: <ISO>`

5. **Покажи task.**
   - Выведи содержимое `.hr-eval/sessions/<session-id>/task.md`
   - Скажи: "Hooks активны, всё логируется. Работай как обычно. Когда закончишь — `/eval-report`. Удачи."

## Notes

- `/eval-start` **не создаёт** новую сессию и не принимает task аргументом. Task формируется на шаге `/eval-prepare` вместе с HR — это часть transparency контракта.
- Hook scripts должны быть executable. Если плагин ставился через marketplace — обычно ок; если вручную, проверь `chmod +x ${CLAUDE_PLUGIN_ROOT}/hooks/*.sh`.
- Если кандидат запускает в папке без write-доступа — сообщи об ошибке, не активируй hooks.
