@echo off
title Booktopia Helper Agent
python "%~dp0main.py" %*
if errorlevel 1 (
    echo.
    echo If Python is not installed, download it from python.org
    echo Then run: pip install -r requirements.txt
    pause
)
