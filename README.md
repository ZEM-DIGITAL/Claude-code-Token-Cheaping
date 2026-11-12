# Claude Code Token Cheaping

**Claude Code config to reduce token usage and stop hitting usage limits.** Token cheaping is the opposite of tokenmaxxing: CLAUDE.md rules, subagents with model routing (Haiku / Sonnet / Opus), context engineering, deny rules and [graphify](https://graphify.com). Make your Claude plan last longer. One-command install.

[English](#english) · [Español](#español)

## Measured results (Nov 2 vs Nov 9, 2026)

Comparison of two weeks of real Claude Code usage, tracked with `ccusage`, across 2 repos
(Music-saas and ZEM-TPV) on a single machine. The week of Nov 9 is partial (~4 days).
Cost is the API-equivalent price: actual usage is on a subscription plan, so the savings
translate into headroom under the daily and weekly limits, not into money saved.

| Metric | Week of Nov 2 | Week of Nov 9 | Change |
|---|---|---|---|
| Total equivalent cost | $138.75 | $41.48 | -70% |
| Total tokens | 329.4 M | 166.9 M | -49% |
| Cache read | 320.5 M | 159.6 M | -50% |
| Output tokens | 1.49 M | 1.00 M | -33% |
| Cost per million output tokens | ~$93 | ~$41 | **-55%** |
| Cost per commit | $5.34 | $2.18 | **-59%** |
| Cost per 1,000 lines added | $6.37 | $4.80 | **-25%** |
| Commits per day | ~3.7 | ~4.75 | +28% |
| Lines added per day | ~3,100 | ~2,160–2,470 | -20% to -30% |

**Final estimate:** for the same output, consumption drops between 25% and 59%
depending on the metric. The central figure is ~55%, which is roughly 2x the capacity
of the same plan.

**Limitations:**
- The savings coincide with a switch from Opus to Haiku and Sonnet. This data cannot
  separate how much is due to the configuration and how much to the model change.
- Data comes from a single machine. Other devices and projects are not included.
- Lines and commits are rough proxies for output, not for value.
- The week of Nov 9 is partial; the table will be updated with the full week.

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

**Estimated: around 50% less usage (range 40-60%)** if you currently use Opus for everything, and **20-35% less** if you already use Sonnet as your default.

These are estimates, not measurements. How we got them, using relative model prices (Haiku 1, Sonnet 3, Opus 5):

| Part of the work | Model | Share | Cost vs all-Opus |
|---|---|---|---|
| Architecture and hard bugs | Opus | ~10% | 0.10 |
| Code, design, writing, scraping, automations | Sonnet | ~65% | 0.39 |
| Git, tests, builds, small edits, research | Haiku | ~25% | 0.05 |
| **Total from model routing** | | | **~0.54 (46% less)** |

On top of that, clarify-first, deny rules and context hygiene (`/clear`, `/compact`) usually cut another 10-25% of what is left, and graphify reduces code reading further. That is where the ~50% comes from.

Your result depends on how much Claude actually delegates, how disciplined you are with `/clear`, and your plan's usage rules, which do not have to match API prices exactly. Measure it yourself: compare a normal week before and after (for example with `ccusage`). Pull requests with real numbers are welcome.

---

## Español

## Resultados medidos (2 nov vs 9 nov 2026)

Comparación de dos semanas de uso real de Claude Code con `ccusage`, en 2 repos
(Music-saas y ZEM-TPV) y un solo equipo. La semana del 9 nov es parcial (~4 días).
El coste es el equivalente a precio de API: el uso real es por suscripción, así que
el ahorro se traduce en margen bajo los límites diarios y semanales, no en dinero.

| Métrica | Sem. 2 nov | Sem. 9 nov | Cambio |
|---|---|---|---|
| Coste equivalente total | $138,75 | $41,48 | -70% |
| Tokens totales | 329,4 M | 166,9 M | -49% |
| Cache read | 320,5 M | 159,6 M | -50% |
| Tokens de salida | 1,49 M | 1,00 M | -33% |
| Coste por millón de tokens de salida | ~$93 | ~$41 | **-55%** |
| Coste por commit | $5,34 | $2,18 | **-59%** |
| Coste por 1.000 líneas añadidas | $6,37 | $4,80 | **-25%** |
| Commits por día | ~3,7 | ~4,75 | +28% |
| Líneas añadidas por día | ~3.100 | ~2.160–2.470 | -20% a -30% |

**Estimación final:** para el mismo output, el consumo baja entre un 25% y un 59%
según la métrica. La cifra central es ~55%.

**Limitaciones:**
- El ahorro coincide con el paso de Opus a haiku y sonnet. Con estos datos no se
  puede separar cuánto se debe a esa configuración y cuánto al cambio de modelo.
- Solo hay datos de un equipo. Faltan otros dispositivos y proyectos.
- Líneas y commits son indicadores aproximados de producción, no de valor.
- La semana del 9 nov es parcial; se actualizará con la semana completa.

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

### ¿Cuánto ahorra?

**Estimación: en torno a un 50% menos de consumo (entre 40% y 60%)** si ahora usas Opus para todo, y **un 20-35% menos** si ya usas Sonnet por defecto. Es una estimación, no una medición: el cálculo está en la sección en inglés. Depende de cuánto delegue Claude y de lo constante que seas con `/clear`. Mídelo tú comparando una semana normal antes y después.

### Hábitos

- Tarea nueva → `/clear`
- Misma tarea, conversación larga → `/compact conserva <lo importante>`
- Sé concreto en lo que pides.
- Fuerza un modelo barato cuando quieras: «usa `quick` para formatear este archivo».

---

## Credits

- [graphify](https://graphify.com) (Apache-2.0) is a separate project; this repo only installs it and does not include its code.
- Made by Zakaria Enzo Mouedden (@Zakariaenzo_). MIT License.
