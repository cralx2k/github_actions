#!/usr/bin/env python3
"""Sample Python script for GitHub Actions workflow."""

import os
import sys

def main():
    print("=" * 50)
    print("Running Python Script")
    print("=" * 50)
    
    # Get username and password from environment variables
    username = os.environ.get('USERNAME_SECRET', 'Not set')
    password = os.environ.get('PASSWORD_SECRET', 'Not set')
    
    # Don't print actual password for security
    password_display = '*' * len(password) if password != 'Not set' else 'Not set'
    
    print(f"Username: {username}")
    print(f"Password: {password_display}")
    print(f"Python version: {sys.version}")
    print("Python script executed successfully!")
    print("=" * 50)

if __name__ == "__main__":
    main()
