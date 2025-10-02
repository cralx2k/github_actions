@echo off
rem ===== Pure-BAT SMB auth probe with robust password escaping =====
setlocal DisableDelayedExpansion
setlocal EnableExtensions

set "LOGFILE=C:\temp\action_log\verify_login_script.txt"

rem --- Read config from env with defaults ---
set "HOST=%TARGET_HOST%"
if not defined HOST set "HOST=leaoserver"

set "SHARE=%TARGET_SHARE%"
if not defined SHARE set "SHARE=c"  rem \\server\c  (NOT admin C$)

set "DOMAIN=%AUTH_DOMAIN%"
set "USER_BASE=%GHA_USERNAME%"
set "PASS_RAW=%GHA_PASSWORD%"

rem --- Truncate + header so each run is clean ---
> "%LOGFILE%" echo [BATCH] %DATE% %TIME% - starting batch auth probe
>> "%LOGFILE%" echo [BATCH] Config: HOST=%HOST%  SHARE=%SHARE%  DOMAIN=%DOMAIN%

if not defined USER_BASE (
  echo [BATCH] ERROR: GHA_USERNAME not set >> "%LOGFILE%"
  echo [BATCH] ERROR: GHA_USERNAME not set
  exit /b 1
)
if not defined PASS_RAW (
  echo [BATCH] ERROR: GHA_PASSWORD not set >> "%LOGFILE%"
  echo [BATCH] ERROR: GHA_PASSWORD not set
  exit /b 1
)

rem --- Build domain\user if a domain was provided (leave UPN as-is) ---
set "USER_FOR_AUTH=%USER_BASE%"
if defined DOMAIN if "%USER_BASE:%=%"=="%USER_BASE%" set "USER_FOR_AUTH=%DOMAIN%\%USER_BASE%"
rem (tiny guard: if USER_BASE contains '@', assume UPN and don't prefix DOMAIN)

rem --- Escape password for CMD meta chars and quote it for NET USE ---
set "PWD_SAFE=%PASS_RAW%"
set "PWD_SAFE=%PWD_SAFE:^=^^%"
set "PWD_SAFE=%PWD_SAFE:&=^&%"
set "PWD_SAFE=%PWD_SAFE:|=^|%"
set "PWD_SAFE=%PWD_SAFE:<=^<%"
set "PWD_SAFE=%PWD_SAFE:>=^>%"
set "PWD_SAFE=%PWD_SAFE:)=^)%"
set "PWD_SAFE=%PWD_SAFE:(=^(%"
rem DelayedExpansion is OFF so '!' stays literal

echo [BATCH] Local session user: %USERNAME%
echo [BATCH] Testing SMB auth to \\%HOST%\%SHARE% as %USER_FOR_AUTH%
>> "%LOGFILE%" echo [BATCH] Testing \\%HOST%\%SHARE% as %USER_FOR_AUTH%

rem --- Ensure folder exists ---
if not exist "C:\temp\action_log\" mkdir "C:\temp\action_log\" >nul 2>&1

rem --- Clear any stale mapping (ignore errors) ---
net use \\%HOST%\%SHARE% /delete >nul 2>&1

rem --- Attempt mapping (non-persistent) and show errors inline if any ---
net use \\%HOST%\%SHARE% /user:%USER_FOR_AUTH% "%PWD_SAFE%" /persistent:no
set "RC=%ERRORLEVEL%"
if not "%RC%"=="0" (
  echo [BATCH] Auth FAILED to \\%HOST%\%SHARE% (RC=%RC%) >> "%LOGFILE%"
  echo [BATCH] Auth FAILED (RC=%RC%)
  exit /b %RC%
)

rem --- Optional probe of the root ---
dir \\%HOST%\%SHARE% >nul 2>&1

rem --- Cleanup mapping (best-effort) ---
net use \\%HOST%\%SHARE% /delete >nul 2>&1

echo [BATCH] Auth OK to \\%HOST%\%SHARE% >> "%LOGFILE%"
echo [BATCH] Batch script ran successfully >> "%LOGFILE%"
exit /b 0
