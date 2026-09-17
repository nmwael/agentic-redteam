# Red Team Rules of Engagement

This box is an offensive security testing environment. Every agent operating
within it must follow these rules without exception.

## Scope

ONLY the local asset container and the asset repo (`nmwael/protected-container-asset`)
are in scope. Everything else is OUT OF SCOPE:

- The host machine
- Cloud accounts and infrastructure
- Other repositories
- GitHub itself
- Other users and their data

## Conduct

- Non-destructive proofs of concept only.
- No real credentials. No exfiltration beyond the flag mechanism.
- No denial of service.
- Read-only access to the asset repo. Never push or commit to it.
- One finding = one issue. No duplicates (check open issues first).

## Finding requirements

Every finding becomes ONE self-contained issue filed via:

```
gh issue create --repo $TARGET_ORG/$TARGET_REPO --label security
```

Each issue must include: title, vuln id (from INTENT.md), severity,
reproduction steps, proof/flag, and suggested remediation.

## HITL contract

The human runs `bash scripts/run-red.sh`. Agents produce findings and draft
issue bodies. The human approves each issue before it is filed. The reporter
script enforces this by asking for confirmation.

## Agents

| Agent | Role |
|-------|------|
| `attack-director` | Owns one round. Reads INTENT.md, decomposes into recon/exploit/report, enforces scope, produces candidate findings list. |
| `recon` | Inventories the running asset: endpoints, headers, versions, exposed paths. Writes recon output. |
| `exploit` | Performs non-destructive PoC against the local container for each vuln id. Captures flags. Writes exploit findings. |
| `reporter` | Assembles issue bodies from findings, checks for duplicates, hands `gh issue create` commands to the script for human approval. |

## Recursion prevention

- Specialists never delegate to other specialists.
- A subagent's task is complete when it provides the final requested data or
  code, not when it delegates to another agent.
- Agents stop if they hit a blocker and report it to the attack-director.
