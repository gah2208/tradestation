@echo off
REM __version__ = 2.0.0
REM Copyright 2026 Gregory Howard  all rights reserved.

cd /d %~dp0

echo.
echo ===============================
echo   GENERATE CHECKSUM
echo ===============================
echo.

echo Running checksum generator...
echo.

python generate_checksum.py

echo.
echo -------------------------------
echo Copy the value above and paste into:
echo checksum.py → CHECKSUM = "VALUE"
echo -------------------------------
echo.

pause