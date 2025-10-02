@echo off
setlocal
echo [BATCH] Local session user: %USERNAME%
echo [BATCH] Delegating SMB auth to PowerShell...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0show_login.ps1"
exit /b %ERRORLEVEL%
