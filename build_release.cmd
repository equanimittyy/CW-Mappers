@echo off
rem Double-click entry point: gets past the default execution policy and keeps the window open to show the result.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0build_release.ps1" %*
pause
