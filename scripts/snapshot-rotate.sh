#!/usr/bin/env bash
# Snapshot an instance and keep only the newest N snapshots created by this script.
# Usage: ./snapshot-rotate.sh <instance> [keep=7]
# Cron example (daily 03:15): 15 3 * * * /opt/incus-examples/scripts/snapshot-rotate.sh web-01 7
set -euo pipefail

inst=${1:?instance required}
keep=${2:-7}
prefix="auto-"

incus snapshot create "$inst" "${prefix}$(date +%Y%m%d-%H%M%S)"

mapfile -t snaps < <(incus query "/1.0/instances/${inst}/snapshots?recursion=1" \
  | python3 -c 'import json,sys; [print(s["name"]) for s in sorted(json.load(sys.stdin), key=lambda s: s["created_at"])]' \
  | grep "^${prefix}" || true)

excess=$(( ${#snaps[@]} - keep ))
for ((i=0; i<excess; i++)); do
  echo "Deleting old snapshot ${snaps[$i]}"
  incus snapshot delete "$inst" "${snaps[$i]}"
done
echo "Done. Kept $(( ${#snaps[@]} < keep ? ${#snaps[@]} : keep )) snapshots."
