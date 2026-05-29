# apply-job

Generate a tailored CV and motivation letter for a job application.

## Input

`$ARGUMENTS` contains the full job description text.

## Steps

### 1. Derive the folder name

From the job description, extract the company name and role title. Compose a folder name following the existing convention in `Professional/CV/Jobs/` (e.g. `"Kraken Technologies France - Python Developer Remote"`, `"Natural Solutions - Web"`, `"CNRS - Expert en Ingénierie logicielle"`). Match the language and casing style of existing folders.

### 2. Create the directory and save the job description

- Create `Professional/CV/Jobs/[folder name]/`
- Write the full job description from `$ARGUMENTS` to `Professional/CV/Jobs/[folder name]/Job Description.md`

### 3. Read the source files

Read both files in full before generating anything:
- `README.md` — single source of truth for all experiences, projects, achievements, skills, and links
- `Professional/CV/cv_format_spec.md` — authoritative format rules for cv.md and motivation_letter.md

### 4. Generate `cv.md`

Follow `Professional/CV/cv_format_spec.md` exactly. Key rules to enforce:
- **Language**: match the job description language (French or English)
- **Intro**: 570–580 characters (excluding all links in parentheses), exactly 2 narrative paragraphs, no markdown links — only `(https://url.com)` inline after project names
- **Skills**: max 9 technical + max 9 workflow keywords, selected for relevance to this job
- **Job experiences**: max 3, reverse chronological, `[ICON]` placeholder instead of markdown links, bullet points as plain sentences (~95 chars each, excl. links), all project mentions include a link in parentheses immediately after the name, followed by a `Links:` subsection
- **Do not name the employer, their products, or their brands** — keep cv.md portable; use domains, stacks, and outcomes from README.md only
- **TheMusicDeck**: refer to it as a game/product only — never mention "TheMusicDeck Admin" or any admin/back-office tooling; surface it as the end-user game experience
- **No markdown links** (`[text](url)`) anywhere — use `[ICON]` for icon placeholders and `(https://url.com)` for project links

Write the file to `Professional/CV/Jobs/[folder name]/cv.md`.

### 5. Generate `motivation_letter.md`

Follow `Professional/CV/cv_format_spec.md` exactly. Key rules:
- **Language**: match the job description language
- **Structure**: 3–4 paragraphs — opening & interest, relevant experience & skills, cultural fit & values, closing
- Name the company and role explicitly (unlike the CV)
- Reference specific requirements from the job description and connect them to concrete experiences/metrics from README.md

Write the file to `Professional/CV/Jobs/[folder name]/motivation_letter.md`.

### 6. Validate and adjust

Before finalising, verify:
1. Intro character count (excluding all links in parentheses) is between 570 and 580 — adjust if not
2. Each job experience bullet is approximately 95 characters (excluding links in parentheses) — adjust any that are significantly over or under
3. Every project mentioned in the intro or job experiences has a link in parentheses immediately after it
4. No markdown links (`[text](url)`) appear anywhere in cv.md

Report the validated character counts for the intro and confirm the files were created.
