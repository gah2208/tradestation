# ==============================================================
#  CREATE_SHORTCUTS.ps1 - VTBC Desktop Shortcut Installer


$VTBC_DIR = $PSScriptRoot
$CMD_EXE = "C:\Windows\System32\cmd.exe"

# OneDrive-aware desktop path
$DESKTOP = (Get-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders").Desktop
if (-not $DESKTOP) { $DESKTOP = [Environment]::GetFolderPath('Desktop') }
$DESKTOP = [System.Environment]::ExpandEnvironmentVariables($DESKTOP)

Write-Host ""
Write-Host "=============================================================="
Write-Host "  VTBC SHORTCUT INSTALLER v1.00"
Write-Host "=============================================================="
Write-Host "  VTBC Dir: $VTBC_DIR"
Write-Host "  Desktop: $DESKTOP"
Write-Host ""

# Shortcut definitions - all point to .bat wrappers
$SHORTCUTS = @(
    @{ Name = "Start Trading";   Script = "START_TRADING.bat"; Icon = "Start_Trading.ico"   },
    @{ Name = "Restart Trading"; Script = "RESTART.bat";        Icon = "Restart_Trading.ico" },
    @{ Name = "Abort Trading";   Script = "ABORT_TRADING.bat";  Icon = "Abort.ico"           },
    @{ Name = "Config Editor";   Script = "CONFIG_EDITOR.bat";  Icon = "Config_Editor.ico"   },
    @{ Name = "Update VTB";     Script = "UPDATE.bat";          Icon = "Update.ico"          }
)
# Helper: create one shortcut via temp VBScript
function New-Shortcut {
    param(
        [string]$LnkPath,
        [string]$TargetPath,
        [string]$Arguments,
        [string]$WorkingDir,
        [string]$Description,
        [string]$IconPath
    )

    $lines = [System.Collections.Generic.List[string]]::new()
    $lines.Add('Dim ws, sc')
    $lines.Add('Set ws = WScript.CreateObject("WScript.Shell")')
    $lines.Add('Set sc = ws.CreateShortcut("' + $LnkPath + '")')
    $lines.Add('sc.TargetPath = "' + $TargetPath + '"')
    $lines.Add('sc.Arguments = "' + $Arguments + '"')
    $lines.Add('sc.WorkingDirectory = "' + $WorkingDir + '"')
    $lines.Add('sc.Description = "' + $Description + '"')
    $lines.Add('sc.WindowStyle = 1')

    if ($IconPath -and (Test-Path $IconPath)) {
        $lines.Add('sc.IconLocation = "' + $IconPath + ', 0"')
    }

    $lines.Add('sc.Save()')

    $tmp = [System.IO.Path]::GetTempFileName() -replace '\.tmp$', '.vbs'
    [System.IO.File]::WriteAllLines($tmp, $lines.ToArray(), [System.Text.Encoding]::ASCII)
    $result = & cscript //nologo $tmp 2>&1
    Remove-Item $tmp -Force

    if ($result) {
        Write-Host "    VBScript output: $result"
    }
}

# Step 1: Remove existing VTBC shortcuts
Write-Host "  Removing existing shortcuts..."
foreach ($s in $SHORTCUTS) {
    $lnk = "$DESKTOP\$($s.Name).lnk"
    if (Test-Path $lnk) {
        Remove-Item $lnk -Force
        Write-Host "    Removed: $($s.Name).lnk"
    }
}

Write-Host ""

# Step 2: Create new shortcuts
Write-Host "  Creating new shortcuts..."

foreach ($s in $SHORTCUTS) {
    $lnk      = "$DESKTOP\$($s.Name).lnk"
    $script   = "$VTBC_DIR\$($s.Script)"
    $iconPath = "$VTBC_DIR\$($s.Icon)"

    if (-not (Test-Path $script)) {
        Write-Host "    SKIPPED: $($s.Name) - $($s.Script) not found in $VTBC_DIR"
        continue
    }

    $cmdArgs = '/c ""' + $script + '""'

    New-Shortcut `
        -LnkPath     $lnk `
        -TargetPath  $CMD_EXE `
        -Arguments   $cmdArgs `
        -WorkingDir  $VTBC_DIR `
        -Description "VTBC - $($s.Name)" `
        -IconPath    $iconPath

    if (Test-Path $lnk) {
        Write-Host "    Created: $($s.Name).lnk"
    } else {
        Write-Host "    FAILED:  $($s.Name).lnk was not created"
    }
}

Write-Host ""
Write-Host "=============================================================="
Write-Host "  Done. VTBC shortcuts are on your desktop."
Write-Host "=============================================================="
Write-Host ""
