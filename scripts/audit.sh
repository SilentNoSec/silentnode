#!/usr/bin/env bash
set -euo pipefail

ERRORS=0
PUBLIC_DIR="${1:-public}"

echo "=== SilentNode Privacy Audit ==="
echo ""

echo "[1] Checking for HTML comments..."
if grep -rn '<!--' "$PUBLIC_DIR"/*.html 2>/dev/null | grep -v 'DOCTYPE'; then
    echo "    [FAIL] HTML comments found"
    ERRORS=$((ERRORS + 1))
else
    echo "    [PASS] No HTML comments"
fi

echo ""
echo "[2] Checking for meta author/generator..."
if grep -rni 'meta.*name=.\(author\|generator\)' "$PUBLIC_DIR"/*.html 2>/dev/null; then
    echo "    [FAIL] Meta author/generator tags found"
    ERRORS=$((ERRORS + 1))
else
    echo "    [PASS] No meta author/generator"
fi

echo ""
echo "[3] Checking for third-party URLs..."
if grep -rnoE 'https?://[^"'"'"' ]+' "$PUBLIC_DIR"/*.html 2>/dev/null | grep -v 'silentnode.example' | grep -v 'protonmail.com'; then
    echo "    [WARN] External URLs found (review manually)"
else
    echo "    [PASS] No unexpected external URLs"
fi

echo ""
echo "[4] Checking for Google Fonts / CDN references..."
if grep -rni 'fonts.googleapis\|cdnjs\|unpkg\|jsdelivr\|ajax.googleapis\|facebook\|google-analytics\|googletagmanager' "$PUBLIC_DIR" 2>/dev/null; then
    echo "    [FAIL] Third-party CDN/font references found"
    ERRORS=$((ERRORS + 1))
else
    echo "    [PASS] No third-party CDN references"
fi

echo ""
echo "[5] Checking for tracking pixels..."
if grep -rni 'width="1".*height="1"\|1x1\|beacon\|pixel' "$PUBLIC_DIR" 2>/dev/null; then
    echo "    [FAIL] Possible tracking pixels found"
    ERRORS=$((ERRORS + 1))
else
    echo "    [PASS] No tracking pixels"
fi

echo ""
echo "[6] Checking for cookie-setting code..."
if grep -rni 'document.cookie\|Set-Cookie\|localStorage\|sessionStorage\|indexedDB' "$PUBLIC_DIR" 2>/dev/null; then
    echo "    [FAIL] Cookie/storage references found"
    ERRORS=$((ERRORS + 1))
else
    echo "    [PASS] No cookie/storage usage"
fi

echo ""
echo "[7] Checking for WebRTC / geolocation / camera references..."
if grep -rni 'getUserMedia\|RTCPeerConnection\|navigator.geolocation\|navigator.getBattery' "$PUBLIC_DIR" 2>/dev/null; then
    echo "    [FAIL] Invasive Web API references found"
    ERRORS=$((ERRORS + 1))
else
    echo "    [PASS] No invasive Web APIs"
fi

echo ""
echo "[8] Checking for prefetch/preconnect to external domains..."
if grep -rni 'rel="prefetch"\|rel="preconnect"\|rel="dns-prefetch"' "$PUBLIC_DIR"/*.html 2>/dev/null; then
    echo "    [FAIL] Prefetch/preconnect found"
    ERRORS=$((ERRORS + 1))
else
    echo "    [PASS] No prefetch/preconnect"
fi

echo ""
echo "[9] Checking _headers file..."
if [ -f "$PUBLIC_DIR/_headers" ]; then
    if grep -q "script-src 'none'" "$PUBLIC_DIR/_headers" && \
       grep -q "no-referrer" "$PUBLIC_DIR/_headers" && \
       grep -q "interest-cohort=()" "$PUBLIC_DIR/_headers"; then
        echo "    [PASS] Security headers configured"
    else
        echo "    [FAIL] Missing critical headers"
        ERRORS=$((ERRORS + 1))
    fi
else
    echo "    [FAIL] _headers file not found"
    ERRORS=$((ERRORS + 1))
fi

echo ""
echo "[10] Checking for image metadata..."
if command -v exiftool &> /dev/null; then
    METADATA=$(exiftool -r "$PUBLIC_DIR/images" 2>/dev/null | grep -E "^(GPS|Author|Creator|Camera|Software)" || true)
    if [ -n "$METADATA" ]; then
        echo "    [FAIL] Identifying metadata found in images:"
        echo "$METADATA"
        ERRORS=$((ERRORS + 1))
    else
        echo "    [PASS] No identifying image metadata"
    fi
else
    echo "    [SKIP] exiftool not installed"
fi

echo ""
echo "==========================="
if [ $ERRORS -eq 0 ]; then
    echo "[RESULT] ALL CHECKS PASSED"
    exit 0
else
    echo "[RESULT] $ERRORS CHECK(S) FAILED"
    exit 1
fi
