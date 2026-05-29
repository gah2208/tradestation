@echo off
REM __version__ = 1.0.0
REM VTBC Build Pipeline

cd /d %~dp0

echo.
echo ===============================
echo  VTBC BUILD PIPELINE START
echo ===============================
echo.

REM ---------------------------
REM STEP 1 — BUILD CHECK
REM ---------------------------
echo Running build version check...
python -c "from build_check import run_build_check; run_build_check()"

IF %ERRORLEVEL% NEQ 0 (
    echo.
    echo ❌ BUILD VERSION CHECK FAILED
    goto END
)

echo ✅ VERSION CHECK PASSED
echo.

REM ---------------------------
REM STEP 2 — CHECKSUM VALIDATION
REM ---------------------------
echo Running checksum validation...
python -c "from checksum import verify_checksum; verify_checksum()"

IF %ERRORLEVEL% NEQ 0 (
    echo.
    echo ❌ CHECKSUM VALIDATION FAILED
    goto END
)

echo ✅ CHECKSUM VALIDATION PASSED
echo.

REM ---------------------------
REM STEP 3 — CLEAN PREVIOUS BUILD
REM ---------------------------
echo Cleaning previous build artifacts...

rmdir /s /q build >nul 2>&1
rmdir /s /q dist >nul 2>&1

del *.spec >nul 2>&1

echo Clean complete.
echo.

REM ---------------------------
REM STEP 4 — BUILD EXECUTABLES
REM ---------------------------
echo ===============================
echo  BUILDING EXECUTABLES
echo ===============================
echo.

echo Building main.exe...
python -m PyInstaller --onefile --noconsole --name main dev\main.py

IF %ERRORLEVEL% NEQ 0 (
    echo ❌ main.exe build failed
    goto END
)

echo main.exe built successfully.
echo.

echo Building config_editor.exe...
python -m PyInstaller --onefile --noconsole --name config_editor dev\ui\config_editor.py

IF %ERRORLEVEL% NEQ 0 (
    echo ❌ config_editor.exe build failed
    goto END
)

echo config_editor.exe built successfully.
echo.

REM ---------------------------
REM STEP 5 — COPY TO DISTRIBUTION
REM ---------------------------
echo ===============================
echo  COPYING TO DIST
echo ===============================
echo.

REM Recreate clean dist folder
mkdir dist >nul 2>&1

copy /y dist\main.exe ..\dist\main.exe >nul
copy /y dist\config_editor.exe ..\dist\config_editor.exe >nul

IF %ERRORLEVEL% NEQ 0 (
    echo ❌ Failed to copy executables
    goto END
)

echo Executables copied to distribution folder.
echo.

REM ---------------------------
REM STEP 6 — COPY VERSION FILE
REM ---------------------------
if exist VERSION.txt (
    copy /y VERSION.txt ..\dist\VERSION.txt >nul
)

echo Version file copied.
echo.

REM ---------------------------
REM COMPLETE
REM ---------------------------
echo ===============================
echo ✅ BUILD COMPLETED SUCCESSFULLY
echo ===============================
echo.

:END
echo.
echo Press any key to close...
pause >nul
exit /b