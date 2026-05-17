---
description: Candidate command. Start a logged AI-assisted interview session.
argument-hint: "[task-path-or-url-or-paste]"
allowed-tools: Read, Write, Bash, WebFetch
---

# /eval-start — Begin Interview Session

Используется **кандидатом** в начале собеседования. Показывает consent notice, активирует logging hooks, открывает task.

## Process

1. **Получи task.**
   - Если есть аргумент `$ARGUMENTS` — определи его тип:
     - Локальный path к `.md` файлу → читай через Read
     - URL (gist/github raw) → читай через WebFetch (request format: markdown)
     - Если аргумент длиннее 200 символов и содержит markdown — трактуй как inline paste
   - Если аргумент пустой — попроси кандидата либо вставить task текстом, либо дать path/URL

2. **Создай session folder.**
   - Сгенерируй session-id: `<YYYYMMDD-HHMMSS>-<short-uuid>` (используй `date +%Y%m%d-%H%M%S` и `uuidgen | head -c 8`)
   - Создай папку `.hr-eval/sessions/<session-id>/` в текущей рабочей директории (cwd)
   - Сохрани task в `.hr-eval/sessions/<session-id>/task.md`
   - Если в task.md (или его рядом) идёт `profile-public.yaml` — сохрани его тоже

3. **Покажи consent notice.**
   - Прочитай `${CLAUDE_PLUGIN_ROOT}/lib/consent-notice.md`
   - Покажи кандидату полностью
   - Дождись подтверждения ("да", "ok", "согласен", "go" или любое явное согласие)
   - Если кандидат отказывается — не начинай, выйди gracefully

4. **Активируй hooks.**
   - Прочитай существующий `.claude/settings.local.json` (если есть)
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
               "command": "${CLAUDE_PLUGIN_ROOT}/hooks/log-prompt.sh",
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
               "command": "${CLAUDE_PLUGIN_ROOT}/hooks/log-pre-tool.sh",
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
               "command": "${CLAUDE_PLUGIN_ROOT}/hooks/log-post-tool.sh",
               "env": { "HR_EVAL_SESSION": "<session-id>", "HR_EVAL_CWD": "<absolute-cwd>" }
             }
           ]
         }
       ]
     }
   }
   ```

   Замени `<session-id>` на реальное значение, `<absolute-cwd>` на абсолютный путь текущей рабочей директории (выведи через `pwd`). `${CLAUDE_PLUGIN_ROOT}` — резолви в абсолютный путь к корню плагина **до записи** в settings.local.json (через env `echo $CLAUDE_PLUGIN_ROOT` в Bash tool); placeholder в самой записи settings.local.json не разворачивается.

5. **Запиши session metadata.**
   - Создай `.hr-eval/sessions/<session-id>/meta.json`:
     ```json
     {
       "session_id": "<session-id>",
       "started_at": "<ISO timestamp>",
       "cwd": "<absolute path>",
       "task_source": "<file path | url | inline>",
       "consent_given_at": "<ISO timestamp>",
       "status": "active"
     }
     ```

6. **Покажи task.**
   - Выведи содержимое task.md
   - Скажи кандидату: "Всё готово. Работай как обычно. Когда закончишь — `/eval-report`. Удачи!"

## Notes

- Если session уже запущена (есть active `meta.json`) — предложи: продолжить эту, или завершить и стартовать новую.
- Если кандидат запускает в папке без write-доступа — сообщи об ошибке.
- Hook scripts должны быть executable (chmod +x при установке плагина).
