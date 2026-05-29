

Set-Location -Path $PSScriptRoot

$modeFlag  = if ($Live) { "--live" } else { "" }
$modeLabel = if ($Live) { "LIVE" } else { "PAPER" }

# -- Pushover helper -----------------------------------------------------------
function Send-PushoverAlert {
    param([string]$Message, [string]$Title)
    try {
        $cfg = Get-Content "C:\CTV\config_ctv2.py" -ErrorAction SilentlyContinue
        if (-not $cfg) { return }
        if (-not ($cfg | Select-String "PUSHOVER_ENABLED\s*=\s*True")) { return }
        $userKey  = ($cfg | Select-String "PUSHOVER_USER_KEY\s*=\s*'([^']+)'").Matches.Groups[1].Value
        $apiToken = ($cfg | Select-String "PUSHOVER_API_TOKEN\s*=\s*'([^']+)'").Matches.Groups[1].Value
        if (-not $userKey -or -not $apiToken) { return }
        Invoke-RestMethod -Uri "https://api.pushover.net/1/messages.json" -Method Post -Body @{
            token    = $apiToken
            user     = $userKey
            message  = $Message
            title    = $Title
            priority = 1
            sound    = "siren"
        } | Out-Null
    } catch { }
}

# -- Integrity check -----------------------------------------------------------
function Invoke-IntegrityCheck {
    $manifestPath = "C:\CTV\install_manifest.json"

    Write-Host "  Checking Python integrity..."

    if (-not (Test-Path $manifestPath)) {
        Write-Host ""
        Write-Host "  ERROR: install_manifest.json not found."
        Write-Host "  Run the installer to generate a fresh manifest before trading."
        Write-Host ""
        return $false
    }

    $manifest = Get-Content $manifestPath | ConvertFrom-Json

    function Get-FileSHA256 {
        param([string]$Path)
        if (-not (Test-Path $Path)) { return $null }
        return (Get-FileHash -Path $Path -Algorithm SHA256).Hash
    }

    $pyActual = Get-FileSHA256 $manifest.python.path
    if ($pyActual -eq $manifest.python.sha256) {
        Write-Host "  Python : OK"
    } else {
        Write-Host ""
        Write-Host "  Python integrity check FAILED - reinstalling Python 3.11.9..."
        try {
            $ProgressPreference = 'SilentlyContinue'
            $pyInstaller = "$env:TEMP\python-3.11.9-amd64.exe"
            Invoke-WebRequest -Uri "https://www.python.org/ftp/python/3.11.9/python-3.11.9-amd64.exe" `
                -OutFile $pyInstaller -UseBasicParsing
            Start-Process -FilePath $pyInstaller `
                -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1 Include_test=0" -Wait
            Start-Sleep -Seconds 15
            $pyActual = Get-FileSHA256 $manifest.python.path
            $manifest.python.sha256 = $pyActual
            $manifest | ConvertTo-Json -Depth 5 | Set-Content $manifestPath -Encoding UTF8
            Write-Host "  Python : Reinstalled and manifest updated."
        } catch {
            Write-Host ""
            Write-Host "  ERROR: Python reinstall failed."
            Write-Host "  $_"
            Write-Host "  Trading cannot proceed. Check your internet connection and try again."
            Write-Host ""
            return $false
        }
    }

    Write-Host "  Integrity check passed."
    Write-Host ""
    return $true
}

# -- Header --------------------------------------------------------------------
Write-Host ""
Write-Host "============================================================"
Write-Host "  VTB RESTART"
Write-Host "  Copyright (c) Gregory Howard 2026  All rights reserved"
Write-Host "============================================================"
Write-Host "  Mode: $modeLabel"
Write-Host ""

if (-not (Invoke-IntegrityCheck)) {
    Read-Host "Press Enter to exit"
    exit 1
}

# -- Clear live trading confirmation -------------------------------------------
# Restart always requires fresh confirmation regardless of prior state.
$flagFile = "C:\CTV\live_confirmed.flag"
if (Test-Path $flagFile) {
    Write-Host "  Clearing live trading confirmation..."
    Remove-Item $flagFile -Force
}

# -- Pre-flight credential check -----------------------------------------------
Write-Host "  Checking required credentials..."
python preflight_check.py --mode restart
if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "  Setup cancelled. Restart aborted."
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Host "  Credentials OK."
Write-Host ""

# -- Stop existing runner ------------------------------------------------------
Write-Host "  Stopping existing runner..."
Get-Process python -ErrorAction SilentlyContinue |
    Where-Object { $_.CommandLine -like "*ctv2_runner*" } |
    Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 3

# -- Clear risk suspension flag ------------------------------------------------
if (Test-Path "RESTART_TRADING.flag") {
    Write-Host "  Clearing risk suspension flag..."
    Remove-Item "RESTART_TRADING.flag" -Force
}
"" | Out-File "RESTART_TRADING.flag" -Encoding ascii
Start-Sleep -Seconds 1

# -- Log setup -----------------------------------------------------------------
Write-Host "  Starting runner..."
Write-Host "  Press Ctrl+C to stop cleanly."
Write-Host ""

$logsDir = "C:\CTV\logs"
if (-not (Test-Path $logsDir)) { New-Item -ItemType Directory -Path $logsDir | Out-Null }
$modeTag = if ($Live) { "live" } else { "paper" }
$logFile = Join-Path $logsDir ("ctv2_${modeTag}_" + (Get-Date -Format "yyyyMMdd_HHmmss") + ".log")
Write-Host "  Log file: $logFile"
Write-Host ""

# -- Run runner ----------------------------------------------------------------
if ($Live) {
    python -u ctv2_runner.py --live 2>&1 | Tee-Object -FilePath $logFile
} else {
    python -u ctv2_runner.py 2>&1 | Tee-Object -FilePath $logFile
}

Write-Host ""
Write-Host "  Runner exited. Log saved to: $logFile"
Write-Host ""
Read-Host "Press Enter to exit"
