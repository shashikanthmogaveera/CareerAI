# CareerAI - Start Script (PowerShell)
# Right-click → "Run with PowerShell"  OR  double-click after enabling PS scripts.

$ErrorActionPreference = "Stop"
$Host.UI.RawUI.WindowTitle = "CareerAI Launcher"

$ROOT = Split-Path -Parent $MyInvocation.MyCommand.Path

function Write-Banner {
    Write-Host ""
    Write-Host "  ╔══════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "  ║         CareerAI - Intelligent Career        ║" -ForegroundColor Cyan
    Write-Host "  ║              Guidance System                 ║" -ForegroundColor Cyan
    Write-Host "  ╚══════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
}

function Write-Step($n, $msg) {
    Write-Host "  [$n] $msg" -ForegroundColor Yellow
}

function Write-OK($msg)   { Write-Host "  ✓ $msg" -ForegroundColor Green }
function Write-Fail($msg) { Write-Host "  ✗ $msg" -ForegroundColor Red }
function Write-Info($msg) { Write-Host "  · $msg" -ForegroundColor Gray }

# ── Banner ────────────────────────────────────────────────────────────────────
Write-Banner
Write-Info "Project root: $ROOT"
Write-Host ""

# ── 1. Python ─────────────────────────────────────────────────────────────────
Write-Step "1/5" "Checking Python..."
try {
    $pyVer = & python --version 2>&1
    Write-OK $pyVer
} catch {
    Write-Fail "Python not found. Download from https://www.python.org/downloads/"
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Host ""

# ── 2. Node.js ────────────────────────────────────────────────────────────────
Write-Step "2/5" "Checking Node.js..."
try {
    $nodeVer = & node --version 2>&1
    Write-OK "Node.js $nodeVer"
} catch {
    Write-Fail "Node.js not found. Download from https://nodejs.org/"
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Host ""

# ── 3. Virtual environment ────────────────────────────────────────────────────
Write-Step "3/5" "Setting up Python environment..."

$VENV    = Join-Path $ROOT "venv"
$VENV_PY = Join-Path $VENV "Scripts\python.exe"
$VENV_PIP= Join-Path $VENV "Scripts\pip.exe"

if (-not (Test-Path $VENV_PY)) {
    Write-Info "Creating virtual environment..."
    & python -m venv $VENV
    if ($LASTEXITCODE -ne 0) {
        Write-Fail "Could not create venv. Using system Python."
        $VENV_PY  = "python"
        $VENV_PIP = "pip"
    } else {
        Write-OK "Virtual environment created."
    }
} else {
    Write-OK "Virtual environment found."
}

# Check / install packages
Write-Info "Checking Python packages..."
$check = & $VENV_PY -c "import flask, flask_cors, jwt, flask_sqlalchemy" 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Info "Installing backend dependencies..."
    & $VENV_PIP install --quiet --upgrade pip
    & $VENV_PIP install --quiet -r (Join-Path $ROOT "backend\requirements.txt")
    if ($LASTEXITCODE -ne 0) {
        Write-Fail "pip install failed. Check your internet connection."
        Read-Host "Press Enter to exit"
        exit 1
    }
    Write-OK "Backend packages installed."
} else {
    Write-OK "Backend packages OK."
}
Write-Host ""

# ── 4. Node modules ───────────────────────────────────────────────────────────
Write-Step "4/5" "Checking Node modules..."
$reactPkg = Join-Path $ROOT "node_modules\react"
if (-not (Test-Path $reactPkg)) {
    Write-Info "Running npm install (first time, may take a few minutes)..."
    Push-Location $ROOT
    & npm install --silent
    Pop-Location
    if ($LASTEXITCODE -ne 0) {
        Write-Fail "npm install failed."
        Read-Host "Press Enter to exit"
        exit 1
    }
    Write-OK "Node modules installed."
} else {
    Write-OK "Node modules OK."
}
Write-Host ""

# ── 5. Clear ports ────────────────────────────────────────────────────────────
Write-Step "5/5" "Clearing ports 3000 and 5000..."
foreach ($port in @(3000, 5000)) {
    $pids = (Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue).OwningProcess
    foreach ($pid in $pids) {
        Stop-Process -Id $pid -Force -ErrorAction SilentlyContinue
    }
}
Write-OK "Ports clear."
Write-Host ""

# ── Launch Backend ────────────────────────────────────────────────────────────
Write-Host "  Starting Flask backend  →  http://localhost:5000" -ForegroundColor Cyan
$backendCmd = "& '$VENV_PY' '$ROOT\flask_cors_config.py'"
Start-Process powershell -ArgumentList @(
    "-NoExit",
    "-Command",
    "`$Host.UI.RawUI.WindowTitle = 'CareerAI Backend [port 5000]'; " +
    "Write-Host '  CareerAI Backend  →  http://localhost:5000' -ForegroundColor Cyan; " +
    "Set-Location '$ROOT'; " +
    "& '$VENV_PY' '$ROOT\flask_cors_config.py'"
)

Start-Sleep -Seconds 3

# ── Launch Frontend ───────────────────────────────────────────────────────────
Write-Host "  Starting React frontend →  http://localhost:3000" -ForegroundColor Yellow
Start-Process powershell -ArgumentList @(
    "-NoExit",
    "-Command",
    "`$Host.UI.RawUI.WindowTitle = 'CareerAI Frontend [port 3000]'; " +
    "Write-Host '  CareerAI Frontend →  http://localhost:3000' -ForegroundColor Yellow; " +
    "`$env:BROWSER = 'none'; " +
    "Set-Location '$ROOT'; " +
    "npm start"
)

# ── Wait then open browser ────────────────────────────────────────────────────
Write-Host ""
Write-Host "  Waiting for React to compile (~15 seconds)..." -ForegroundColor Gray
Start-Sleep -Seconds 15

Write-Host "  Opening browser..." -ForegroundColor Gray
Start-Process "http://localhost:3000"

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "  ║  CareerAI is running!                        ║" -ForegroundColor Green
Write-Host "  ║                                              ║" -ForegroundColor Green
Write-Host "  ║  Frontend  →  http://localhost:3000          ║" -ForegroundColor Green
Write-Host "  ║  Backend   →  http://localhost:5000          ║" -ForegroundColor Green
Write-Host "  ║                                              ║" -ForegroundColor Green
Write-Host "  ║  Run STOP_PROJECT.ps1 to stop all servers.   ║" -ForegroundColor Green
Write-Host "  ╚══════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Read-Host "Press Enter to close this launcher window"
