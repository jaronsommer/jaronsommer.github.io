# ════════════════════════════════════════════════════════════════════
# optimize-images.ps1
# ════════════════════════════════════════════════════════════════════
# Komprimiert Bilder in images/ via sharp-cli (npx).
#
# Nutzung:
#   .\optimize-images.ps1                 # alle Bilder in images/
#   .\optimize-images.ps1 images\foo.jpg  # einzelne Datei
#
# Was es macht:
#   - Resize auf max 800px Breite (keine Vergroesserung)
#   - JPEG: quality 80, mozjpeg encoder
#   - PNG:  quality 80-90, max compression
#   - Schreibt in-place (Git fungiert als Backup)
#
# Voraussetzungen:
#   - Node.js (Check: `node --version`)
#   - Erstmaliger Run laedt sharp via npx (~50MB, danach gecached)
# ════════════════════════════════════════════════════════════════════

param(
    [Parameter(Position=0, ValueFromRemainingArguments=$true)]
    [string[]]$Files
)

$ErrorActionPreference = 'Stop'
$MaxWidth = 800

if (-not (Get-Command npx -ErrorAction SilentlyContinue)) {
    Write-Error "npx nicht gefunden. Bitte Node.js installieren: https://nodejs.org"
    exit 1
}

# Wenn keine Dateien uebergeben: alle Bilder in images/
if (-not $Files -or $Files.Count -eq 0) {
    $Files = Get-ChildItem -Path images -File -Include *.jpg,*.jpeg,*.png -Recurse `
             | Select-Object -ExpandProperty FullName
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
