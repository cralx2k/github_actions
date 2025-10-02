@echo off
setlocal ENABLEEXTENSIONS

set "LOGFILE=C:\temp\action_log\verify_login_script.txt"
set "HOST=%TARGET_HOST%"
if "%HOST%"=="" set "HOST=leaoserver"

if "%GHA_USERNAME%"=="" (
  echo [BATCH] ERROR: GHA_USERNAME not set >> "%LOGFILE%"
  exit /b 1
)
if "%GHA_PASSWORD%"=="" (
  echo [BATCH] ERROR: GHA_PASSWORD not set >> "%LOGFILE%"
  exit /b 1
)

echo [BATCH] Local session user: %USERNAME%
echo [BATCH] Testing network auth to \\%HOST%\IPC$

rem stage creds
cmdkey /add:%HOST% /user:%GHA_USERNAME% /pass:%GHA_PASSWORD% >nul 2>&1

rem probe IPC$
dir \\%HOST%\IPC$ >nul 2>&1
set "RC=%ERRORLEVEL%"

rem cleanup creds
cmdkey /delete:%HOST% >nul 2>&1

if %RC% NEQ 0 (
  echo [BATCH] Auth FAILED to \\%HOST%\IPC$ >> "%LOGFILE%"
  echo [BATCH] Auth FAILED
  exit /b 1
) else (
  echo [BATCH] Auth OK to \\%HOST%\IPC$ >> "%LOGFILE%"
  echo [BATCH] Auth OK
)

echo [BATCH] Batch script ran successfully >> "%LOGFILE%"
endlocal
