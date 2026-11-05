@echo off
REM Opens the latest Robot Framework HTML Report in your default web browser
echo [INFO] Launching Robot Framework Test Report in browser...
if exist "%~dp0reports\report.html" (
    start "" "%~dp0reports\report.html"
) else (
    echo [ERROR] No report.html found. Please run tests first.
)
