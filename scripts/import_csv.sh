#!/usr/bin/env bash
# =============================================================================
# AATK Smart Library — CSV Import Script
# Imports textbooks from data.csv into BookLore via the Physical Book API
# =============================================================================
set -euo pipefail

# ── Configuration ────────────────────────────────────────────────────────────
API_URL="${API_URL:-http://localhost:8080/api/v1}"
CSV_FILE="${1:-data.csv}"
LIBRARY_ID="${LIBRARY_ID:-1}"
AUTH_TOKEN="${AUTH_TOKEN:-}"
DELAY="${DELAY:-0.2}"

# ── Colours ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# ── Helpers ──────────────────────────────────────────────────────────────────
log_ok()   { echo -e "${GREEN}[OK]${NC}   $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_err()  { echo -e "${RED}[ERR]${NC}  $1"; }

if [[ ! -f "$CSV_FILE" ]]; then
  log_err "CSV file not found: $CSV_FILE"
  exit 1
fi

command -v python3 >/dev/null 2>&1 || { log_err "python3 is required"; exit 1; }
command -v curl    >/dev/null 2>&1 || { log_err "curl is required";    exit 1; }

# ── Auth header ──────────────────────────────────────────────────────────────
AUTH_HEADER=""
if [[ -n "$AUTH_TOKEN" ]]; then
  AUTH_HEADER="-H \"Authorization: Bearer ${AUTH_TOKEN}\""
fi

# ── Main import loop ─────────────────────────────────────────────────────────
TOTAL=0
SUCCESS=0
FAIL=0

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " AATK Smart Library — CSV Import"
echo " API:  $API_URL"
echo " File: $CSV_FILE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Use Python to parse CSV properly (handles quoted commas, multiline fields)
python3 -c "
import csv, json, sys

with open('${CSV_FILE}', mode='r', encoding='utf-8') as f:
    reader = csv.DictReader(f)
    for row in reader:
        title = (row.get('title') or '').strip()
        authors_raw = (row.get('authors') or '').strip()
        authors = [a.strip() for a in authors_raw.split(',') if a.strip()] if authors_raw else []
        grade_raw = (row.get('grade') or '').strip()
        grade = int(grade_raw) if grade_raw.isdigit() else None
        subject = (row.get('subject') or '').strip() or None
        publisher = (row.get('publisher') or '').strip() or None
        year = (row.get('year') or '').strip() or None
        language = (row.get('language') or '').split('/')[0].strip() or None
        description = (row.get('description') or '').strip()[:500] or None
        isbn = (row.get('isbn') or '').strip() or None

        payload = {
            'libraryId': ${LIBRARY_ID},
            'title': title,
            'authors': authors,
            'description': description,
            'publisher': publisher,
            'publishedDate': year,
            'language': language,
            'grade': grade,
            'subject': subject,
            'isbn': isbn
        }
        # Remove None values
        payload = {k: v for k, v in payload.items() if v is not None}
        print(json.dumps(payload, ensure_ascii=False))
" | while IFS= read -r json_payload; do
  TOTAL=$((TOTAL + 1))
  TITLE=$(echo "$json_payload" | python3 -c "import sys,json; print(json.load(sys.stdin).get('title','???'))")

  HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
    -X POST "${API_URL}/books/physical" \
    -H "Content-Type: application/json" \
    ${AUTH_HEADER} \
    -d "$json_payload" 2>/dev/null || echo "000")

  if [[ "$HTTP_CODE" == "200" || "$HTTP_CODE" == "201" ]]; then
    SUCCESS=$((SUCCESS + 1))
    log_ok "#${TOTAL} ${TITLE}"
  else
    FAIL=$((FAIL + 1))
    log_err "#${TOTAL} ${TITLE} (HTTP ${HTTP_CODE})"
  fi

  sleep "$DELAY"
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e " Import complete: ${GREEN}${SUCCESS} OK${NC} / ${RED}${FAIL} FAIL${NC} / Total: ${TOTAL}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
