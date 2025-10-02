@echo off
setlocal DisableDelayedExpansion
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

rem escape metacharacters and quote the password
set "PWD_SAFE=%GHA_PASSWORD%"
set "PWD_SAFE=%PWD_SAFE:^=^^%"
set "PWD_SAFE=%PWD_SAFE:&=^&%"
set "PWD_SAFE=%PWD_SAFE:|=^|%"
set "PWD_SAFE=%PWD_SAFE:<=^<%"
set "PWD_SAFE=%PWD_SAFE:>=^>%"
set "PWD_SAFE=%PWD_SAFE:)=^)%"
set "PWD_SAFE=%PWD_SAFE:(=^(%"
set "PWD_SAFE=%PWD_SAFE:!=^^!%"

echo [BATCH] Local session user: %USERNAME%
echo [BATCH] Testing SMB auth to \\%HOST%\%SHARE% as %USER_FOR_AUTH%

rem clear any stale mapping
net use \\%HOST%\%SHARE% /delete >nul 2>&1

rem try the requested share first (show error output if it fails)
net use \\%HOST%\%SHARE% /user:%USER_FOR_AUTH% "%PWD_SAFE%" /persistent:no
set "RC=%ERRORLEVEL%"
if %RC% NEQ 0 (
  echo [BATCH] FIRST TRY FAILED (RC=%RC%). Output above shows the reason.
  echo [BATCH] FIRST TRY FAILED to \\%HOST%\%SHARE% (RC=%RC%) >> "%LOGFILE%"

  rem fallback to IPC$ if it wasn't already
  if /I not "%SHARE%"=="IPC$" (
    echo [BATCH] Falling back to \\%HOST%\IPC$
    net use \\%HOST%\IPC$ /delete >nul 2>&1
    net use \\%HOST%\IPC$ /user:%USER_FOR_AUTH% "%PWD_SAFE%" /persistent:no
    set "RC=%ERRORLEVEL%"
    if %RC% NEQ 0 (
      echo [BATCH] Fallback to IPC$ FAILED (RC=%RC%). Output above shows the reason.
      echo [BATCH] Auth FAILED to \\%HOST%\IPC$ (RC=%RC%) >> "%LOGFILE%"
      exit /b %RC%
    ) else (
      echo [BATCH] Auth OK to \\%HOST%\IPC$ >> "%LOGFILE%"
      net use \\%HOST%\IPC$ /delete >nul 2>&1
      echo [BATCH] Batch script ran successfully >> "%LOGFILE%"
      exit /b 0
    )
  ) else (
    exit /b %RC%
  )
) else (
  echo [BATCH] Auth OK to \\%HOST%\%SHARE% >> "%LOGFILE%"
  net use \\%HOST%\%SHARE% /delete >nul 2>&1
  echo [BATCH] Batch script ran successfully >> "%LOGFILE%"
  exit /b 0
)
