# ============================================================
#  config_editor.ps1 - Launch CTV2 Config Editor  v1.3
#  Place this file in C:\CTV
#
#  v1.3 - Banner title updated from CTV2 to VTB (user-facing branding).
#  v1.2 - Copyright (c) Gregory Howard 2026 All rights reserved added to
#          console banner at startup.
#  v1.1 - Added version header
# ============================================================

Set-Location -Path "C:\CTV"
Write-Host ""
Write-Host "============================================================"
Write-Host "  VTB Config Editor"
Write-Host "  Copyright (c) Gregory Howard 2026  All rights reserved"
Write-Host "============================================================"
Write-Host ""
python ctv2_config_editor.py
