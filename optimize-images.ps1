# ════════════════════════════════════════════════════════════════════
# optimize-images.ps1
# ════════════════════════════════════════════════════════════════════
# Komprimiert Bilder in images/ via sharp-cli (npx).
#
# Nutzung:
#   .\optimize-images.ps1                 # nur uncommitted Bilder (neu + modified)
#   .\optimize-images.ps1 -All            # alle Bilder in images/ (auch committed)
#   .\optimize-images.ps1 images\foo.jpg  # einzelne Datei (bypasst git-Check)
#
# Default-Verhalten: schlaegt nur an, was git als neu oder modifiziert listet.
# Bereits committete + unveraenderte Bilder werden ignoriert (keine doppelte
# Arbeit, kein npx-Spawn). Mit -All kann das uebersteuert werden.
#
# Was es macht:
#   - Resize auf max 800px Breite (keine Vergroesserung)
#   - JPEG: quality 80, mozjpeg encoder
#   - PNG:  quality 80-90, max compression, palette
#   - Schreibt in-place (Git fungiert als Backup)
#
# Voraussetzungen:
#   - Node.js (Check: `node --version`)
#   - Erstmaliger Run laedt sharp via npx (~50MB, danach gecached)
# ════════════════════════════════════════════════════════════════════

param(
    [Parameter(Position=0, ValueFromRemainingArguments=$true)]
    [string[]]$Files,
    [switch]$All
)

$ErrorActionPreference = 'Stop'
$MaxWidth = 800

if (-not (Get-Command npx -ErrorAction SilentlyContinue)) {
    Write-Error "npx nicht gefunden. Bitte Node.js installieren: https://nodejs.org"
    exit 1
}

# Wenn keine Dateien uebergeben → Default-Quelle ermitteln
if (-not $Files -or $Files.Count -eq 0) {
    if ($All) {
        # Override: alle Bilder
        $Files = Get-ChildItem -Path images -File -Include *.jpg,*.jpeg,*.png -Recurse `
                 | Select-Object -ExpandProperty FullName
    } elseif (Get-Command git -ErrorAction SilentlyContinue) {
        # Standard: nur uncommitted Bilder via git status
        # Format: "XY filename" (X=staged, Y=unstaged, '??'=untracked)
        $Files = @()
        $statusLines = & git status --porcelain -- images/ 2>$null
        foreach ($line in $statusLines) {
            if ($line.Length -lt 4) { continue }
            $xy = $line.Substring(0, 2)
            $rel = $line.Substring(3).Trim()
            # Skip Deletes / Renames (eine umgezogene Datei zaehlt nicht als zu komprimieren)
            if ($xy -match '[DR]') { continue }
            if ($rel -match '\.(jpe?g|png)$') {
                $Files += $rel
            }
        }
        if ($Files.Count -eq 0) {
            Write-Output "Keine uncommitted Bilder in images/. Nichts zu tun."
            Write-Output "(Fuer alle Bilder: .\optimize-images.ps1 -All)"
            exit 0
        }
        Write-Host "Gefundene uncommitted Bilder: $($Files.Count)" -ForegroundColor Cyan
    } else {
        # Fallback ohne git -> wie -All
        Write-Warning "git nicht gefunden - verarbeite alle Bilder"
        $Files = Get-ChildItem -Path images -File -Include *.jpg,*.jpeg,*.png -Recurse `
                 | Select-Object -ExpandProperty FullName
    }
}

if (-not $Files -or $Files.Count -eq 0) {
    Write-Output "Keine Bilder gefunden."
    exit 0
}

$totalBefore = 0
$totalAfter = 0
$results = @()

foreach ($file in $Files) {
    if (-not (Test-Path $file)) {
        Write-Warning "Skip (nicht gefunden): $file"
        continue
    }

    # sharp-cli mag relative Pfade mit Backslash nicht zuverlaessig
    # → immer in absoluten Pfad aufloesen
    $file = (Resolve-Path $file).Path
    $item = Get-Item $file
    $ext = $item.Extension.ToLower()
    $sizeBefore = $item.Length
    $tmp = Join-Path $env:TEMP ("opt-" + [guid]::NewGuid().ToString() + $ext)

    Write-Host "Optimiere $($item.Name) ($sizeBefore bytes)..." -NoNewline

    # Format-spezifische Optionen sind GLOBALE Flags in sharp-cli (nicht Subcommands).
    # Hinweis: --input/--output muessen LONG form sein (-i/-o funktioniert nicht zuverlaessig auf Windows)
    try {
        if ($ext -in '.jpg', '.jpeg') {
            & npx -y sharp-cli --input $file --output $tmp `
                --format jpeg --quality 80 --mozjpeg `
                resize $MaxWidth 2>$null | Out-Null
        } elseif ($ext -eq '.png') {
            & npx -y sharp-cli --input $file --output $tmp `
                --format png --quality 85 --compressionLevel 9 --palette `
                resize $MaxWidth 2>$null | Out-Null
        } else {
            Write-Host " skip (unsupported $ext)"
            continue
        }
    } catch {
        Write-Host " FAIL: $_"
        continue
    }

    if (-not (Test-Path $tmp)) {
        Write-Host " FAIL: keine Ausgabe"
        continue
    }

    $sizeAfter = (Get-Item $tmp).Length

    # Nur uebernehmen wenn tatsaechlich kleiner
    if ($sizeAfter -lt $sizeBefore) {
        Move-Item -Path $tmp -Destination $file -Force
        $pct = [math]::Round((($sizeBefore - $sizeAfter) / $sizeBefore) * 100, 1)
        Write-Host " -> $sizeAfter bytes (-$pct%)"
        $totalBefore += $sizeBefore
        $totalAfter += $sizeAfter
        $results += [PSCustomObject]@{ File = $item.Name; Before = $sizeBefore; After = $sizeAfter; SavedPct = $pct }
    } else {
        Remove-Item $tmp
        Write-Host " skip (waere groesser)"
    }
}

if ($results.Count -gt 0) {
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════"
    $results | Format-Table -AutoSize
    $totalSavedPct = [math]::Round((($totalBefore - $totalAfter) / $totalBefore) * 100, 1)
    Write-Host ("Total: {0} -> {1} bytes (-{2}%)" -f $totalBefore, $totalAfter, $totalSavedPct)
}
