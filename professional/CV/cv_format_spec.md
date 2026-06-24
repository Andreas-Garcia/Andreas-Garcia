# CV Content Format Specification

## PROCESS

Given a job description in `professional/CV/Jobs/[job title]/` (typically `Job Description.md`, or `Description.txt` if used), follow the formats below to generate:

1. **cv.md** - Contains:
   - Intro section (following INTRO SECTION format)
   - Skills section (following SKILLS SECTION format)
   - Job experiences section (following JOB EXPERIENCES SECTION format, max 3 experiences from README.md)
   - More info section (following MORE INFO SECTION format)

2. **motivation_letter.md** - Contains:
   - A tailored motivation letter (following MOTIVATION LETTER TEMPLATE format)
   - Must reference specific requirements from the job description
   - Must connect experiences from README.md to job requirements

3. **Validation step** - After generating cv.md:
   - Verify that all mentions of projects in the intro section and job experiences section have links in parentheses (format: `ProjectName (https://url.com)`)
   - Verify that all bullet points in the job experiences section are approximately 95 characters in length (excluding project links in parentheses)
   - Verify that the intro section is between 570 and 580 characters in length (excluding all project links in parentheses) and consists of 2 paragraphs
   - **Important:** Project links in parentheses do not count toward character limits for validation purposes
   - Adjust any bullet points or intro section that do not meet these requirements

Both files should be created in the same directory as the job description: `professional/CV/Jobs/[job title]/`

**CV portability (cv.md):** Do not name the employer, their products, programmes, or brands as written in the job description. Tailor the CV using domains, stacks, and outcomes from **README.md** only; the motivation letter is where the organisation and role can be named explicitly.

**Source of truth:** All job experiences, projects, achievements, and skills should be referenced from `README.md` in the repository root.

**Ecosystem name:** The music metadata ecosystem is **TheMusicTree**. **Primary link (portfolio):** https://themusictree.org. Use **TheMusicTree** in CV copy; prefer that URL for the venture; open-source repos are under the GitHub organization whose login is **BehindTheMusicTree** (used only inside URLs); refer to it as **TheMusicTree** in prose when mentioning the org or its code.

**Language:** The output language (for both cv.md and motivation_letter.md) must match the language of the job description. If the job description is in French, output in French. If in English, output in English.

**Writing style:** Avoid overusing the words "expert" or "expertise". Use alternative phrasing such as "experienced in", "skilled in", "proficient with", or describe specific achievements and capabilities instead.

**Links formatting:** Do not include markdown links in the text (e.g., `[text](url)`). Instead, use `[ICON]` as a placeholder where an icon should be placed (you will add the icon manually in Canva). List all links separately at the end of the document or after the relevant section in the format: `Project/Company Name: https://url.com`. This allows you to manually link the icon to the URL in Canva.

## INTRO SECTION

Format:

- Opening line with title/role tags
- 2 paragraphs about your professional identity
- Optional: Brief mention of key achievements

**Important:** The intro section should be between 570 and 580 characters in length (excluding project links in parentheses). **All mentions of projects must include a link in parentheses** (format: `ProjectName (https://url.com)`). **Multiple projects can be mentioned, but only one link per project should be included** (priority order: website > PyPI > GitHub). The character count should be verified excluding all links in parentheses. Use real, flowing sentences, not fragmented bullet-style text.

**Best practice:** Write both paragraphs as full, narrative sentences with clear subject and verb (e.g. "Je construis…", "J'ai travaillé…"). Avoid a telegram-style or list-like second paragraph (e.g. chaining noun phrases or fragments separated only by periods). Prefer 1–2 complete sentences per paragraph that tell a short narrative.

Example:
Results-oriented Engineering Executive with a proven track record of optimizing project outcomes. Skilled in strategic project management and team leadership.

Seeking a challenging executive role to leverage technical skills and drive engineering excellence. Experienced in leading cross-functional teams and delivering complex projects on time and within budget.

## SKILLS SECTION

Format:

- **Techniques:** List technical skills relevant to the job description (e.g., Javascript, React, Next.js, Python, Django DRF, RESTful API, SGBD, CI/CD). **Maximum 9 keywords.**
- **Workflow:** List project/process skills relevant to the job description (e.g., GitFlow, Test Driven Development, Assurance Qualité, Agile/SCRUM). **Maximum 9 keywords.**

**Important:** Skills should be selected based on relevance to the job description and should reference skills from README.md. The language should match the job description language (French or English).

**Terminology:** Use **GitFlow** (one word), not "Git Flow". For the GitHub workflow, use **GitHub Flow** if needed.

Example:

Techniques: Javascript, React, Next.js, Python, Django DRF, RESTful API, SGBD, CI/CD

Workflow: GitFlow, Test Driven Development, Assurance Qualité, Agile/SCRUM

## JOB EXPERIENCES SECTION

3 job experiences max.

**Note:** Job experiences should be selected from those listed in the README.md file under the "Professional Experience" section **based on relevance to the job description**. **Experiences must always be listed in reverse chronological order (most recent first)**.

Format:

- `[ICON]` Company/Project Name - Role Title (use `[ICON]` placeholder instead of markdown links)
- Date Range (e.g., "Dec. 2021 – Present")
- 2-3 bullet points describing:
  - Key responsibilities
  - Technical achievements
  - Impact/Results (with metrics when possible)
  - Technologies used (if relevant)

**Important:** Do not use "-" as a bullet point marker. Write bullet points as plain text sentences without any bullet markers.

**Project links:** **All mentions of specific projects** (e.g., AudioMeta Python, AudioMeta Webapp, TheMusicTreeAPI, OpenSILEX, GrowTheMusicTree) **must include the project link(s) in parentheses immediately after the project name**: `ProjectName (https://url.com)`. Priority order for links: website > PyPI > GitHub. **Note:** Links in parentheses do not count toward the character limit. **Multiple project links with icon placeholders are allowed in the job experiences section.**

**Available links (first priority):** Use these URLs when mentioning the following projects (override GitHub/repo links). Mention systematically that they are wip:

- **AudioMeta Webapp:** https://themusictree.org/projects/audiometa-webapp (portfolio page) or https://audiometa.themusictree.org/ (live app). **Next.js on Vercel.**
- **GrowTheMusicTree:** https://grow.themusictree.org/ (wip). **Next.js on Vercel.**
- **Portfolio / marketing site:** https://themusictree.org/ — **Next.js on Vercel** (when relevant).
- **HearTheMusicTree:** https://hear-api.themusictree.org/docs/ (wip)

**Links:** After the job experiences section, include a "Links" subsection listing all URLs in the format: `Project/Company Name: https://url.com`

**Important:** Each bullet point sentence should be approximately 95 characters in length (excluding project links in parentheses).

Example:

### [ICON] Company Name - Role Title

Dec. 2021 – Present

Implemented cost-effective solutions, resulting in a 20% reduction in project expenses.
Streamlined project workflows, enhancing overall efficiency by 25%.
Led a team in successfully delivering a complex engineering project on time and within allocated budget.

**Links:**
Company Name: https://example.com

## MORE INFO SECTION

[Describe what additional information should be included]
Example format:

- Technical stack (grouped by Backend/Frontend/Database/DevOps)
- Education
- Languages
- Open to: [opportunities]

## MOTIVATION LETTER TEMPLATE

**Note:** Motivation letters should be tailored to each job application, referencing specific requirements from the job description and connecting them to experiences from the README.md file.

### Structure:

**Paragraph 1: Opening & Interest**

- Express genuine interest in the position and company
- Mention how you discovered the opportunity
- Briefly state why this role aligns with your career goals

**Paragraph 2: Relevant Experience & Skills**

- Reference 2-3 key requirements from the job description
- Connect them to specific experiences from your README (projects, roles, achievements)
- Highlight technical skills and methodologies that match the role
- Include metrics/quantifiable results when possible

**Paragraph 3: Cultural Fit & Values**

- Reference your impact areas (Environmental, Social, Cultural) from the README
- Show alignment with company values/mission (if mentioned in job description)
- Mention relevant soft skills or approaches (e.g., open-source contributions, community focus)

**Paragraph 4: Closing**

- Reiterate enthusiasm for the role
- Express willingness to discuss further
- Professional closing

### Key Guidelines:

- **Length:** 3-4 paragraphs, concise and focused
- **Tone:** Professional, enthusiastic, authentic
- **Customization:** Must reference specific job requirements and company context
- **Evidence:** Always back claims with concrete examples from README
- **Connection:** Link technical skills to business impact

### Example Opening:

"I am writing to express my strong interest in the [Position Title] role at [Company Name]. With [X years] of experience in [relevant field] and a proven track record in [key area from job description], I am excited about the opportunity to contribute to [specific company goal/project mentioned in job description]."

### Example Experience Connection:

"Your requirement for [specific skill/technology from job description] aligns perfectly with my experience developing [project name from README], where I [specific achievement with metrics]. This project demonstrates my ability to [relevant capability] while maintaining [quality standard/methodology]."
