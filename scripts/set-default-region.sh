#!/usr/bin/env bash
#
# Set the region that eks/eks-control-plane-dashboard.json opens with.
# The Region dropdown still lets you switch to any other region.
#
# Usage:
#   scripts/set-default-region.sh <region> > dashboard.json
#
# Example:
#   scripts/set-default-region.sh ap-northeast-1 > dashboard.json

set -euo pipefail

if [ $# -ne 1 ]; then
  echo "usage: $0 <region>" >&2
  exit 2
fi

template="$(dirname "$0")/../eks/eks-control-plane-dashboard.json"

jq --arg region "$1" '
  .variables |= map(
    if .property == "region" then
      if any(.values[]; .value == $region) then
        .defaultValue = $region
      else
        "error: \($region) is not in the Region dropdown list\n" | halt_error(1)
      end
    else
      .
    end
  )
' "$template"
