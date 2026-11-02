---
name: apply-job
description: Create a tailored CV and motivation letter for a job description using this portfolio's facts and format rules.
---

# Prepare a job application

Read `Professional/CV/AGENTS.md`, `professional/CV/cv_format_spec.md`,
`Professional/CV/emphasis_priorities.md`, and the root `README.md` before
writing. The format spec governs presentation, the priorities govern selection
subject to job relevance, and the README supplies facts. Do not invent facts.

Use the supplied job description to derive a company and role folder. Check
both `Professional/CV/Jobs/` and `professional/CV/Jobs/` for an existing
folder on case-sensitive systems; otherwise create it under
`Professional/CV/Jobs/`, following existing names. Save the description as
`Job Description.md`, then create `cv.md` and `motivation_letter.md` in the
same folder. Check for existing files before writing and preserve them unless
the user has requested their replacement. Match the description's language.

Apply the format spec in full, including its relevance, link, length and
portability rules; the motivation letter may name the company and role. Check
all requirements, including the intro and skills character limits and project
links. `professional/CV/validate_cv.py` uses obsolete length limits; do not
rely on its verdict until it is updated to match the spec. Report the intro
character count and the created files.
