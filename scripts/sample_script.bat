@echo off
REM Sample Batch script for GitHub Actions workflow

echo ==================================================
echo Running Batch Script
echo ==================================================

REM Get username and password from environment variables
if defined USERNAME_SECRET (
    echo Username: %USERNAME_SECRET%
) else (
    echo Username: Not set
)

if defined PASSWORD_SECRET (
    echo Password: ********
) else (
    echo Password: Not set
)

echo Batch script executed successfully!
echo ==================================================
