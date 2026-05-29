@echo off
REM __version__ = 1.0.7
REM Copyright 2026 Gregory Howard  all rights reserved.

cd /d %~dp0

echo.
echo ===============================
echo  VTBC BUILD VERIFICATION START
echo ===============================
echo.

REM ===== BUILD CHECK =====
echo Running build version check...
python -c "from build_check import run_build_check; run_build_check()"

IF %ERRORLEVEL% NEQ 0 (
    echo.
    echo ❌ BUILD VERSION CHECK FAILED
    goto END
)

echo.
echo ✅ VERSION CHECK PASSED
echo.

REM ===== CHECKSUM =====
echo ===============================
echo  VTBC CHECKSUM VALIDATION
echo ===============================
echo.

python -c "from checksum import verify_checksum; verify_checksum()"

IF %ERRORLEVEL% NEQ 0 (
    echo.
    echo ❌ CHECKSUM VALIDATION FAILED
    goto END
)

echo.
echo ===============================
echo ✅ BUILD VERIFIED SUCCESSFULLY
echo ===============================
echo.

:END
echo.
echo Press any key to close...
pause >nul
exit /b