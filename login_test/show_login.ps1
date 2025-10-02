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
if (-not [string]::IsNullOrWhiteSpace($Domain) -and ($UserBase -notmatch '@')) {
  $User = "$Domain\$UserBase"
} else {
  $User = $UserBase
}

Write-Host "[PWSH] Local session user: $env:USERNAME"
$rootPath = "\\$HostName\$Share"
Write-Host "[PWSH] Testing SMB auth to: $rootPath as $User"

# Build credential safely
$sec  = ConvertTo-SecureString $Password -AsPlainText -Force
$cred = [System.Management.Automation.PSCredential]::new($User, $sec)

# Create a transient PSDrive and probe it
$driveName = "Auth$([guid]::NewGuid().ToString('N').Substring(0,6))"

try {
  $null = New-PSDrive -Name $driveName -PSProvider FileSystem -Root $rootPath -Credential $cred -ErrorAction Stop

  # IMPORTANT: use ${driveName}: to avoid parser error
  $driveRoot = "${driveName}:\"
  # Light probe that requires auth
  if (-not (Test-Path -LiteralPath $driveRoot)) {
    throw "Drive path not found: $driveRoot"
  }
  $null = Get-ChildItem -LiteralPath $driveRoot -Force -ErrorAction Stop | Select-Object -First 1

  Add-Content $LogFile "[PWSH] Auth OK to $rootPath"
  Add-Content $LogFile "[PWSH] PowerShell script ran successfully"
  Write-Host "[PWSH] Auth OK"
  exit 0
}
catch {
  Add-Content $LogFile "[PWSH] Auth FAILED to $rootPath : $($_.Exception.Message)"
  Write-Host "[PWSH] Auth FAILED: $($_.Exception.Message)"
  exit 1
}
finally {
  if (Get-PSDrive -Name $driveName -ErrorAction SilentlyContinue) {
    Remove-PSDrive -Name $driveName -Force -ErrorAction SilentlyContinue
  }
}
