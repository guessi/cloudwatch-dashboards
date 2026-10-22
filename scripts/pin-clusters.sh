#!/usr/bin/env bash
#
# Fill eks/eks-control-plane-dashboard-pinned.json with your region and clusters.
#
# Usage:
#   scripts/pin-clusters.sh <region> <cluster-name>... > dashboard.json
#
# Example:
#   scripts/pin-clusters.sh us-east-1 my-prod-cluster my-staging-cluster > dashboard.json

set -euo pipefail

if [ $# -lt 2 ]; then
  echo "usage: $0 <region> <cluster-name>..." >&2
  exit 2
fi

region=$1
shift

template="$(dirname "$0")/../eks/eks-control-plane-dashboard-pinned.json"

jq --arg region "$region" '
  .variables |= map(
    if .property == "region" then
      .defaultValue = $region
    elif .property == "ClusterName" then
      .values = [$ARGS.positional[] | {value: .}]
      | .defaultValue = $ARGS.positional[0]
    else
      .
    end
  )
' "$template" --args "$@"
