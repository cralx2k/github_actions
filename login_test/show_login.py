import os, subprocess, sys
from pathlib import Path

LOGFILE = Path(r"C:\temp\action_log\verify_login_script.txt")
LOGFILE.parent.mkdir(parents=True, exist_ok=True)

host   = os.environ.get("TARGET_HOST") or "leaoserver"
share  = os.environ.get("TARGET_SHARE") or "IPC$"
domain = os.environ.get("AUTH_DOMAIN") or ""
user   = os.environ.get("GHA_USERNAME")
pwd    = os.environ.get("GHA_PASSWORD")

if not user or not pwd:
    with LOGFILE.open("a", encoding="utf-8") as f:
        if not user: f.write("[PY] ERROR: GHA_USERNAME not set\n")
        if not pwd:  f.write("[PY] ERROR: GHA_PASSWORD not set\n")
    sys.exit(1)

user_for_auth = f"{domain}\\{user}" if domain else user
print(f"[PY] Local session user: {os.environ.get('USERNAME') or os.environ.get('USER')}")
print(f"[PY] Testing SMB auth to: \\\\{host}\\{share} as {user_for_auth}")

def run(cmd):
    return subprocess.run(cmd, capture_output=True, text=True, shell=True)

# Clear stale mapping
run(f'net use \\\\{host}\\{share} /delete')

# Map (non-persistent)
map_res = run(f'net use \\\\{host}\\{share} /user:{user_for_auth} {pwd} /persistent:no')
rc = map_res.returncode

if rc != 0:
    with LOGFILE.open("a", encoding="utf-8") as f:
        f.write(f"[PY] Auth FAILED to \\\\{host}\\{share} (RC={rc})\n")
    print(f"[PY] Auth FAILED (RC={rc})")
    sys.exit(rc)

# Cleanup
run(f'net use \\\\{host}\\{share} /delete')

with LOGFILE.open("a", encoding="utf-8") as f:
    f.write(f"[PY] Auth OK to \\\\{host}\\{share}\n")
    f.write("Python script ran successfully\n")

print("[PY] Auth OK")
