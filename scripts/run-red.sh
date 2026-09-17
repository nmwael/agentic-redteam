#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REDTEAM_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
export REDTEAM_DIR

source "$SCRIPT_DIR/target-config.sh"

R="$(date +%Y%m%d-%H%M)"
ROUND_DIR="$FINDINGS_DIR/R-${R}"
mkdir -p "$ROUND_DIR"
export FINDINGS_DIR="$ROUND_DIR"
export REPORT_DIR="$ROUND_DIR"

echo "============================================"
echo "  Red Team Round: $R"
echo "  Target: $TARGET"
echo "============================================"

# Ensure asset is up
echo ""
echo "--- Phase: prep ---"
bash "$SCRIPT_DIR/prep.sh"

# Recon phase
echo ""
echo "--- Phase: recon ---"
opencode run --agent recon \
    "Recon phase for round $R against $TARGET. Inventory all endpoints, headers, versions, and exposed paths on the local asset container. Write findings to $ROUND_DIR/recon-${R}.md."

# Exploit phase
echo ""
echo "--- Phase: exploit ---"
opencode run --agent exploit \
    "Exploit phase for round $R against $TARGET. Read INTENT.md from $CLONE_DIR/app/vulns/INTENT.md. For each vuln id, perform a non-destructive PoC against the local container, capture the flag, and write findings to $ROUND_DIR/exploit-<vulnid>.md."

# Report phase
echo ""
echo "--- Phase: report ---"
bash "$SCRIPT_DIR/report.sh"

echo ""
echo "============================================"
echo "  Round $R complete"
echo "  Findings in: $ROUND_DIR"
echo "============================================"
