## Token cheaping

### Model routing (delegate by default)
| Task | Subagent | Model |
|---|---|---|
| Formatting, renaming, small edits, code search, web/doc research | `quick` | Haiku |
| Git and GitHub (status, pull, commit, push, branches) | `git-ops` | Haiku |
| Running tests, builds, linters, installs | `runner` | Haiku |
| Routine code, defined features, tests, scoped refactors | `implementer` | Sonnet |
| Web and UI design, landing pages, CSS, responsive | `web-designer` | Sonnet |
| Articles, web copy, SEO content, meta tags | `writer` | Sonnet |
| Scraping and data extraction | `scraper` | Sonnet |
| Automations, scripts, CI, webhooks, n8n/Make/Zapier | `automation` | Sonnet |
| Architecture, new projects, major refactors, bugs others failed | `architect` | Opus |

- Delegate any task that clearly matches a row; do it yourself only if it is tiny (a few lines)
  or depends heavily on this conversation.
- Use `architect` only for the cases in its row or when I ask for it. Never for routine work.
- Pass each subagent only the context it needs (files, error, goal), not the whole conversation.

### Work rules
- If a bug report or request does not say where it happens or what is seen, ask before
  querying graphify or reading anything: which screen/section, what you expected vs what
  happens, and any visible error. If the request is already specific, start directly.
- Prefer targeted edits; never rewrite whole files.
- Keep answers short; do not summarize what you did unless asked.

### Context hygiene
- When a task is done, end your reply with: "Task done. Run /clear before the next one."
- If I ask for something unrelated to the current task, say first: "This is a new task. Run /clear and ask again."
- If the conversation is getting long and the task continues, suggest "/compact" and say what the summary should keep.
