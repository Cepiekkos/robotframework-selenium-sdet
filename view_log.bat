@echo off
REM Opens the latest Robot Framework detailed Log in your default web browser
echo [INFO] Launching Robot Framework Test Log in browser...
if exist "%~dp0reports\log.html" (
    start "" "%~dp0reports\log.html"
) else (
    echo [ERROR] No log.html found. Please run tests first.
)
