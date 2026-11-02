---
name: letter-to-pdf
description: Render an existing job application motivation letter as a print-ready PDF with clickable links, preserving its contents.
---

# Render a motivation letter

Resolve the supplied job folder under `Professional/CV/Jobs/` or
`professional/CV/Jobs/`, or the supplied letter path. Read the letter, the job description, and the root `README.md` for
sender contact details. Never invent missing contact details. This workflow is
for letters, not the differently formatted CV. Preserve factual claims and flag
any disagreement with the corresponding CV.

Create a self-contained HTML file in a temporary directory. Use a top-right
sender block (name, phone, mailto link), a French date line in Névez, a bold
object line naming the role and company, the letter's paragraphs, and a
professional sign-off. Use a neutral greeting unless the recruiter is clearly
identified. Render project links as clickable project names without visible raw
URLs. Use a clean sans-serif font around 11.5 pt, justified body, 1.5 line
spacing, A4 with margins of 2.5 cm vertically and 3 cm horizontally, and
underlined links in the text color.

Render the HTML to PDF with an available headless Chrome or Chromium, disabling
printed headers and footers. Do not install software without the user's
approval. Verify the page count and rendered pages, and inspect the PDF's link
annotations to confirm the mailto and project links remain clickable. Save the
PDF beside the source letter using the same base filename; obtain confirmation
before replacing an existing PDF. Report the path, page count, and link count.
