# ============================================================
#  ABORT_TRADING.ps1 - CTV2 Emergency Stop
#  Revision: 1.2
#  v1.2 - Banner and status messages updated from CTV2 to VTB (user-facing branding).
#  v1.1 - Copyright (c) Gregory Howard 2026 All rights reserved added to
#          console banner.
#  v1.0 - Initial implementation.
#  Emergency escape hatch. Kills the running CTV2 runner
#  immediately and clears the live trading confirmation flag.
#
#  Open trades are NOT force-closed. They will expire at EOD.
#  Use this when you need to stop trading without waiting for
#  a clean shutdown.
#
#  Placed on the desktop as "Abort Trading" shortcut.
# ============================================================

Set-Location -Path "C:\CTV"

Write-Host ""
Write-Host "============================================================"
Write-Host "  VTB ABORT TRADING"
Write-Host "  Copyright (c) Gregory Howard 2026  All rights reserved"
Write-Host "============================================================"
Write-Host ""
Write-Host "  Stopping VTB runner..."

# Find the python process running ctv2_runner.py
$proc = Get-CimInstance Win32_Process |
        Where-Object { $_.CommandLine -like '*ctv2_runner*' } |
        Select-Object -First 1

if ($proc) {
    Stop-Process -Id $proc.ProcessId -Force -ErrorAction SilentlyContinue
    Write-Host "  Runner (PID $($proc.ProcessId)) stopped."
} else {
    Write-Host "  VTB runner not found - may have already exited."
}

Write-Host ""

# Clear live trading confirmation - require fresh confirm on next start
$flagFile = "C:\CTV\live_confirmed.flag"
if (Test-Path $flagFile) {
    Remove-Item $flagFile -Force
    Write-Host "  Live trading confirmation cleared."
    Write-Host "  You must re-confirm live trading before the next session."
} else {
    Write-Host "  Live trading flag not present (paper mode or already cleared)."
}

Write-Host ""
Write-Host "  Open positions (if any) will expire at end of day."
Write-Host ""
Write-Host "============================================================"
Write-Host ""
Read-Host "Press Enter to close"
