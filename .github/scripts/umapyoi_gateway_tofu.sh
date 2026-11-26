#!/usr/bin/env bash
# Called from the FRP OpenTofu stack after Azure OIDC login.
set -euo pipefail
umask 077
case "$OPERATION" in
  plan)
    : "${GATEWAY_TFVARS_JSON:?Set UMAPYOI_GATEWAY_TFVARS_JSON in the prod environment}"
    PLAN_ID="$GITHUB_RUN_ID-$GITHUB_RUN_ATTEMPT"
    ;;
  deploy)
    if [[ ! $PLAN_ID =~ ^[1-9][0-9]*-[1-9][0-9]*$ ]]; then
      echo "Enter the reviewed plan ID (run-attempt), for example 12345-1." >&2
      exit 1
    fi
    ;;
  *) echo "Unknown gateway operation" >&2; exit 1 ;;
esac

scratch=$(mktemp -d "$RUNNER_TEMP/frp-plan.XXXXXXXX")
trap 'rm -f -- "$scratch/gateway.tfplan" "$scratch/inputs.tfvars.json"; rmdir -- "$scratch"' EXIT
plan="$scratch/gateway.tfplan"
blob="umapyoi-frp-plans/$GITHUB_SHA/$PLAN_ID.tfplan"
storage=(--auth-mode login --account-name acmhybridstore --container-name acm-terraform-state --name "$blob" --only-show-errors)

tofu init -input=false -lockfile=readonly
if [[ $OPERATION == plan ]]; then
  tofu workspace select -or-create prod
  printf '%s\n' "$GATEWAY_TFVARS_JSON" > "$scratch/inputs.tfvars.json"
  tofu plan -input=false -lock-timeout=5m -no-color -var-file="$scratch/inputs.tfvars.json" -out="$plan" >/dev/null
  az storage blob upload "${storage[@]}" --file "$plan" --overwrite false --output none
  {
    echo "Gateway plan \`$PLAN_ID\` for commit \`$GITHUB_SHA\`"
    echo
    echo 'Resource changes'
    echo '~~~'
    tofu show -json "$plan" | jq -r '.resource_changes[]? | select(.change.actions != ["no-op"]) | "\(.change.actions | join("/"))  \(.address)"'
    echo '~~~'
    echo "Full plan in private state storage: \`$blob\`."
  } >> "$GITHUB_STEP_SUMMARY"
else
  tofu workspace select prod
  az storage blob download "${storage[@]}" --file "$plan" --output none
  tofu apply -input=false -lock-timeout=5m -no-color "$plan"
  az storage blob delete "${storage[@]}" --output none ||
    echo "::warning::Applied the gateway plan. Remove the used plan from private storage: $blob"
fi
