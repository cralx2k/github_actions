$ErrorActionPreference = 'Stop'
$LogFile  = 'C:\temp\action_log\verify_login_script.txt'
$HostName = if ([string]::IsNullOrWhiteSpace($env:TARGET_HOST)) { 'leaoserver' } else { $env:TARGET_HOST }

if ([string]::IsNullOrWhiteSpace($env:GHA_USERNAME)) { Add-Content $LogFile "[PWSH] ERROR: GHA_USERNAME not set"; throw "GHA_USERNAME not set" }
if ([string]::IsNullOrWhiteSpace($env:GHA_PASSWORD)) { Add-Content $LogFile "[PWSH] ERROR: GHA_PASSWORD not set"; throw "GHA_PASSWORD not set" }

Write-Host "[PWSH] Local session user: $env:USERNAME"
Write-Host "[PWSH] Testing network auth to: \\$HostName\IPC$"

# stage creds
cmdkey.exe /add:$HostName /user:$env:GHA_USERNAME /pass:$env:GHA_PASSWORD | Out-Null

try {
  if (Test-Path "\\$HostName\IPC$") {
    Add-Content $LogFile "[PWSH] Auth OK to \\$HostName\IPC$"
    Write-Host "[PWSH] Auth OK"
  } else {
    Add-Content $LogFile "[PWSH] Auth FAILED to \\$HostName\IPC$"
    Write-Host "[PWSH] Auth FAILED"
    exit 1
  }
}
finally {
  cmdkey.exe /delete:$HostName | Out-Null
}

Add-Content $LogFile "[PWSH] PowerShell script ran successfully"
