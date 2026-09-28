#!/usr/bin/env bash
set -euo pipefail

PERSONAL_OWNER="${PERSONAL_OWNER:-enamavornyo}"
EAV_ORG="${EAV_ORG:-eav-labs-dev}"

command -v gh >/dev/null || { echo "gh CLI is required" >&2; exit 1; }
gh auth status >/dev/null

echo "== Personal repositories =="
gh api --paginate "/users/${PERSONAL_OWNER}/repos?per_page=100&type=owner" --jq '.[] | [.name,.visibility,.default_branch,(.archived|tostring)] | @tsv'

echo
echo "== EAV Labs repositories =="
gh api --paginate "/orgs/${EAV_ORG}/repos?per_page=100&type=all" --jq '.[] | [.name,.visibility,.default_branch,(.archived|tostring),(.description // "")] | @tsv'

echo
echo "== EAV Labs topics =="
while IFS= read -r repo; do
  printf '%s\t' "$repo"
  gh api "/repos/${EAV_ORG}/${repo}/topics" --jq '.names | join(",")'
done < <(gh api --paginate "/orgs/${EAV_ORG}/repos?per_page=100&type=all" --jq '.[].name')

echo
echo "== Profile files =="
gh api "/repos/${PERSONAL_OWNER}/${PERSONAL_OWNER}/contents/README.md" --jq '"personal README: " + .html_url'
if gh api "/repos/${EAV_ORG}/.github/contents/profile/README.md" --silent 2>/dev/null; then
  echo "organization README: present"
else
  echo "organization README: missing (.github repository/profile/README.md required)"
fi
