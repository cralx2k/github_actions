@echo off
rem Thin wrapper: log the call and delegate SMB auth to PowerShell (safer for special chars)

setlocal
set "LOGFILE=C:\temp\action_log\verify_login_script.txt"

if not exist "C:\temp\action_log\" mkdir "C:\temp\action_log\" >nul 2>&1
>> "%LOGFILE%" echo [BATCH] %DATE% %TIME% - wrapper start. Delegating to PowerShell.

echo [BATCH] Local session user: %USERNAME%
echo [BATCH] Delegating SMB auth to PowerShell...
>> "%LOGFILE%" echo [BATCH] Local session user: %USERNAME%

powershell -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command ^
  "try { & '%~dp0show_login.ps1' ; exit $LASTEXITCODE } catch { Write-Host 'PWSH wrapper error:' $_.Exception.Message ; exit 1 }"

set "RC=%ERRORLEVEL%"
>> "%LOGFILE%" echo [BATCH] PowerShell returned RC=%RC%
if %RC% NEQ 0 (
  echo [BATCH] Delegated auth FAILED (RC=%RC%)
  exit /b %RC%
)

echo [BATCH] Delegated auth SUCCEEDED
exit /b 0
