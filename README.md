# github_actions

This repository demonstrates GitHub Actions workflows that run Python, PowerShell, and Batch scripts with username and password secrets.

## Features

- **Python Script**: Runs on Ubuntu with Python 3.x
- **PowerShell Script**: Runs on Windows with PowerShell
- **Batch Script**: Runs on Windows with cmd.exe
- **Secrets Management**: Uses GitHub Secrets to securely pass username and password to scripts

## Setup

### Setting Up Secrets

To use this workflow, you need to configure the following secrets in your GitHub repository:

1. Go to your repository on GitHub
2. Click on **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add the following secrets:
   - `USERNAME`: Your username value
   - `PASSWORD`: Your password value

### Running the Workflow

The workflow runs automatically on:
- Push to `main` or `master` branch
- Pull requests to `main` or `master` branch
- Manual trigger via **Actions** tab → **Run Scripts with Secrets** → **Run workflow**

## Scripts

### Python Script (`scripts/sample_script.py`)
- Reads `USERNAME_SECRET` and `PASSWORD_SECRET` from environment variables
- Displays username and masked password
- Shows Python version

### PowerShell Script (`scripts/sample_script.ps1`)
- Reads `USERNAME_SECRET` and `PASSWORD_SECRET` from environment variables
- Displays username and masked password
- Shows PowerShell version

### Batch Script (`scripts/sample_script.bat`)
- Reads `USERNAME_SECRET` and `PASSWORD_SECRET` from environment variables
- Displays username and masked password

## Workflow Details

The workflow file is located at `.github/workflows/run-scripts.yml` and contains three jobs:

1. **run-python-script**: Executes the Python script on Ubuntu
2. **run-powershell-script**: Executes the PowerShell script on Windows
3. **run-batch-script**: Executes the Batch script on Windows

Each job:
- Checks out the repository
- Sets up the necessary environment (Python for Python script)
- Passes secrets as environment variables
- Runs the corresponding script

## Security Notes

- Secrets are never printed in logs
- Passwords are masked in script output
- GitHub automatically masks secret values in workflow logs