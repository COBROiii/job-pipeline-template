# CVs and project swaps

Keep as few CVs as you can; two works well (one specialist, one general). Save each as a PDF with a `.md` text copy next to it (ask Claude to make the `.md` from the PDF). Nothing else counts as a CV.

| CV | File | Used for (track IDs from config/criteria.md) |
|---|---|---|
| TODO e.g. "Your Name CV" (technical) | `cv/technical/<name>_CV.pdf` (text: `.md`) | TODO |
| TODO e.g. "Your Name CV - Other" | `cv/non-technical/<name>_CV_Other.pdf` (text: `.md`) | TODO |

## What's on each

| Project | CV 1 | CV 2 | Long-form source |
|---|---|---|---|
| TODO | ✓ | — | cv-points.md › TODO |

Optional: if `answer-bank/cv-points.md` is a copy of a Notion page, name the page here. When the Notion connector is available, Claude fetches the live page first.

## When to suggest a swap

| Role signal | CV | Suggested swap |
|---|---|---|
| TODO e.g. "role mentions data analysis" | TODO | TODO e.g. "swap project A → project B" |

## Rules
- The pipeline only **suggests** swaps, with the replacement bullets drafted from cv-points. You edit your CV and export the PDF yourself. Claude never uploads a CV you haven't exported and never edits the PDFs.
- Bullets: change as little as possible, keep your phrasing, one line each (~110 characters max).
- If you save a tailored PDF for a job, put it at `applications/jobs/<id>/cv.pdf`. It's uploaded instead of the default for that job only.
