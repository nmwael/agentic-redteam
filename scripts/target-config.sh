#!/usr/bin/env bash
set -euo pipefail

TARGET_ORG="${TARGET_ORG:-nmwael}"
TARGET_REPO="${TARGET_REPO:-protected-container-asset}"
TARGET_BRANCH="${TARGET_BRANCH:-main}"
TARGET="${TARGET_ORG}/${TARGET_REPO}"
REDTEAM_DIR="${REDTEAM_DIR:-$PWD}"
FINDINGS_DIR="${REDTEAM_DIR}/findings"
CLONE_DIR="${REDTEAM_DIR}/asset-clone"

# Handle being sourced: return without killing the caller's shell.
# The constants above are defined before this guard so sourcing is safe.
[ "${BASH_SOURCE[0]}" = "$0" ] || return 0
exit 0