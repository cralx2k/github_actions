$ErrorActionPreference = 'Stop'
$LogFile    = 'C:\temp\action_log\verify_login_script.txt'
$HostName   = if ([string]::IsNullOrWhiteSpace($env:TARGET_HOST)) { 'leaoserver' } else { $env:TARGET_HOST }
$Share      = if ([string]::IsNullOrWhiteSpace($env:TARGET_SHARE)) { 'IPC$' } else { $env:TARGET_SHARE }
$Domain     = $env:AUTH_DOMAIN
$UserBase   = $env:GHA_USERNAME
$Password   = $env:GHA_PASSWORD

if ([string]::IsNullOrWhiteSpace($UserBase)) { Add-Content $LogFile "[PWSH] ERROR: GHA_USERNAME not set"; throw "GHA_USERNAME not set" }
if ([string]::IsNullOrWhiteSpace($Password)) { Add-Content $LogFile "[PWSH] ERROR: GHA_PASSWORD not set"; throw "GHA_PASSWORD not set" }

$User = if ([string]::IsNullOrWhiteSpace($Domain)) { $UserBase } else { "$Domain\$UserBase" }

Write-Host "[PWSH] Local session user: $env:USERNAME"
Write-Host "[PWSH] Testing SMB auth to: \\$HostName\$Share as $User"

# Clear any stale mapping
cmd /c "net use \\$HostName\$Share /delete" | Out-Null

# Map the share (non-persistent)
$rc = (cmd /c "net use \\$HostName\$Share /user:$User $Password /persistent:no" ; echo $LASTEXITCODE) | Select-Object -Last 1
if ($rc -ne 0) {
  Add-Content $LogFile "[PWSH] Auth FAILED to \\$HostName\$Share (RC=$rc)"
  Write-Host "[PWSH] Auth FAILED (RC=$rc)"
  exit $rc
}

# Cleanup mapping
cmd /c "net use \\$HostName\$Share /delete" | Out-Null

Add-Content $LogFile "[PWSH] Auth OK to \\$HostName\$Share"
Add-Content $LogFile "[PWSH] PowerShell script ran successfully"
Write-Host "[PWSH] Auth OK"
