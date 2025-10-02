# login_test\show_login.ps1
$ErrorActionPreference = 'Stop'

$LogFile    = 'C:\temp\action_log\verify_login_script.txt'
$HostName   = if ([string]::IsNullOrWhiteSpace($env:TARGET_HOST)) { 'leaoserver' } else { $env:TARGET_HOST }
$Share      = if ([string]::IsNullOrWhiteSpace($env:TARGET_SHARE)) { 'IPC$' } else { $env:TARGET_SHARE }
$Domain     = $env:AUTH_DOMAIN
$UserBase   = $env:GHA_USERNAME
$Password   = $env:GHA_PASSWORD

if ([string]::IsNullOrWhiteSpace($UserBase)) { Add-Content $LogFile "[POWERSHELL] ERROR: GHA_USERNAME not set"; exit 1 }
if ([string]::IsNullOrWhiteSpace($Password)) { Add-Content $LogFile "[POWERSHELL] ERROR: GHA_PASSWORD not set"; exit 1 }

# Compose full username
if (-not [string]::IsNullOrWhiteSpace($Domain) -and ($UserBase -notmatch '@')) {
  $User = "$Domain\$UserBase"
} else {
  $User = $UserBase
}

Write-Host "[POWERSHELL] Local session user: $env:USERNAME"
$rootPath = "\\$HostName\$Share"
Write-Host "[POWERSHELL] Testing SMB auth to: $rootPath as $User"

if ($Share -ieq 'IPC$') {
  # ---- IPC$ path: use cmdkey + probe (PSDrive won't work on IPC$) ----
  try {
    # Stage credentials
    & cmdkey.exe /add:$HostName /user:$User /pass:$Password | Out-Null

    # Lightweight probe that requires auth
    $probe = & cmd.exe /c "dir \\$HostName\IPC$" 2>&1
    if ($LASTEXITCODE -ne 0) {
      Add-Content $LogFile "[POWERSHELL] Auth FAILED to \\$HostName\IPC$ (RC=$LASTEXITCODE) : $probe"
      Write-Host  "[POWERSHELL] Auth FAILED (RC=$LASTEXITCODE)"
      exit $LASTEXITCODE
    }

    Add-Content $LogFile "[POWERSHELL] Auth OK to \\$HostName\IPC$"
    Add-Content $LogFile "[POWERSHELL] PowerShell script ran successfully"
    Write-Host  "[POWERSHELL] Auth OK"
    exit 0
  }
  finally {
    & cmdkey.exe /delete:$HostName | Out-Null
  }
}
else {
  # ---- Real share path: use PSDrive + PSCredential ----
  $sec  = ConvertTo-SecureString $Password -AsPlainText -Force
  $cred = [System.Management.Automation.PSCredential]::new($User, $sec)

  $driveName = "Auth$([guid]::NewGuid().ToString('N').Substring(0,6))"
  try {
    $null = New-PSDrive -Name $driveName -PSProvider FileSystem -Root $rootPath -Credential $cred -ErrorAction Stop
    $driveRoot = "${driveName}:\"
    if (-not (Test-Path -LiteralPath $driveRoot)) {
      throw "Drive path not found: $driveRoot"
    }
    # Simple read probe
    $null = Get-ChildItem -LiteralPath $driveRoot -Force -ErrorAction Stop | Select-Object -First 1

    Add-Content $LogFile "[POWERSHELL] Auth OK to $rootPath"
    Add-Content $LogFile "[POWERSHELL] PowerShell script ran successfully"
    Write-Host  "[POWERSHELL] Auth OK"
    exit 0
  }
  catch {
    Add-Content $LogFile "[POWERSHELL] Auth FAILED to $rootPath : $($_.Exception.Message)"
    Write-Host  "[POWERSHELL] Auth FAILED: $($_.Exception.Message)"
    exit 1
  }
  finally {
    if (Get-PSDrive -Name $driveName -ErrorAction SilentlyContinue) {
      Remove-PSDrive -Name $driveName -Force -ErrorAction SilentlyContinue
    }
  }
}
