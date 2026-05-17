---
description: HR command. Generate a candidate task + evaluation profile from a job description.
allowed-tools: Read, Write, Bash, Glob
---

# /eval-prepare — Generate Task & Profile from JD

Используется **HR-ом** (или нанимающим руководителем) до собеседования. Из текста JD генерирует:

- `task.md` — задание для кандидата (public, paste-ready)
- `setup.md` — инструкция по setup среды (public)
- `profile-public.yaml` — открытая часть профиля (передаётся кандидату)
- `profile-private.yaml` — приватная часть с весами категорий, custom red/green flags (остаётся у HR-а)
- `SHARE.md` — paste-ready сообщение для кандидата
- `jd.txt` — оригинальный JD для аудита

Всё кладётся в `~/.hr-eval/jobs/<job-slug>/`.

## Process

1. **Спроси у HR-а JD.** Один из двух форматов:
   - Inline paste (HR вставляет текст в сообщение)
   - Path к файлу: HR говорит "из файла ~/Desktop/jd.md"

2. **Прочитай и разбери JD** по полям:
   - position title, level
   - tech stack
   - domain
   - тип задач
   - team size (если упомянут)

3. **Задай 3-5 уточняющих вопросов HR-у** (см. полный список в `${CLAUDE_PLUGIN_ROOT}/lib/prepare-prompt.md`, секция "Шаг 2"). Используй AskUserQuestion tool с 1-3 questions за раз. Не задавай вопросы про вещи, которые уже явно есть в JD.

4. **Сгенерируй артефакты** по шаблону в `${CLAUDE_PLUGIN_ROOT}/lib/prepare-prompt.md` (секция "Шаг 3"). Принципы дизайна задания строго соблюдай.

5. **Сохрани в `~/.hr-eval/jobs/<job-slug>/`** где slug — kebab-case из title.

6. **Покажи HR-у:**
   - Что сгенерировано (список файлов)
   - Путь к папке
   - Preview SHARE.md (paste-ready, готово отправлять кандидату)
   - Спроси: всё ок или нужны правки?

## Methodology reference

Полная методология генерации — в `${CLAUDE_PLUGIN_ROOT}/lib/prepare-prompt.md`. Прочитай его и rubric.md перед началом работы — они описывают:
- Что считается хорошим заданием (anti-algorithmic, ambiguity by design, hallucination trap, possibility of overengineering)
- Как выводить веса 7 категорий из JD и ответов HR-а
- Структуру profile-public/private

## Notes

- Если папка `~/.hr-eval/jobs/<slug>/` уже существует — спроси HR-а: overwrite или новый slug?
- В `task.md` НЕ должно быть имени реальных клиентов, секретов, IP компании
- Веса в `profile-private.yaml` дефолтятся к 1.0; модифицируешь только если есть основания из JD/ответов HR-а
