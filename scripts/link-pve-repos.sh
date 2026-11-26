#!/usr/bin/env bash
# Find local clones of the two PVE repos and symlink them into repos/ (gitignored), so an agent
# working in this kit can open them as ./repos/home-proxmox and ./repos/oracle-proxmox.
#   ./scripts/link-pve-repos.sh
# Override a location with HOME_PVE_REPO=/path or ORACLE_PVE_REPO=/path.
# Never clones, pulls or edits the repos; it only creates symlinks.
set -euo pipefail

KIT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEST="$KIT/repos"

# name | github repo | env override
REPOS=(
  "home-proxmox|hereisderek/proxmox-services|${HOME_PVE_REPO:-}"
  "oracle-proxmox|hereisderek/oracle-proxmox|${ORACLE_PVE_REPO:-}"
)
ROOTS=(/Volumes/private/workspace/my-lab /workspace/my-lab /workspace "$HOME/workspace/my-lab" "$HOME/workspace" "$HOME/code" "$HOME/src" "$(dirname "$KIT")" "$(dirname "$KIT")/..")

# is_clone <dir> <github repo>: a git checkout whose origin is that repo.
is_clone() { git -C "$1" remote get-url origin 2>/dev/null | grep -qiE "github\.com[:/]$2(\.git)?$"; }

mkdir -p "$DEST"
for entry in "${REPOS[@]}"; do
  IFS='|' read -r name gh override <<<"$entry"
  base="${gh##*/}" found=""
  cands=("$override"); for r in "${ROOTS[@]}"; do cands+=("$r/$base"); done
  for c in "${cands[@]}"; do
    [ -n "$c" ] && [ -d "$c/.git" ] && is_clone "$c" "$gh" && { found="$(cd "$c" && pwd -P)"; break; }
  done
  if [ -n "$found" ]; then
    ln -sfn "$found" "$DEST/$name"
    echo "link repos/$name -> $found"
  else
    rm -f "$DEST/$name"   # drop a stale link; only ever a symlink
    echo "MISS $name: no local clone of github.com/$gh found. Clone it, or set $(echo ${name%%-*} | tr a-z A-Z)_PVE_REPO. Use Tier A/B/C in rules/proxmox-infrastructure.md meanwhile."
  fi
done
