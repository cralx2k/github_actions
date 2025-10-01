import getpass
import os

current_user = getpass.getuser()
if current_user == 'cralx2k':
    print(f"Welcome, {current_user}!")
else:
    print(f"You are logged in as {current_user}. Access denied.")
