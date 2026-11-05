# Claude Code Token Cheaping

**Claude Code config to reduce token usage and stop hitting usage limits.** Token cheaping is the opposite of tokenmaxxing: CLAUDE.md rules, subagents with model routing (Haiku / Sonnet / Opus), context engineering, deny rules and [graphify](https://graphify.com). Make your Claude plan last longer. One-command install.

[English](#english) · [Español](#español)

---

## English

### What it does

| Technique | What it saves |
|---|---|
| **Model routing** | Nine global subagents with a routing table: Haiku for mechanical work, git and running tests (`quick`, `git-ops`, `runner`); Sonnet for code, web design, writing/SEO, scraping and automations (`implementer`, `web-designer`, `writer`, `scraper`, `automation`); Opus only for architecture (`architect`). |
| **Clarify first** | On vague bug reports, Claude asks *where* and *what you see* before reading any file, instead of exploring blindly. |
| **Context hygiene** | Claude tells you when to run `/clear` (new task) or `/compact` (long task), because every message re-sends the whole conversation. |
| **Deny rules** | Claude never reads `node_modules`, `dist`, virtualenvs, databases, `.env` files, certificates or the raw graphify graph. Saves tokens *and* protects secrets. |
| **graphify** | Claude queries a knowledge graph of your code instead of reading whole files. |

Everything goes into your user folder (`~/.claude`), so it applies to **all your projects**. The installer **merges** with your existing setup: it never deletes your settings or your own CLAUDE.md content, and it is safe to run again.

### Requirements

- [Claude Code](https://docs.claude.com) (terminal, VS Code or the desktop app)
- Python 3.10+ for graphify (optional; use `--no-graphify` to skip it)

### Install

**Windows (PowerShell)**

```powershell
git clone https://github.com/YOUR_USER/claude-code-token-cheaping
cd claude-code-token-cheaping
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

**macOS / Linux**

```bash
git clone https://github.com/YOUR_USER/claude-code-token-cheaping
cd claude-code-token-cheaping
chmod +x install.sh && ./install.sh
```

Add `-NoGraphify` (Windows) or `--no-graphify` (macOS/Linux) to skip graphify.

### Then, in each project

1. `graphify claude install` inside the project folder (adds graphify rules to its CLAUDE.md).
2. In Claude Code, type `/graphify .` once to build the graph.
3. Type `/mcp` and turn off connectors the project does not use.
4. Optional: copy `templates/CLAUDE.project.md` as the project's `CLAUDE.md` and fill in two lines about it.
5. Start a new conversation and check with `/context`.

### Recommended base model

Set `"model": "sonnet"` in `~/.claude/settings.json`. Opus is then used only through `architect`, or with `/model opus` for a hard task.

### Daily habits

- New task → `/clear`
- Same task, long conversation → `/compact keep <what matters>`
- Be specific: "the total doesn't update after removing an item on the table screen" beats "there's a bug".
- Force a cheaper model when you want: "use `quick` to format this file".

### Update

```bash
git pull
# then run the installer again
```

### Uninstall

Delete the agent files listed in `global/agents/` from `~/.claude/agents/`, remove the block between `<!-- token-cheaping:start -->` and `<!-- token-cheaping:end -->` in `~/.claude/CLAUDE.md`, and restore `~/.claude/settings.json.bak` if you want your previous settings back.

### How much does it save?

It depends on how you work today. Measure it: note your plan usage for a week before and a week after. Pull requests with real numbers are welcome.

---

## Español

### Qué hace

| Técnica | Qué ahorra |
|---|---|
| **Enrutado de modelos** | Nueve subagentes globales con una tabla de reparto: Haiku para tareas mecánicas, git y tests (`quick`, `git-ops`, `runner`); Sonnet para código, diseño web, artículos/SEO, scraping y automatizaciones (`implementer`, `web-designer`, `writer`, `scraper`, `automation`); Opus solo para arquitectura (`architect`). |
| **Preguntar primero** | Ante un bug vago, Claude pregunta *dónde* y *qué ves* antes de leer archivos, en vez de explorar a ciegas. |
| **Higiene de contexto** | Claude te avisa de cuándo hacer `/clear` (tarea nueva) o `/compact` (tarea larga), porque cada mensaje reenvía toda la conversación. |
| **Reglas de bloqueo** | Claude no lee `node_modules`, `dist`, entornos virtuales, bases de datos, `.env`, certificados ni el grafo en bruto de graphify. Ahorra tokens *y* protege secretos. |
| **graphify** | Claude consulta un grafo de tu código en vez de leer archivos enteros. |

Todo se instala en tu carpeta de usuario (`~/.claude`), así que vale para **todos tus proyectos**. El instalador **fusiona** con tu configuración: no borra tus ajustes ni lo que ya tengas en tu CLAUDE.md, y puedes ejecutarlo varias veces.

### Instalar

**Windows (PowerShell)**

```powershell
git clone https://github.com/TU_USUARIO/claude-code-token-cheaping
cd claude-code-token-cheaping
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

**macOS / Linux**

```bash
git clone https://github.com/TU_USUARIO/claude-code-token-cheaping
cd claude-code-token-cheaping
chmod +x install.sh && ./install.sh
```

Añade `-NoGraphify` (Windows) o `--no-graphify` (macOS/Linux) para no instalar graphify.

### Después, en cada proyecto

1. `graphify claude install` dentro de la carpeta del proyecto.
2. En Claude Code, escribe `/graphify .` una vez para crear el grafo.
3. Escribe `/mcp` y desactiva los conectores que el proyecto no use.
4. Opcional: copia `templates/CLAUDE.project.md` como `CLAUDE.md` del proyecto y describe el proyecto en dos líneas.
5. Abre una conversación nueva y compruébalo con `/context`.

### Hábitos

- Tarea nueva → `/clear`
- Misma tarea, conversación larga → `/compact conserva <lo importante>`
- Sé concreto en lo que pides.
- Fuerza un modelo barato cuando quieras: «usa `quick` para formatear este archivo».

---

## Credits

- [graphify](https://graphify.com) (Apache-2.0) is a separate project; this repo only installs it and does not include its code.
- Made by Zakaria Enzo Mouedden (@Zakariaenzo_). MIT License.
