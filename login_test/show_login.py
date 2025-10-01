import os

username = os.environ.get("USERNAME") or os.environ.get("USER") or os.getlogin()
print(f"Logged in as: {username}")
print("Login is working! Welcome, cralx2k.")