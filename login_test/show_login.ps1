$Username = $env:USERNAME
Write-Host "Logged in as: $Username"
Write-Host "Login is working! Welcome, cralx2k."
"PowerShell script ran successfully" | Out-File -Append C:\temp\verify_login_script.txt
Pause
