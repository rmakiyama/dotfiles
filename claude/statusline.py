#!/usr/bin/env python3
"""Statusline: directory + branch on line 1, braille rate limits on line 2"""
import json, sys, os, subprocess

if sys.platform == 'win32':
    sys.stdout.reconfigure(encoding='utf-8')

data = json.load(sys.stdin)

BRAILLE = ' ⣀⣄⣤⣦⣶⣷⣿'
R = '\033[0m'
DIM = '\033[2m'


def gradient(pct):
    if pct < 50:
        r = int(pct * 5.1)
        return f'\033[38;2;{r};200;80m'
    else:
        g = int(200 - (pct - 50) * 4)
        return f'\033[38;2;255;{max(g, 0)};60m'


def braille_bar(pct, width=8):
    pct = min(max(pct, 0), 100)
    level = pct / 100
    bar = ''
    for i in range(width):
        seg_start = i / width
        seg_end = (i + 1) / width
        if level >= seg_end:
            bar += BRAILLE[7]
        elif level <= seg_start:
            bar += BRAILLE[0]
        else:
            frac = (level - seg_start) / (seg_end - seg_start)
            bar += BRAILLE[min(int(frac * 7), 7)]
    return bar


def fmt(emoji, label, pct):
    p = round(pct)
    return f'{emoji} {DIM}{label}{R} {gradient(pct)}{braille_bar(pct)}{R} {p}%'


# Line 1: directory + branch
cwd = data.get('cwd', os.getcwd())
dirname = os.path.basename(cwd)

try:
    branch = subprocess.check_output(
        ['git', 'rev-parse', '--abbrev-ref', 'HEAD'],
        cwd=cwd, stderr=subprocess.DEVNULL
    ).decode().strip()
except Exception:
    branch = ''

line1 = f'📁 {dirname}'
if branch:
    line1 += f' {DIM}|{R} 🌿 {branch}'

# Line 2: context, 5h, 7d
parts = []

ctx = data.get('context_window', {}).get('used_percentage')
if ctx is not None:
    parts.append(fmt('🧠', 'context', ctx))

five = data.get('rate_limits', {}).get('five_hour', {}).get('used_percentage')
if five is not None:
    parts.append(fmt('⏱', '5h', five))

week = data.get('rate_limits', {}).get('seven_day', {}).get('used_percentage')
if week is not None:
    parts.append(fmt('📅', '7d', week))

line2 = f' {DIM}│{R} '.join(parts) if parts else ''

if line2:
    print(f'{line1}\n{line2}', end='')
else:
    print(line1, end='')
