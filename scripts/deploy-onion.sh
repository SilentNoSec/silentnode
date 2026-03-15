#!/usr/bin/env bash
set -euo pipefail

REMOTE_USER="${REMOTE_USER:-user}"
REMOTE_HOST="${REMOTE_HOST:-your-vps-ip}"
REMOTE_PATH="${REMOTE_PATH:-/var/www/silentnode/public}"
LOCAL_PATH="public/"

if [ -z "$REMOTE_HOST" ] || [ "$REMOTE_HOST" = "your-vps-ip" ]; then
    echo "[ERROR] Set REMOTE_HOST environment variable to your VPS IP/hostname"
    exit 1
fi

echo "[*] Stripping metadata before deploy..."
bash scripts/strip-metadata.sh

echo "[*] Syncing files to onion mirror..."
rsync -avz --delete \
    --exclude '.git' \
    --exclude '.github' \
    --exclude '_headers' \
    -e "ssh -o StrictHostKeyChecking=accept-new" \
    "$LOCAL_PATH" "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}"

echo "[*] Deploy complete"
echo "[*] Verify: access your .onion address via Tor Browser"
