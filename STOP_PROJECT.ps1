# CareerAI - Stop Script (PowerShell)
# Right-click → "Run with PowerShell"

$Host.UI.RawUI.WindowTitle = "CareerAI - Stopping"

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════╗" -ForegroundColor Red
Write-Host "  ║         CareerAI - Stopping Servers          ║" -ForegroundColor Red
Write-Host "  ╚══════════════════════════════════════════════╝" -ForegroundColor Red
Write-Host ""

function Stop-Port($port, $label) {
    $connections = Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue
    if ($connections) {
        foreach ($conn in $connections) {
            Stop-Process -Id $conn.OwningProcess -Force -ErrorAction SilentlyContinue
        }
        Write-Host "  ✓ $label stopped (port $port)." -ForegroundColor Green
    } else {
        Write-Host "  · $label was not running (port $port)." -ForegroundColor Gray
    }
}

Stop-Port 5000 "Backend"
Stop-Port 3000 "Frontend"

# Close the titled PowerShell windows
Get-Process powershell -ErrorAction SilentlyContinue | Where-Object {
    $_.MainWindowTitle -like "CareerAI*"
} | Stop-Process -Force -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "  ║  All CareerAI servers stopped.               ║" -ForegroundColor Green
Write-Host "  ╚══════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Read-Host "Press Enter to close"
