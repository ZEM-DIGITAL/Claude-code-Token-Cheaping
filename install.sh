#!/usr/bin/env bash
# Token cheaping installer for macOS / Linux (Claude Code)
# Usage:  ./install.sh [--no-graphify]
# Safe to run again: it updates its own block and never removes your settings.
set -euo pipefail

REPO="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
NO_GRAPHIFY=0
[ "${1:-}" = "--no-graphify" ] && NO_GRAPHIFY=1

ok()   { printf '  \033[32m[ok]\033[0m %s\n' "$1"; }
warn() { printf '  \033[33m[!]\033[0m %s\n' "$1"; }

PY=""
for c in python3 python; do command -v "$c" >/dev/null 2>&1 && { PY="$c"; break; }; done

echo
echo "Token cheaping - installing into $CLAUDE_DIR"
mkdir -p "$CLAUDE_DIR/agents"

# 1. Subagents
for f in "$REPO"/global/agents/*.md; do
  cp "$f" "$CLAUDE_DIR/agents/"
  ok "subagent $(basename "$f" .md)"
done

if [ -z "$PY" ]; then
  warn "Python not found: copy global/CLAUDE.md and global/deny-rules.json by hand."
else
  # 2 + 3. CLAUDE.md block and settings.json deny rules
  "$PY" - "$REPO" "$CLAUDE_DIR" <<'PYEOF'
import json, os, shutil, sys
repo, cdir = sys.argv[1], sys.argv[2]
S, E = "<!-- token-cheaping:start -->", "<!-- token-cheaping:end -->"

md = os.path.join(cdir, "CLAUDE.md")
block = S + "\n" + open(os.path.join(repo, "global", "CLAUDE.md"), encoding="utf-8").read().strip() + "\n" + E
cur = open(md, encoding="utf-8").read() if os.path.exists(md) else ""
i, j = cur.find(S), cur.find(E)
if i >= 0 and j > i:
    new = cur[:i] + block + cur[j + len(E):]
elif cur.strip():
    new = cur.rstrip() + "\n\n" + block + "\n"
else:
    new = block + "\n"
open(md, "w", encoding="utf-8").write(new)
print("  [ok] rules added to CLAUDE.md (your existing content is kept)")

st = os.path.join(cdir, "settings.json")
rules = json.load(open(os.path.join(repo, "global", "deny-rules.json"), encoding="utf-8"))
try:
    data = {}
    if os.path.exists(st):
        raw = open(st, encoding="utf-8-sig").read()
        data = json.loads(raw) if raw.strip() else {}
        shutil.copy(st, st + ".bak")
    deny = data.setdefault("permissions", {}).setdefault("deny", [])
    added = [r for r in rules if r not in deny]
    deny.extend(added)
    open(st, "w", encoding="utf-8").write(json.dumps(data, indent=2, ensure_ascii=False) + "\n")
    print(f"  [ok] settings.json: {len(added)} deny rules added (backup: settings.json.bak)")
except ValueError:
    print("  [!] Could not read settings.json (it may contain comments). Nothing was changed.")
    print("  [!] Add the rules from global/deny-rules.json to permissions.deny by hand.")
PYEOF
fi

# 4. graphify (optional)
if [ "$NO_GRAPHIFY" = 1 ]; then
  echo "  graphify skipped (--no-graphify)"
else
  if ! command -v graphify >/dev/null 2>&1; then
    echo "  installing graphify (PyPI package: graphifyy)..."
    if command -v uv >/dev/null 2>&1; then uv tool install graphifyy || true
    elif command -v pipx >/dev/null 2>&1; then pipx install graphifyy || true
    elif [ -n "$PY" ]; then "$PY" -m pip install --user graphifyy || true
    fi
  fi
  if command -v graphify >/dev/null 2>&1; then
    graphify install && ok "graphify installed (/graphify skill registered)"
  else
    warn "graphify not available yet. Install Python 3.10+, then run:"
    warn "  pip install graphifyy && graphify install"
    warn "(if 'graphify' is not found, open a new terminal so PATH refreshes)"
  fi
fi

echo
echo "Done. Next, in each project:"
echo "  1. graphify claude install     (adds graphify rules to the project's CLAUDE.md)"
echo "  2. In Claude Code: /graphify . (builds the graph once)"
echo "  3. In Claude Code: /mcp        (turn off connectors the project does not use)"
echo "  4. Start a new Claude Code conversation so the changes load."
echo
