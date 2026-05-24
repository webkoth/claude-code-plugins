---
description: Generate task + transparent evaluation profile at the start of a live interview call. Run by candidate, with HR's verbal guidance.
allowed-tools: Read, Write, Bash, Glob
---

# /eval-prepare — Generate Task & Profile (live, in front of HR)

Запускается **кандидатом** на своей машине в начале live-собеседования. HR сидит на звонке, видит экран, помогает голосом отвечать на вопросы. Никакого профиля HR заранее не готовит — всё происходит здесь, прозрачно.

Из JD + 3-5 устных ответов HR-а генерирует:

- `task.md` — задание для кандидата
- `setup.md` — инструкция по setup среды
- `profile.yaml` — один плоский профиль (position + company + weights + custom flags + notes), **виден кандидату**
- `meta.json` — session metadata, `status: prepared`
- `jd.txt` — оригинальный JD для аудита

Всё кладётся в `<cwd>/.hr-eval/sessions/<session-id>/`. `/eval-start` дальше подхватит эту prepared-сессию.

## Process

1. **Получи JD.**
   - HR может прислать в чат звонка → кандидат paste'ит
   - Или path к локальному файлу
   - Или HR диктует голосом — кандидат пишет

2. **Прочитай и разбери JD** (position, level, stack, domain, тип задач — см. `${CLAUDE_PLUGIN_ROOT}/lib/prepare-prompt.md` шаг 1).

3. **Задай 3-5 уточняющих вопросов вслух** через AskUserQuestion (1-3 за раз). Кандидат пересказывает HR голосом, HR отвечает, кандидат вписывает. Полный список в `${CLAUDE_PLUGIN_ROOT}/lib/prepare-prompt.md` шаг 2.

4. **Сгенерируй артефакты** по шаблону в `${CLAUDE_PLUGIN_ROOT}/lib/prepare-prompt.md` шаг 3. Принципы дизайна задания соблюдай строго.

5. **Сгенерируй session-id и сохрани в `<cwd>/.hr-eval/sessions/<session-id>/`:**
   - `session-id` = `<YYYYMMDD-HHMMSS>-<short-uuid>` (`date +%Y%m%d-%H%M%S` + `uuidgen | head -c 8`)
   - Файлы: `task.md`, `setup.md`, `profile.yaml`, `meta.json` (status: "prepared"), `jd.txt`
   - **После записи task.md и profile.yaml** — посчитай SHA-256 каждого:
     ```bash
     shasum -a 256 .hr-eval/sessions/<id>/task.md | awk '{print $1}'
     shasum -a 256 .hr-eval/sessions/<id>/profile.yaml | awk '{print $1}'
     ```
     И запиши оба хеша в `meta.json` как `task_sha256` и `profile_sha256`. Это integrity-check — `/eval-report` сверит хеши и если кто-то изменил файлы после prepare, отчёт получит integrity warning.

6. **Покажи кандидату + HR-у:**
   - Список созданных файлов и абсолютный путь к session-папке
   - Полный `task.md` (HR подтверждает голосом что окей)
   - Предложенные веса с однострочным обоснованием на каждый — HR подтверждает или корректирует голосом
   - Следующий шаг: `/eval-start` (он подхватит prepared-сессию автоматически)

## Notes

- В `task.md`, `notes`, `profile.yaml` НЕ должно быть имён реальных клиентов, секретов, IP компании.
- Веса по умолчанию = 1.0; модифицируешь только если есть основания из JD/ответов HR-а (правила в `prepare-prompt.md`).
- Если в `<cwd>/.hr-eval/sessions/` уже есть session со status `prepared` без последующего `/eval-start` — спроси: использовать ту или создать новую.
- Это **обязательный** первый шаг. `/eval-start` без prepared-сессии откажется стартовать — это часть transparency контракта (кандидат должен видеть task + веса до того как hooks активируются).
