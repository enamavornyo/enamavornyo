#!/usr/bin/env bash
set -euo pipefail

EAV_ORG="${EAV_ORG:-eav-labs-dev}"
DRY_RUN=true
[[ "${1:-}" == "--apply" ]] && DRY_RUN=false

repos=(eav-insight-api eav-field-mobile eav-dispatch-service eav-ledger-api)
descriptions=(
  "FastAPI service for document intake, operational reporting, and searchable business records."
  "Offline-first React Native app for field inspections, evidence capture, and synchronization."
  "Spring Boot service for shipments, assignments, delivery lifecycles, and auditable dispatch workflows."
  "Laravel API for customers, invoices, payments, receipts, and billing workflows."
)
topics=(
  "fastapi,python,postgresql,docker,rest-api,github-actions,eav-labs"
  "react-native,expo,typescript,offline-first,mobile,sqlite,eav-labs"
  "java,spring-boot,postgresql,docker,rest-api,logistics,eav-labs"
  "php,laravel,postgresql,rest-api,billing,eav-labs"
)

command -v gh >/dev/null || { echo "gh CLI is required" >&2; exit 1; }
gh auth status >/dev/null

for i in "${!repos[@]}"; do
  repo="${repos[$i]}"
  echo "${DRY_RUN:+[preview] }${EAV_ORG}/${repo}"
  echo "  description: ${descriptions[$i]}"
  echo "  topics: ${topics[$i]}"
  if [[ "$DRY_RUN" == false ]]; then
    gh repo edit "${EAV_ORG}/${repo}" --description "${descriptions[$i]}"
    IFS=',' read -ra topic_list <<< "${topics[$i]}"
    args=()
    for topic in "${topic_list[@]}"; do args+=(--add-topic "$topic"); done
    gh repo edit "${EAV_ORG}/${repo}" "${args[@]}"
  fi
done

if [[ "$DRY_RUN" == true ]]; then
  echo
  echo "No changes applied. Re-run with --apply after reviewing this output."
fi
