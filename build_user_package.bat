@echo off
REM __version__ = 1.0.0
REM Copyright 2026 Gregory Howard  all rights reserved.

cd /d %~dp0

echo.
echo ===============================
echo   BUILDING USER PACKAGE
echo ===============================
echo.

REM ===== CLEAN OLD BUILD =====
if exist dist rmdir /s /q dist
mkdir dist

echo Copying user files...

REM ===== COPY ONLY USER FILES =====
copy main.py dist\
copy config.py dist\
copy eligibility_engine.py dist\
copy ema_engine.py dist\
copy ema_rebuild.py dist\
copy ema_persistence.py dist\
copy execution_state.py dist\
copy market_data.py dist\
copy order_builder.py dist\
copy ts_client.py dist\
copy trade_logger.py dist\
copy build_manifest.py dist\
copy checksum.py dist\
copy license.py dist

REM ===== EXCLUDE ADMIN FILES =====
REM (DO NOT copy admin_config.py)

echo.
echo Creating zip package...

REM ===== ZIP USING POWERSHELL =====
powershell -command "Compress-Archive -Path dist\* -DestinationPath vtbc_user_package.zip -Force"

echo.
echo ===============================
echo ✅ PACKAGE BUILT: vtbc_user_package.zip
echo ===============================
echo.

pause
exit /b