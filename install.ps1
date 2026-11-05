# Token cheaping installer for Windows (Claude Code)
# Usage:  powershell -ExecutionPolicy Bypass -File .\install.ps1 [-NoGraphify]
# Safe to run again: it updates its own block and never removes your settings.

param([switch]$NoGraphify)

$ErrorActionPreference = "Stop"
$Repo      = Split-Path -Parent $MyInvocation.MyCommand.Path
$ClaudeDir = Join-Path $HOME ".claude"
$AgentsDir = Join-Path $ClaudeDir "agents"
$Utf8      = New-Object System.Text.UTF8Encoding $false
$Start     = "<!-- token-cheaping:start -->"
$End       = "<!-- token-cheaping:end -->"

function Say($msg)  { Write-Host "  $msg" }
function Ok($msg)   { Write-Host "  [ok] $msg" -ForegroundColor Green }
function Warn($msg) { Write-Host "  [!] $msg" -ForegroundColor Yellow }

Write-Host ""
Write-Host "Token cheaping - installing into $ClaudeDir" -ForegroundColor Cyan
New-Item -ItemType Directory -Force -Path $AgentsDir | Out-Null

# 1. Subagents
Get-ChildItem (Join-Path $Repo "global\agents") -Filter *.md | ForEach-Object {
    Copy-Item $_.FullName (Join-Path $AgentsDir $_.Name) -Force
    Ok "subagent $($_.BaseName)"
}

# 2. Global CLAUDE.md: insert or replace our block, keep everything else
$ClaudeMd = Join-Path $ClaudeDir "CLAUDE.md"
$Block = $Start + "`n" + ([IO.File]::ReadAllText((Join-Path $Repo "global\CLAUDE.md"))).Trim() + "`n" + $End
$Current = ""
if (Test-Path $ClaudeMd) { $Current = [IO.File]::ReadAllText($ClaudeMd) }
$i = $Current.IndexOf($Start); $j = $Current.IndexOf($End)
if ($i -ge 0 -and $j -gt $i) {
    $New = $Current.Substring(0, $i) + $Block + $Current.Substring($j + $End.Length)
} elseif ($Current.Trim().Length -gt 0) {
    $New = $Current.TrimEnd() + "`n`n" + $Block + "`n"
} else {
    $New = $Block + "`n"
}
[IO.File]::WriteAllText($ClaudeMd, $New, $Utf8)
Ok "rules added to CLAUDE.md (your existing content is kept)"

# 3. settings.json: merge deny rules, keep everything else
$Settings = Join-Path $ClaudeDir "settings.json"
$Rules = [IO.File]::ReadAllText((Join-Path $Repo "global\deny-rules.json")) | ConvertFrom-Json
try {
    if (Test-Path $Settings) {
        $Raw = [IO.File]::ReadAllText($Settings)
        if ($Raw.Trim().Length -eq 0) { $Raw = "{}" }
        $Json = $Raw | ConvertFrom-Json
        Copy-Item $Settings "$Settings.bak" -Force
    } else {
        $Json = New-Object PSObject
    }
    if (-not $Json.PSObject.Properties["permissions"]) {
        $Json | Add-Member -NotePropertyName permissions -NotePropertyValue (New-Object PSObject)
    }
    if (-not $Json.permissions.PSObject.Properties["deny"]) {
        $Json.permissions | Add-Member -NotePropertyName deny -NotePropertyValue @()
    }
    $Deny = @($Json.permissions.deny)
    $Added = 0
    foreach ($r in $Rules) { if ($Deny -notcontains $r) { $Deny += $r; $Added++ } }
    $Json.permissions.deny = $Deny
    [IO.File]::WriteAllText($Settings, ($Json | ConvertTo-Json -Depth 50), $Utf8)
    Ok "settings.json: $Added deny rules added (backup: settings.json.bak)"
} catch {
    Warn "Could not read settings.json (it may contain comments). Nothing was changed."
    Warn "Add the rules from global\deny-rules.json to permissions.deny by hand."
}

# 4. graphify (optional)
if ($NoGraphify) {
    Say "graphify skipped (-NoGraphify)"
} else {
    $HasGraphify = [bool](Get-Command graphify -ErrorAction SilentlyContinue)
    if (-not $HasGraphify) {
        Say "installing graphify (PyPI package: graphifyy)..."
        try {
            if (Get-Command uv -ErrorAction SilentlyContinue)        { uv tool install graphifyy }
            elseif (Get-Command pipx -ErrorAction SilentlyContinue)  { pipx install graphifyy }
            elseif (Get-Command py -ErrorAction SilentlyContinue)    { py -m pip install --user graphifyy }
            elseif (Get-Command python -ErrorAction SilentlyContinue){ python -m pip install --user graphifyy }
            else { throw "Python 3.10+ not found" }
            $HasGraphify = [bool](Get-Command graphify -ErrorAction SilentlyContinue)
            if (-not $HasGraphify) {
                # pip --user puts graphify.exe in a Scripts folder that is often not on PATH
                $PyCmd = if (Get-Command py -ErrorAction SilentlyContinue) { "py" } else { "python" }
                $ScriptsDir = (& $PyCmd -c "import sysconfig; print(sysconfig.get_path('scripts', 'nt_user'))").Trim()
                if ($ScriptsDir -and (Test-Path (Join-Path $ScriptsDir "graphify.exe"))) {
                    $UserPath = [Environment]::GetEnvironmentVariable("Path", "User")
                    if (-not $UserPath) { $UserPath = "" }
                    if (($UserPath -split ";") -notcontains $ScriptsDir) {
                        [Environment]::SetEnvironmentVariable("Path", ($UserPath.TrimEnd(";") + ";" + $ScriptsDir).TrimStart(";"), "User")
                        Ok "added $ScriptsDir to your PATH"
                    }
                    $env:Path += ";" + $ScriptsDir
                    $HasGraphify = [bool](Get-Command graphify -ErrorAction SilentlyContinue)
                }
            }
        } catch { Warn "graphify install failed: $_" }
    }
    if ($HasGraphify) {
        graphify install --platform windows
        Ok "graphify installed (/graphify skill registered)"
    } else {
        Warn "graphify not available yet. Install Python 3.10+, then run:"
        Warn "  pip install graphifyy ; graphify install --platform windows"
        Warn "(if 'graphify' is not found, open a new terminal so PATH refreshes)"
    }
}

Write-Host ""
Write-Host "Done. Next, in each project:" -ForegroundColor Cyan
Say "1. graphify claude install     (adds graphify rules to the project's CLAUDE.md)"
Say "2. In Claude Code: /graphify . (builds the graph once)"
Say "3. In Claude Code: /mcp        (turn off connectors the project does not use)"
Say "4. Restart VS Code / Claude Code completely so it picks up the new PATH and rules."
Write-Host ""
