#!/usr/bin/env bash
# Launch an Incus instance with extra profiles and an optional cloud-init file.
# Usage: ./launch.sh <name> <image> [profile1,profile2] [cloud-init.yaml] [--vm]
set -euo pipefail

name=${1:?name required}
image=${2:-images:ubuntu/24.04/cloud}
profiles=${3:-}
cloudinit=${4:-}
vm_flag=""
[[ "${5:-}" == "--vm" ]] && vm_flag="--vm"

args=(launch "$image" "$name" -p default)
IFS=',' read -ra plist <<< "$profiles"
for p in "${plist[@]}"; do [[ -n "$p" ]] && args+=(-p "$p"); done
[[ -n "$cloudinit" ]] && args+=(--config "cloud-init.user-data=$(cat "$cloudinit")")
[[ -n "$vm_flag" ]] && args+=("$vm_flag")

incus "${args[@]}"
echo "Waiting for $name to get an IP..."
for _ in $(seq 1 30); do
  ip=$(incus list "$name" -c 4 --format csv | cut -d' ' -f1)
  [[ -n "$ip" ]] && { echo "$name is up at $ip"; exit 0; }
  sleep 1
done
echo "$name started (no IPv4 yet — check: incus list $name)"
