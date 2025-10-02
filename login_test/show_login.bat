@echo off
rem ===== Pure-BAT SMB auth probe with robust password escaping =====
setlocal DisableDelayedExpansion
setlocal EnableExtensions

rem --- Config from workflow env (with sane defaults) ---
set "HOST=%TARGET_HOST%"
if not defined HOST set "HOST=leaoserver"

set "SHARE=%TARGET_SHARE%"
if not defined SHARE set "SHARE=c"  rem e.g., 'c' for \\server\c (NOT C$)

set "DOMAIN=%AUTH_DOMAIN%"
set "USER_BASE=%GHA_USERNAME%"
set "PASS_RAW=%GHA_PASSWORD%"

set "LOGFILE=C:\temp\action_log\verify_login_script.txt"

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

rem --- Build domain\user if a domain was provided (leave as-is if using UPN) ---
set "USER_FOR_AUTH=%USER_BASE%"
if defined DOMAIN set "USER_FOR_AUTH=%DOMAIN%\%USER_BASE%"

rem --- Escape password for CMD meta chars and quote it for NET USE ---
set "PWD_SAFE=%PASS_RAW%"
set "PWD_SAFE=%PWD_SAFE:^=^^%"
set "PWD_SAFE=%PWD_SAFE:&=^&%"
set "PWD_SAFE=%PWD_SAFE:|=^|%"
set "PWD_SAFE=%PWD_SAFE:<=^<%"
set "PWD_SAFE=%PWD_SAFE:>=^>%"
set "PWD_SAFE=%PWD_SAFE:)=^)%"
set "PWD_SAFE=%PWD_SAFE:(=^(%"
rem DelayedExpansion is OFF so '!' is safe

echo [BATCH] Local session user: %USERNAME%
echo [BATCH] Testing SMB auth to \\%HOST%\%SHARE% as %USER_FOR_AUTH%

rem --- Ensure log folder exists (pure cmd) ---
if not exist "C:\temp\action_log\" mkdir "C:\temp\action_log\" >nul 2>&1

rem --- Clear any stale mapping for this UNC path (ignore errors) ---
net use \\%HOST%\%SHARE% /delete >nul 2>&1

rem --- Attempt mapping (non-persistent); show NET USE output if it fails ---
net use \\%HOST%\%SHARE% /user:%USER_FOR_AUTH% "%PWD_SAFE%" /persistent:no
set "RC=%ERRORLEVEL%"
if not "%RC%"=="0" (
  echo [BATCH] Auth FAILED to \\%HOST%\%SHARE% (RC=%RC%) >> "%LOGFILE%"
  echo [BATCH] Auth FAILED (RC=%RC%)
  exit /b %RC%
)

rem --- Optional probe (should succeed if mapped ok) ---
dir \\%HOST%\%SHARE% >nul 2>&1

rem --- Cleanup mapping (best-effort) ---
net use \\%HOST%\%SHARE% /delete >nul 2>&1

echo [BATCH] Auth OK to \\%HOST%\%SHARE% >> "%LOGFILE%"
echo [BATCH] Batch script ran successfully >> "%LOGFILE%"
exit /b 0
