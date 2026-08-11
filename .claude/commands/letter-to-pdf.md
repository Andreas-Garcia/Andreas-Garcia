# letter-to-pdf

Generate a polished, print-ready PDF from a job application motivation letter.

## Input

`$ARGUMENTS` — path to a job folder under `Professional/CV/Jobs/` (e.g. `SOLEIL - Développeur Django - Paris-Saclay`), or a direct path to the letter file.

## Steps

### 1. Locate the letter

Resolve `$ARGUMENTS` to a job folder under `Professional/CV/Jobs/`. Find the motivation letter in it (`motivation_letter.md`, `Lettre de Motivation.md`, or similar — check what's actually present). Read it in full.

### 2. Gather sender details and context

- Read `README.md` at the repo root for canonical contact details (full name, phone, email). Do not invent contact information — if something is missing, ask the user rather than guessing.
- Read `Job Description.md` (or equivalent) in the same folder for the role title, company/organization name, and — if named — the recruiter's name, to build the object line and greeting.

### 3. Build a single self-contained HTML file

Transform the letter's body into an HTML file with:

- **Sender block** (top-right): name (bold), phone, email as a `mailto:` link.
- **Date line**: "Névez, le [today's date in French, e.g. 29 juillet 2026]". Always Névez, never Paris or any other city.
- **Object line** (bold): "Objet : Candidature au poste de [role] — [company/organization]".
- **Greeting**: "Madame, Monsieur," by default. If the job description names a specific recruiter and their apparent gender is unambiguous from the name/title, use "Madame [Nom]," or "Monsieur [Nom]," instead — never guess when ambiguous.
- **Body**: one `<p>` per source paragraph, justified text.
- **Links — no raw URLs in the rendered text**: any `ProjectName (https://url)` or `[ProjectName](https://url)` pattern becomes `<a href="https://url">ProjectName</a>`. The project name itself is the clickable text; the URL string must never be visibly printed.
- **Sign-off**: "Cordialement,<br>[Name]".
- **Style**: clean sans-serif (Helvetica/Arial), ~11.5pt body, A4 page (`@page { size: A4; margin: 2.5cm 3cm; }`), line-height 1.5, links same color as body text but underlined (no garish blue).

Write this HTML to a scratch file (use the scratchpad directory, not the repo).

### 4. Render to PDF with headless Chrome

```bash
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --headless --disable-gpu --no-pdf-header-footer --print-to-pdf="<scratch>/letter.pdf" "file://<scratch>/letter.html"
```

If Chrome isn't at that path, check `/Applications/Chromium.app` or ask the user where a Chromium-based browser is installed. Don't fall back to installing new software without asking first.

### 5. Verify

- Confirm the PDF was written and has a non-trivial size.
- Count `/URI` annotations in the raw PDF bytes and check it roughly matches the number of links embedded (mailto + each project link) — this confirms the links are actually clickable, not just styled text.

### 6. Save and report

Copy the PDF into the job folder, next to the source `.md`, using the same base filename (e.g. `Lettre de Motivation.md` → `Lettre de Motivation.pdf`). If a PDF with that name already exists, confirm with the user before overwriting.

Report: the PDF's path, page count, and number of clickable links embedded.

## Notes

- This skill targets the motivation letter only, not `cv.md` — the CV uses `[ICON]` placeholders meant for manual linking in Canva (see `Professional/CV/cv_format_spec.md`), a different layout (icons, multi-column skills) that this letter-style PDF isn't built for.
- Keep all factual claims (numbers, project names, links) exactly as written in the source `.md` — this skill only handles layout and link rendering, never content changes. If the letter and the job folder's `cv.md` disagree on a fact, flag it to the user instead of silently picking one.
