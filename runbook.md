# Red Team Runbook

Human-in-the-loop playbook for running an offensive round.

## Steps

1. **Boot** the box in CLOUD_MODE (default). Ensure `GH_TOKEN` is available.
2. **Run** `bash scripts/run-red.sh`. The script brings the asset up, runs
   recon, exploit, and report phases.
3. **Review** the generated issue list printed at the end of the run.
4. **Verify** each issue was filed correctly against the target repo by checking
   the printed URLs.
5. **Regression** -- when the blue team has mitigated a finding, re-run the
   round. The reporter skips issues that already exist (by title match). Confirm
   the vuln is gone and stop re-reporting closed findings.

## Finding fields

Every issue must contain:

- **Title** -- short descriptive name
- **Vuln ID** -- identifier from `app/vulns/INTENT.md`
- **Severity** -- critical / high / medium / low / informational
- **Reproduction steps** -- numbered steps against the local container
- **Proof / flag** -- concrete evidence (response body, header, flag string)
- **Suggested remediation** -- how the blue team should fix it

## Scope rules

- Asset-local only: attack the running container and the asset repo source.
- Non-destructive proofs of concept. No credential theft, no exfiltration
  beyond the flag mechanism, no denial of service.
- Read-only access to the asset repo. Never push or commit to it.
- One finding = one issue. No duplicates (check open issues first).
- No real secrets. No production credentials. No attacking anything outside
  the defined scope.

## HITL contract

The reporter script asks for human confirmation before filing each issue.
Agents produce findings and draft issue bodies; the human approves each one
before it is submitted via `gh issue create`.
