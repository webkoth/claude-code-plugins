---
description: HR command. Apply a private company profile (weights + custom flags) to a candidate report and compute the final % fit.
argument-hint: "<report-path-or-url> [--profile <profile-private-path>]"
allowed-tools: Read, Write, Bash, WebFetch, Glob
---

# /eval-grade — Apply Private Profile to Candidate Report

Используется **HR-ом** после того, как кандидат прислал `report.md`. Накладывает приватный профиль с весами и custom flags, считает финальный % fit, добавляет recommendation.

## Inputs

- **Report:** path к локальному `report.md` или URL (gist/email attachment скачанный локально). Аргумент 1.
- **Profile-private:** path к `profile-private.yaml`. По умолчанию ищется в `~/.hr-eval/jobs/*/profile-private.yaml` — если найдено больше одного, спроси HR-а какой использовать.

## Process

1. **Получи report.**
   - Если path — Read
   - Если URL — WebFetch с request format markdown

2. **Получи profile-private.**
   - Если есть `--profile <path>` — используй его
   - Иначе — `ls ~/.hr-eval/jobs/*/profile-private.yaml` и спроси HR-а
   - Прочитай YAML

3. **Извлеки per-category scores из report.md.**
   - Найди секции `### N. <Category> — \`<score>\``
   - Парси scores (0..5 или N/A)

4. **Применяй custom green/red flags.**
   - Для каждого `custom_green_flag` в profile-private:
     - Найди в report.md (в Top 3 green / per-category sections) совпадение по `signal`
     - Если найдено — score соответствующей `category` множится на `weight_multiplier` (cap 5.0)
   - Аналогично для `custom_red_flags` — но множитель уменьшает score (cap 0)

5. **Считай weighted overall %.**
   ```
   weighted_sum = Σ (score_i × weight_i)  для категорий с не-null score
   max_possible = Σ (5 × weight_i)        для тех же категорий
   overall_pct = (weighted_sum / max_possible) × 100
   ```

6. **Применяй critical caps.**
   - Для каждого `critical` в profile-private:
     - Если score этой категории ≤ `threshold` → `overall_pct = min(overall_pct, cap_overall_pct)`

7. **Сгенерируй HR addendum** и допиши в конец report.md (или создай `report-graded.md` рядом):

   ```markdown
   ---

   # HR Grading (private)

   **Profile:** <jobs/<slug>/profile-private.yaml>
   **Graded at:** <ISO>

   ## Weighted scoring

   | Category | Score | Weight | Weighted | Notes |
   |---|---|---|---|---|
   | Promptcraft | 4 | 1.0 | 4.0 | |
   | Critical Reception | 2 | 1.5 | 3.0 | red flag matched: "blindly accepted hallucinated API" |
   | ... | | | | |

   ## Custom flag matches

   **Green flags matched:** <list или "none">
   **Red flags matched:** <list или "none">

   ## Critical caps applied

   <list или "none">

   ## Overall fit: **<NN>%**

   ## Recommendation

   <one of:>
   - **STRONG HIRE** — score ≥ 80, no critical caps, ≥ 3 green flags matched
   - **HIRE** — score 65-79, no critical caps
   - **NEEDS DEEPER INTERVIEW** — score 50-64, или critical cap applied
   - **NO HIRE** — score < 50

   ## What to probe in live follow-up

   <3-5 bullets — что стоит спросить если идём на следующий этап. Берём из "Notes for HR" исходного report.md + ориентируемся на слабые категории.>
   ```

8. **Покажи HR-у summary** и путь к `report-graded.md` (или к updated report.md).

## Critical rules

- **Не модифицируй кандидатский report.md.** Создавай `report-graded.md` рядом, или допиши в копии. Оригинал, который видит кандидат, остаётся без HR-блока.
- **Не выдумывай scores.** Если категория в report.md была N/A — она N/A и в grading (не входит в weighted_sum и max_possible).
- **Custom flag match — строгий.** Только если signal в profile-private совпадает с явно зафиксированным сигналом в report.md (по keywords из обоих).
- **Recommendation — рекомендация, не приговор.** Финальное решение всегда за HR-ом.

## Notes

- Если profile-private отсутствует или невалиден — посчитай неmodified overall % из report.md (равные веса), пометь "no profile applied".
- Возможен batch режим (несколько кандидатов на одну вакансию): `/eval-grade <report1> <report2> ... --profile <p>` — пока не поддержано, но в roadmap.
