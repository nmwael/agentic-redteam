#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REDTEAM_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
export REDTEAM_DIR

source "$SCRIPT_DIR/target-config.sh"

echo "=== Red team prep ==="

# Step 1: Overwrite workspace AGENTS.md with the red team rules
if [ -f "$REDTEAM_DIR/.devcontainer/team/AGENTS.md" ]; then
    cp -f "$REDTEAM_DIR/.devcontainer/team/AGENTS.md" "$REDTEAM_DIR/AGENTS.md"
    echo "AGENTS.md overwritten with red team rules"
fi

# Step 2: Copy custom role files into workspace .opencode/agent/
mkdir -p "$REDTEAM_DIR/.opencode/agent"
for f in "$REDTEAM_DIR/.devcontainer/team/.opencode/agent"/*.md; do
    [ -f "$f" ] && cp -f "$f" "$REDTEAM_DIR/.opencode/agent/"
done
echo "Custom agent roles installed"

# Step 3: Copy custom team library books into workspace
if [ -d "$REDTEAM_DIR/.devcontainer/team/library" ]; then
    mkdir -p "$REDTEAM_DIR/library"
    cp -rf "$REDTEAM_DIR/.devcontainer/team/library/"* "$REDTEAM_DIR/library/"
    echo "Custom red-team library books installed"
fi

# Step 4: Clone asset repo if not already present
if [ ! -d "$CLONE_DIR/.git" ]; then
    echo "Cloning asset repo to $CLONE_DIR ..."
    git clone --depth 1 "https://github.com/${TARGET}.git" "$CLONE_DIR"
else
    echo "Asset clone already present at $CLONE_DIR"
fi

# Step 5: Bring up the local asset container
if [ -f "$CLONE_DIR/app/docker-compose.yml" ]; then
    echo "Starting local asset container ..."
    cd "$CLONE_DIR"
    docker compose -f app/docker-compose.yml up -d
    cd "$REDTEAM_DIR"

    # Wait for healthz (max 60s)
    echo "Waiting for asset healthz ..."
    HEALTH_PORT="${HEALTH_PORT:-8080}"
    ELAPSED=0
    while [ "$ELAPSED" -lt 60 ]; do
        if curl -sf "http://localhost:${HEALTH_PORT}/healthz" >/dev/null 2>&1; then
            echo "Asset healthy after ${ELAPSED}s"
            break
        fi
        sleep 2
        ELAPSED=$((ELAPSED + 2))
    done
    if [ "$ELAPSED" -ge 60 ]; then
        echo "WARNING: asset not healthy after 60s -- continuing anyway"
    fi
else
    echo "WARNING: no docker-compose.yml found in asset clone"
fi

echo "=== Prep complete ==="
