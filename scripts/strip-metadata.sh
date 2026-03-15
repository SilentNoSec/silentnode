#!/usr/bin/env bash
set -euo pipefail

TARGET_DIR="${1:-public/images}"

if ! command -v exiftool &> /dev/null; then
    echo "[ERROR] exiftool is not installed"
    exit 1
fi

if [ ! -d "$TARGET_DIR" ]; then
    echo "[*] Directory not found: $TARGET_DIR — skipping"
    exit 0
fi

echo "[*] Stripping metadata from all files in: $TARGET_DIR"

find "$TARGET_DIR" -type f \( \
    -iname "*.jpg" -o \
    -iname "*.jpeg" -o \
    -iname "*.png" -o \
    -iname "*.webp" -o \
    -iname "*.gif" -o \
    -iname "*.svg" -o \
    -iname "*.pdf" \
\) -exec exiftool -all= -overwrite_original {} \;

echo "[*] Verification:"
exiftool -r "$TARGET_DIR" 2>/dev/null | grep -E "^(File Name|GPS|Author|Creator|Producer|Camera|Software)" || echo "[OK] No identifying metadata found"

echo "[*] Done"
