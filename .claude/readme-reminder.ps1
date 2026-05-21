[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$OutputEncoding = [System.Text.UTF8Encoding]::new($false)

# ════════════════════════════════════════════════════════════════════
# Claude Code PostToolUse Hook
# ════════════════════════════════════════════════════════════════════
# Fires after Edit/Write/MultiEdit. Outputs JSON with system reminders.
# Two checks:
#   1) README-Reminder: did the edit change a non-README/non-.claude file?
#      → reminds Claude to check if README needs updating
#   2) Image-Size-Reminder: are there images/ files exceeding 150KB?
#      → reminds Claude to run optimize-images.ps1
# Both reminders accumulate; output combined.
# ════════════════════════════════════════════════════════════════════

$json = [Console]::In.ReadToEnd()
try {
    $obj = $json | ConvertFrom-Json
    $path = $obj.tool_input.file_path
} catch {
    exit 0
}

$reminders = @()

# ── Check 1: README-Reminder ─────────────────────────────
if ($path -and $path -notmatch 'README\.md$' -and $path -notmatch '\.claude[\\/]') {
    $reminders += 'Hinweis: Eine Projektdatei wurde geaendert. Pruefe, ob README.md aktualisiert werden muss, um die Aenderung widerzuspiegeln (z.B. neue Sektion, neue Datei, geaenderte Projektstruktur, neue Technologie). Falls der README inhaltlich noch passt, einfach weitermachen und dies dem Nutzer kurz mitteilen.'
}

# ── Check 2: Image-Size-Reminder ─────────────────────────
# Repo root = parent of .claude/
$repoRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$imagesDir = Join-Path $repoRoot 'images'
if (Test-Path $imagesDir) {
    $threshold = 150 * 1024  # 150 KB
    $oversized = Get-ChildItem $imagesDir -File -Recurse |
                 Where-Object { $_.Extension -match '\.(jpe?g|png)$' -and $_.Length -gt $threshold } |
                 Select-Object -First 5
    if ($oversized) {
        $list = ($oversized | ForEach-Object {
            $kb = [math]::Round($_.Length / 1024)
            "$($_.Name) (${kb} KB)"
        }) -join ', '
        $reminders += "Hinweis: Bilder ueber 150 KB in images/ entdeckt: $list. Bitte '.\optimize-images.ps1' ausfuehren (alle) oder gezielt mit Dateiname als Argument. Reduziert Mobile-Load fuer 3G-Nutzer."
    }
}

if ($reminders.Count -eq 0) { exit 0 }

$payload = @{
    hookSpecificOutput = @{
        hookEventName = 'PostToolUse'
        additionalContext = ($reminders -join "`n`n")
    }
} | ConvertTo-Json -Compress -Depth 4
Write-Output $payload
