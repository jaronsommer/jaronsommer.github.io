[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$OutputEncoding = [System.Text.UTF8Encoding]::new($false)

# ════════════════════════════════════════════════════════════════════
# Claude Code PostToolUse Hook
# ════════════════════════════════════════════════════════════════════
# Fires after Edit/Write/MultiEdit. Outputs JSON with system reminders.
# Three checks:
#   1) README-Reminder: did the edit change a non-README/non-.claude file?
#      → reminds Claude to check if README needs updating
#   2) Image-Size-Reminder: are there images/ files exceeding 150KB?
#      → reminds Claude to run optimize-images.ps1
#   3) SEO-Reminder: did the edit change an .html file (Inhalt)?
#      → reminds Claude to check sitemap.xml <lastmod> + robots.txt/sitemap
# All reminders accumulate; output combined.
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

# ── Check 3: SEO-Reminder (sitemap/robots aktuell halten) ─
# Feuert wenn eine .html-Datei geaendert wurde (Inhalt aendert sich
# → sitemap <lastmod> sollte aufs Aenderungsdatum gesetzt werden;
#   neue .html-Seiten muessen zusaetzlich in sitemap.xml als <url> rein).
# robots.txt/sitemap.xml-Edits selbst loesen den Reminder NICHT aus.
if ($path -and $path -match '\.html$') {
    $reminders += 'Hinweis SEO: Eine HTML-Datei wurde geaendert. Pruefe (1) sitemap.xml: <lastmod> auf das heutige Datum (YYYY-MM-DD) setzen, und falls eine NEUE .html-Seite hinzugekommen ist, sie als zusaetzlichen <url>-Eintrag aufnehmen; (2) robots.txt: nur anpassen, falls neue Pfade aus-/eingeschlossen werden sollen. Wenn beide bereits aktuell sind, einfach weitermachen.'
}

if ($reminders.Count -eq 0) { exit 0 }

$payload = @{
    hookSpecificOutput = @{
        hookEventName = 'PostToolUse'
        additionalContext = ($reminders -join "`n`n")
    }
} | ConvertTo-Json -Compress -Depth 4
Write-Output $payload
