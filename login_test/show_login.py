import os
import subprocess
import sys
from pathlib import Path

LOGFILE = Path(r"C:\temp\action_log\verify_login_script.txt")
LOGFILE.parent.mkdir(parents=True, exist_ok=True)

host = os.environ.get("TARGET_HOST") or "leaoserver"
u = os.environ.get("GHA_USERNAME")
p = os.environ.get("GHA_PASSWORD")

if not u or not p:
    with LOGFILE.open("a", encoding="utf-8") as f:
        if not u:
            f.write("[PY] ERROR: GHA_USERNAME not set\n")
        if not p:
            f.write("[PY] ERROR: GHA_PASSWORD not set\n")
    sys.exit(1)

print(f"[PY] Local session user: {os.environ.get('USERNAME') or os.environ.get('USER')}")
print(f"[PY] Testing network auth to: \\\\{host}\\IPC$")

def run(cmd):
    return subprocess.run(cmd, capture_output=True, text=True, shell=True)

# stage creds
run(f'cmdkey /add:{host} /user:{u} /pass:{p}')

# probe IPC$
probe = run(f'dir \\\\{host}\\IPC$')

# cleanup creds
run(f'cmdkey /delete:{host}')

if probe.returncode != 0:
    with LOGFILE.open("a", encoding="utf-8") as f:
        f.write(f"[PY] Auth FAILED to \\\\{host}\\IPC$\n")
    print("[PY] Auth FAILED")
    sys.exit(1)

with LOGFILE.open("a", encoding="utf-8") as f:
    f.write(f"[PY] Auth OK to \\\\{host}\\IPC$\n")
    f.write("Python script ran successfully\n")

print("[PY] Auth OK")
