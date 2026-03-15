#!/usr/bin/env bash
set -euo pipefail

echo "[*] Configuring anonymous git identity for this repository..."

git config user.name "anonymous"
git config user.email "silentnosec@proton.me"
git config core.eol lf
git config core.autocrlf input
git config commit.gpgsign false
git config log.showSignature false

echo "[*] Git config set:"
echo "    user.name  = $(git config user.name)"
echo "    user.email = $(git config user.email)"
echo "    core.eol   = $(git config core.eol)"

echo ""
echo "[*] REMINDER: Always commit via VPN/Tor"
echo "[*] REMINDER: Vary commit times to avoid temporal correlation"
echo "[*] Done"
