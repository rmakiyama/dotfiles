#!/usr/bin/env python3
"""Write fish's history to a new zsh history file, keeping the timestamps.

Usage: import-fish-history.py [FISH_HISTORY] [ZSH_HISTORY]
Defaults to ~/.local/share/fish/fish_history and ~/.zsh_history.
Refuses to overwrite an existing ZSH_HISTORY.
"""

import sys
from pathlib import Path

home = Path.home()
fish_history = Path(sys.argv[1]) if len(sys.argv) > 1 else home / ".local/share/fish/fish_history"
zsh_history = Path(sys.argv[2]) if len(sys.argv) > 2 else home / ".zsh_history"


def unescape_fish(s):
    # fish writes a backslash as \\ and a newline as \n
    out = []
    i = 0
    while i < len(s):
        if s[i] == "\\" and i + 1 < len(s) and s[i + 1] in "\\n":
            out.append("\\" if s[i + 1] == "\\" else "\n")
            i += 2
        else:
            out.append(s[i])
            i += 1
    return "".join(out)


def metafy(data):
    # zsh stores bytes 0x83-0xa2 as 0x83 followed by the byte xor 0x20
    out = bytearray()
    for b in data:
        if 0x83 <= b <= 0xA2:
            out += bytes([0x83, b ^ 0x20])
        else:
            out.append(b)
    return bytes(out)


entries = []
cmd = None
for line in fish_history.read_text(encoding="utf-8", errors="surrogateescape").splitlines():
    if line.startswith("- cmd: "):
        cmd = unescape_fish(line[len("- cmd: "):])
        entries.append([cmd, 0])
    elif line.startswith("  when: ") and entries:
        entries[-1][1] = int(line[len("  when: "):])

if zsh_history.exists():
    sys.exit(f"{zsh_history} already exists. Move it aside and rerun.")

entries.sort(key=lambda e: e[1])
with zsh_history.open("wb") as f:
    for cmd, when in entries:
        # zsh marks a newline inside a command with a backslash before it
        body = cmd.encode("utf-8", errors="surrogateescape").replace(b"\n", b"\\\n")
        f.write(f": {when}:0;".encode() + metafy(body) + b"\n")
zsh_history.chmod(0o600)
print(f"Wrote {len(entries)} commands to {zsh_history}")
