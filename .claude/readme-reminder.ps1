[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$json = [Console]::In.ReadToEnd()
try {
    $obj = $json | ConvertFrom-Json
    $path = $obj.tool_input.file_path
} catch {
    exit 0
}
if (-not $path) { exit 0 }
if ($path -match 'README\.md$') { exit 0 }
if ($path -match '\.claude[\\/]') { exit 0 }
$payload = @{
    hookSpecificOutput = @{
        hookEventName = 'PostToolUse'
        additionalContext = 'Hinweis: Eine Projektdatei wurde geaendert. Pruefe, ob README.md aktualisiert werden muss, um die Aenderung widerzuspiegeln (z.B. neue Sektion, neue Datei, geaenderte Projektstruktur, neue Technologie). Falls der README inhaltlich noch passt, einfach weitermachen und dies dem Nutzer kurz mitteilen.'
    }
} | ConvertTo-Json -Compress -Depth 4
Write-Output $payload
