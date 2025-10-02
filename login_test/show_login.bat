@echo off
setlocal DisableDelayedExpansion  && rem important for '!' in passwords
setlocal ENABLEEXTENSIONS

set "LOGFILE=C:\temp\action_log\verify_login_script.txt"
set "HOST=%TARGET_HOST%"
set "SHARE=%TARGET_SHARE%"
set "DOMAIN=%AUTH_DOMAIN%"

if "%HOST%"==""  set "HOST=leaoserver"
if "%SHARE%"=="" set "SHARE=IPC$"

if "%GHA_USERNAME%"=="" (
  echo [BATCH] ERROR: GHA_USERNAME not set >> "%LOGFILE%"
  exit /b 1
)
if "%GHA_PASSWORD%"=="" (
  echo [BATCH] ERROR: GHA_PASSWORD not set >> "%LOGFILE%"
  exit /b 1
)

set "USER_FOR_AUTH=%GHA_USERNAME%"
if not "%DOMAIN%"=="" set "USER_FOR_AUTH=%DOMAIN%\%GHA_USERNAME%"

rem ---- escape password for CMD metacharacters ----
set "PWD_SAFE=%GHA_PASSWORD%"
rem order matters; do '^' first
set "PWD_SAFE=%PWD_SAFE:^=^^%"
set "PWD_SAFE=%PWD_SAFE:&=^&%"
set "PWD_SAFE=%PWD_SAFE:|=^|%"
set "PWD_SAFE=%PWD_SAFE:<=^<%"
set "PWD_SAFE=%PWD_SAFE:>=^>%"
set "PWD_SAFE=%PWD_SAFE:)=^)%"
set "PWD_SAFE=%PWD_SAFE:(=^(%"
rem '!' is safe because DelayedExpansion is OFF
set "PWD_SAFE=%PWD_SAFE:!=^^!%"

echo [BATCH] Local session user: %USERNAME%
echo [BATCH] Testing SMB auth to \\%HOST%\%SHARE% as %USER_FOR_AUTH%

rem Clear any stale mapping
net use \\%HOST%\%SHARE% /delete >nul 2>&1

rem Use quotes around the (escaped) password
net use \\%HOST%\%SHARE% /user:%USER_FOR_AUTH% "%PWD_SAFE%" /persistent:no >nul 2>&1
set "RC=%ERRORLEVEL%"

if %RC% NEQ 0 (
  echo [BATCH] Auth FAILED to \\%HOST%\%SHARE% (RC=%RC%) >> "%LOGFILE%"
  echo [BATCH] Auth FAILED (RC=%RC%)
  exit /b %RC%
)

rem Cleanup mapping
net use \\%HOST%\%SHARE% /delete >nul 2>&1

echo [BATCH] Auth OK to \\%HOST%\%SHARE% >> "%LOGFILE%"
echo [BATCH] Batch script ran successfully >> "%LOGFILE%"
endlocal
