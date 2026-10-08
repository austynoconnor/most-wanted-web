param(
    [switch]$Analyze,
    [switch]$Regenerate,
    [switch]$Stub,
    [int]$Jobs = 8
)

$ErrorActionPreference = 'Stop'
$taskRoot = Split-Path -Parent $PSScriptRoot
$taskPython = Join-Path $taskRoot '.venv312/Scripts/python.exe'
$taskSdkEnvironment = Join-Path $taskRoot '.tools/emsdk/emsdk_env.ps1'
if (-not (Test-Path -LiteralPath $taskPython)) {
    throw 'Create a Python 3.12 environment at .venv312 and install kit/requirements-dev.txt.'
}
if (-not (Test-Path -LiteralPath $taskSdkEnvironment)) {
    throw 'Install and activate Emscripten in .tools/emsdk. See docs/local-setup.md.'
}
if ($Stub -and ($Analyze -or $Regenerate)) {
    throw 'A runtime-only build cannot analyze or regenerate game code.'
}
if ($Jobs -lt 1) { throw 'Jobs must be positive.' }

Push-Location $taskRoot
try {
    $env:EMSDK_QUIET = '1'
    & $taskSdkEnvironment
    $env:PATH = "$(Join-Path $taskRoot '.venv312/Scripts');$env:PATH"
    if (-not $Stub) {
        & $taskPython tools/setup.py --install original/retail --link-only
        if ($LASTEXITCODE -ne 0) { throw 'Game input validation failed.' }
        $taskSummary = Join-Path $taskRoot 'analysis/decompiled/speed.exe/summary.txt'
        if ($Analyze -or -not (Test-Path -LiteralPath $taskSummary)) {
            $taskGhidra = Join-Path $taskRoot '.tools/ghidra_12.1.3_PUBLIC'
            $taskJava = Join-Path $taskRoot '.tools/jdk-25.0.4.1+1'
            # Isolate Ghidra's settings from existing desktop installations.
            # This also avoids the observed Felix startup failure in the default cache.
            $env:GHIDRA_HEADLESS_JAVA_OPTIONS = "-Dapplication.settingsdir=$(Join-Path $taskRoot '.tools/ghidra-settings')"
            & $taskPython tools/analyze.py --ghidra-home $taskGhidra --java-home $taskJava
            if ($LASTEXITCODE -ne 0) { throw 'Executable analysis failed.' }
            $Regenerate = $true
        }
    }
    $taskArguments = @('tools/build.py', '--target', 'web', '--jobs', "$Jobs")
    if ($Stub) { $taskArguments += '--stub' }
    elseif ($Regenerate -or -not (Test-Path -LiteralPath 'build/recomp/gen/table.c')) {
        $taskArguments += @('--regenerate', '--allow-table-gaps', 'MSVC 7.1 switch shapes; see docs/analysis.md')
    }
    & $taskPython @taskArguments
    if ($LASTEXITCODE -ne 0) { throw 'Browser compilation failed.' }
} finally {
    Pop-Location
}
