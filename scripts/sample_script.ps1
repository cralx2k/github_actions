# Sample PowerShell script for GitHub Actions workflow

Write-Host "=" * 50
Write-Host "Running PowerShell Script"
Write-Host "=" * 50

# Get username and password from environment variables
$username = $env:USERNAME_SECRET
if ([string]::IsNullOrEmpty($username)) {
    $username = "Not set"
}

$password = $env:PASSWORD_SECRET
if ([string]::IsNullOrEmpty($password)) {
    $passwordDisplay = "Not set"
} else {
    $passwordDisplay = "*" * $password.Length
}

Write-Host "Username: $username"
Write-Host "Password: $passwordDisplay"
Write-Host "PowerShell version: $($PSVersionTable.PSVersion)"
Write-Host "PowerShell script executed successfully!"
Write-Host "=" * 50
