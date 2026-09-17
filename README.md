# Red Team Box

An AI-assisted offensive devcontainer for adversarial testing of the protected
container asset (`nmwael/protected-container-asset`). Agents run inside this
box and file every finding as a self-contained GitHub issue against the asset
repo using `gh`.

## Prerequisites

- GitHub Codespaces or a local devcontainer host with Docker
- `GH_TOKEN` with `issues:write` permission on the target repo
- Docker (the asset runs as a compose stack launched by the red team scripts)

## Quickstart

Boot the container, then run:

```
bash scripts/run-red.sh
```

The script orchestrates a full round: prep (bring the asset up), recon, exploit,
report. Each finding lands as a separate GitHub issue labelled `security` on
`$TARGET_ORG/$TARGET_REPO`.

## Round lifecycle

1. **prep** -- clone the asset repo (if needed), launch the local container,
   wait for healthz.
2. **recon** -- inventory endpoints, headers, versions, exposed paths.
3. **exploit** -- perform non-destructive proof-of-concept against the local
   container for each vuln id documented in `app/vulns/INTENT.md`.
4. **report** -- assemble per-finding issue bodies, check for duplicates, file
   via `gh issue create` after human confirmation.

## Scope

Only the local asset container and the asset repo are in scope. Host, cloud
account, other repos, GitHub itself, and other users are explicitly out of scope.

## References

- [runbook.md](runbook.md) -- human turn playbook
- Asset contract: `app/vulns/INTENT.md` in the protected container asset repo
