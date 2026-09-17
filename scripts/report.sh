#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REDTEAM_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
export REDTEAM_DIR

source "$SCRIPT_DIR/target-config.sh"

REPORT_DIR="${REPORT_DIR:-$FINDINGS_DIR}"

echo "=== Red team report ==="

ISSUES_FILED=0
ISSUES_SKIPPED=0

for finding in "$REPORT_DIR"/exploit-*.md; do
    [ -f "$finding" ] || continue

    # Extract title from first non-empty line after "# "
    TITLE=$(grep -m1 '^# ' "$finding" | sed 's/^# //')
    if [ -z "$TITLE" ]; then
        echo "SKIP: $finding -- no title found"
        continue
    fi

    # Check for duplicate open issues
    if gh issue list --repo "$TARGET" --state open --json title --jq '.[].title' 2>/dev/null | grep -qF "$TITLE"; then
        echo "SKIP (duplicate): $TITLE"
        ISSUES_SKIPPED=$((ISSUES_SKIPPED + 1))
        continue
    fi

    BODY=$(cat "$finding")

    echo ""
    echo "--- Issue: $TITLE ---"
    echo "gh issue create --repo \"$TARGET\" --title \"$TITLE\" --label security"
    echo ""

    # Human confirmation (or auto-skip in non-interactive mode)
    if [ -t 0 ]; then
        read -r -p "File this issue? [y/N]: " CONFIRM
    else
        echo "Non-interactive shell -- skipping issue filing"
        CONFIRM="n"
    fi

    if [ "$CONFIRM" = "y" ] || [ "$CONFIRM" = "Y" ]; then
        ISSUE_URL=$(gh issue create \
            --repo "$TARGET" \
            --title "$TITLE" \
            --body "$BODY" \
            --label security)
        echo "Filed: $ISSUE_URL"
        ISSUES_FILED=$((ISSUES_FILED + 1))
    else
        echo "Skipped by user"
        ISSUES_SKIPPED=$((ISSUES_SKIPPED + 1))
    fi
done

echo ""
echo "=== Report summary ==="
echo "Issues filed:   $ISSUES_FILED"
echo "Issues skipped: $ISSUES_SKIPPED"

if [ "$ISSUES_FILED" -eq 0 ] && [ "$ISSUES_SKIPPED" -eq 0 ]; then
    echo "No exploit findings to report"
fi
