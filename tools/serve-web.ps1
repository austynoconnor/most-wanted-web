param([int]$Port = 8000)

$ErrorActionPreference = 'Stop'
$taskRoot = Split-Path -Parent $PSScriptRoot
$taskPython = Join-Path $taskRoot '.venv312/Scripts/python.exe'
$taskSite = Join-Path $taskRoot 'build/web-site'
if (-not (Test-Path -LiteralPath (Join-Path $taskSite 'nfsmw/index.html'))) {
    throw 'Build the game with tools/build-web.ps1 before serving it.'
}
& $taskPython (Join-Path $taskRoot 'kit/tools/web_launcher.py') --game-dir $taskRoot --out $taskSite --asset-dir "nfsmw=$(Join-Path $taskRoot 'original/retail')" --serve $Port
if ($LASTEXITCODE -ne 0) { throw 'The browser server stopped with an error.' }
