@echo off
REM ============================================================
REM  START_TRADING.bat - CTV2 Start Trading Launcher
REM  Revision: 1.0
REM  Calls START_TRADING.ps1 via PowerShell.
REM  This file must exist in C:\CTV for the shortcut to work.
REM ============================================================
powershell.exe -ExecutionPolicy Bypass -NoProfile -File "C:\CTV\START_TRADING.ps1"
pause
