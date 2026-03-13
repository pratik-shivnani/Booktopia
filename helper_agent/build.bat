@echo off
echo ============================================
echo  Booktopia Helper Agent - Build
echo ============================================
echo.

REM Check Python
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python not found. Install Python 3.11+ first.
    pause
    exit /b 1
)

REM Install dependencies
echo Installing dependencies...
pip install -r requirements.txt pyinstaller --quiet

echo.
echo Building exe...
pyinstaller --clean booktopia_helper.spec

echo.
if exist "dist\booktopia-helper.exe" (
    echo ============================================
    echo  SUCCESS! Exe is at:
    echo  dist\booktopia-helper.exe
    echo ============================================
    echo.
    echo You can copy it anywhere and double-click to run.
) else (
    echo BUILD FAILED - check errors above.
)
echo.
pause
