import os

username = os.environ.get("USERNAME") or os.environ.get("USER") or os.getlogin()
message = f"Logged in as: {username}\nLogin is working! Welcome, cralx2k.\n"
print(message)
with open(r"C:\temp\verify_login_script.txt", "a") as f:
    f.write("Python script ran successfully\n")
