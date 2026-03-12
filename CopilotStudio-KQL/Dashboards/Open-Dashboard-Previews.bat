@echo off
REM ===============================================================================
REM Dashboard Preview Launcher
REM ===============================================================================
REM Description: Opens all dashboard HTML files in your default browser
REM ===============================================================================

echo.
echo ====================================
echo Dashboard Preview Launcher
echo ====================================
echo.
echo Opening dashboard previews in your browser...
echo.

REM Get the current directory
set "CURRENT_DIR=%~dp0"

REM Open each dashboard in the default browser
start "" "%CURRENT_DIR%Preview-All-Dashboards-Overview.html"
timeout /t 2 /nobreak >nul

start "" "%CURRENT_DIR%Preview-01-Overview-Dashboard.html"
timeout /t 2 /nobreak >nul

start "" "%CURRENT_DIR%Preview-02-Performance-Dashboard.html"
timeout /t 2 /nobreak >nul

start "" "%CURRENT_DIR%Preview-03-Conversation-Analytics-Dashboard.html"

echo.
echo All dashboards opened successfully!
echo.
echo TIP: To capture these as PNG images:
echo   1. Right-click in browser and select "Inspect" (F12)
echo   2. Press Ctrl+Shift+P
echo   3. Type "Capture full size screenshot"
echo   4. Or run: Capture-Dashboards.ps1 (PowerShell script)
echo.
echo See CAPTURE-INSTRUCTIONS.md for more details.
echo.
pause
