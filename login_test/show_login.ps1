# login_test\show_login.ps1
$ErrorActionPreference = 'Stop'

$LogFile    = 'C:\temp\action_log\verify_login_script.txt'
$HostName   = if ([string]::IsNullOrWhiteSpace($env:TARGET_HOST)) { 'leaoserver' } else { $env:TARGET_HOST }
$Share      = if ([string]::IsNullOrWhiteSpace($env:TARGET_SHARE)) { 'IPC$' } else { $env:TARGET_SHARE }
$Domain     = $env:AUTH_DOMAIN
$UserBase   = $env:GHA_USERNAME
$Password   = $env:GHA_PASSWORD

if ([string]::IsNullOrWhiteSpace($UserBase)) { Add-Content $LogFile "[PWSH] ERROR: GHA_USERNAME not set"; exit 1 }
if ([string]::IsNullOrWhiteSpace($Password)) { Add-Content $LogFile "[PWSH] ERROR: GHA_PASSWORD not set"; exit 1 }

# Compose full username
# - If AUTH_DOMAIN provided -> DOMAIN\user
# - If username already looks like UPN (user@domain) -> use as-is
# - Else -> just the username
if (-not [string]::IsNullOrWhiteSpace($Domain) -and ($UserBase -notmatch '@')) {
  $User = "$Domain\$UserBase"
} else {
  $User = $UserBase
}

Write-Host "[PWSH] Local session user: $env:USERNAME"
Write-Host "[PWSH] Testing SMB auth to: \\$HostName\$Share as $User"

# Build credential safely (no cmd.exe quoting issues)
$sec = ConvertTo-SecureString $Password -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential($User, $sec)

# Use a transient PSDrive (non-persistent) to validate access
$driveName = "AuthTest$([System.Guid]::NewGuid().ToString('N').Substring(0,6))"
$rootPath  = "\\$HostName\$Share"

try {
  $null = New-PSDrive -Name $driveName -PSProvider FileSystem -Root $rootPath -Credential $cred -Scope Script -ErrorAction Stop
  # A simple probe that requires auth (listing root)
  $null = Get-ChildItem "$driveName:`\" -Force | Select-Object -First 1

  Add-Content $LogFile "[PWSH] Auth OK to $rootPath"
  Add-Content $LogFile "[PWSH] PowerShell script ran successfully"
  Write-Host "[PWSH] Auth OK"
  exit 0
}
catch {
  # Provide a concise failure line in the log; full detail goes to job output
  Add-Content $LogFile "[PWSH] Auth FAILED to $rootPath : $($_.Exception.Message)"
  Write-Host "[PWSH] Auth FAILED: $($_.Exception.Message)"
  exit 1
}
finally {
  # Cleanup the transient PSDrive
  if (Get-PSDrive -Name $driveName -ErrorAction SilentlyContinue) {
    Remove-PSDrive -Name $driveName -Scope Script -Force -ErrorAction SilentlyContinue
  }
}
