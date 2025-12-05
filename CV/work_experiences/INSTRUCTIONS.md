INSTRUCTIONS — CV / Work Experiences

Purpose

- This directory contains separate files for different job variants used in CV templates (especially Canva). Each file contains 4 experiences listed from most recent to oldest, in both English (EN:) and French (FR:) versions.

Files

- `full_stack.txt` — Full-Stack Developer variant
- `backend.txt` — Backend Developer variant
- `erp_bi.txt` — ERP / BI variant
- `data_etl.txt` — Data / ETL variant

Format rules (English)

- Each variant is divided into 1st/2nd/3rd/4th Experience sections.
- For each experience, the structure is:
  1st Experience
  EN:
  Role — Company (Dates) — link (optional)
  - Short bullet describing responsibilities or achievements (2–3 bullets recommended; 1–2 lines each)
  - Additional short bullets (2–3 total recommended)
    FR:
    Rôle — Entreprise (Dates) — lien (si disponible)
  - Bullets translated to French

Formatting constraints and best practices

- Keep bullets concise (1–2 lines each) and factual — do not invent metrics or claims you can’t verify.
- Dates: Prefer "YYYY" or "Mon YYYY" formats (e.g., Dec. 2022 – Present, Oct 2018 – Dec 2019).
- Order: Experiences should be listed from most recent (1st Experience) to oldest (4th Experience).
- Links: Add a link next to the role when relevant (company or repo). Canva can render clickable links in designs.
- Remove numeric prefixes (like "1)") — keep the ordinal chapter titles ("1st Experience") but do not number the role lines.
- Align EN and FR sections: for each EN block, provide a directly corresponding FR block beneath.
- Keep language markers (EN: / FR:) in place to help translators or scripts parse the document.

Validation Checks (optional)

- For automated checks, ensure each EN: is followed by a non-bullet role line and at least 1 bullet; same for FR: sections.
- Check there are no leftover numbered lines like "1) " in these files.

Commit & update flow

- Edit the relevant one-file per variant, verify the changes locally, then commit with a message such as:
  git add CV/work_experiences/<variant>.txt
  git commit -m "docs(cv): update <variant> with new experience"
  git fetch origin && git rebase origin/main && git push origin main

When editing for Canva

- Copy the variant matching the targeted job, then paste to your personal Canva content. Replace the role lines and bullets with your factual details, keeping translations aligned.
- For design: 1 or 2 bullets per experience are usually best for fit.

Notes & conventions

- Do not add soft or fuzzy claims. If you need to include achievements with numbers, keep them verifiable.
- Keep the final variants short and easily scannable for the reader.

FR (Résumé des consignes en français)

- Cette arborescence contient un fichier par variante de poste pour faciliter la personnalisation dans des templates Canva.
- Structure: 1st/2nd/3rd/4th Experience → EN: (Role — Company) + bullets → FR: (Rôle — Entreprise) + bullets.
- Respectez l’ordre chronologique (du plus récent au plus ancien), conservez les balises EN: / FR: et alignez la traduction FR sous l’entrée EN correspondante.
- Ne pas inventer de chiffres non vérifiables; les bullets doivent rester courtes (1–2 lignes).
- Pour valider: vérifier l’absence de lignes numérotées du type "1)" et s’assurer que chaque EN/FR a un en-tête non-bullet suivi de 1 ou 2 bullets.

If you want automation help

- I can add a small script (Python) that walks through variant files and verifies the syntax rules and flags missing role headers or misaligned EN/FR blocks.
- Would you like me to add that script to the repo?
