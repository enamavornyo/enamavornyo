#!/usr/bin/env bash
set -euo pipefail

EAV_ORG="${EAV_ORG:-eav-labs-dev}"
expected=(eav-insight-api eav-field-mobile eav-dispatch-service eav-ledger-api)

command -v gh >/dev/null || { echo "gh CLI is required" >&2; exit 1; }
gh auth status >/dev/null

mapfile -t repos < <(gh api --paginate "/orgs/${EAV_ORG}/repos?per_page=100&type=all" --jq '.[].name')

failed=0
for repo in "${expected[@]}"; do
  if printf '%s\n' "${repos[@]}" | grep -Fxq "$repo"; then
    default_branch="$(gh api "/repos/${EAV_ORG}/${repo}" --jq '.default_branch')"
    description="$(gh api "/repos/${EAV_ORG}/${repo}" --jq '.description // ""')"
    topics="$(gh api "/repos/${EAV_ORG}/${repo}/topics" --jq '.names | join(",")')"
    printf 'OK   %-24s default=%-8s topics=%s\n' "$repo" "$default_branch" "$topics"
    [[ "$default_branch" == "main" ]] || { echo "     expected default branch main"; failed=1; }
    [[ -n "$description" ]] || { echo "     missing description"; failed=1; }
  else
    echo "MISS ${repo}"
    failed=1
  fi
done

if [[ "$failed" -ne 0 ]]; then
  echo "Verification failed." >&2
  exit 1
fi

echo "Verification passed. All four EAV repositories were discovered across paginated responses and meet the checked presentation baseline."
