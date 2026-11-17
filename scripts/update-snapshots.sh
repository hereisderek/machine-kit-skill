#!/usr/bin/env bash
# Update local Proxmox machine snapshots in machine-kit-skill.
# Checks access (GitHub authenticated vs local clone vs public endpoints) and refreshes snapshots.
set -euo pipefail

KIT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOME_SNAP="$KIT/snapshots/home-proxmox"
ORACLE_SNAP="$KIT/snapshots/oracle-proxmox"

HOME_LOCAL="/Volumes/private/workspace/my-lab/proxmox-services/docs/infra"
ORACLE_LOCAL="/Volumes/private/workspace/my-lab/oracle-proxmox/docs/lxc"

say() { printf '%s\n' "$*"; }

say "============================================================"
say "Updating Proxmox Machine Snapshots in machine-kit-skill"
say "Kit root: $KIT"
say "============================================================"

# 1. Update Home Proxmox Snapshot
say "\n--> Checking Home Proxmox (home-pve)..."
mkdir -p "$HOME_SNAP"

if [ -d "$HOME_LOCAL" ]; then
  say "✓ Local repository found at $HOME_LOCAL"
  if [ -d "$HOME_LOCAL/../../.git" ]; then
    git -C "$HOME_LOCAL/../.." pull -q --ff-only 2>/dev/null || true
  fi
  cp -R "$HOME_LOCAL"/* "$HOME_SNAP/"
  say "✓ Updated $HOME_SNAP from local working copy"
elif command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
  say "✓ GitHub CLI authenticated. Fetching from hereisderek/proxmox-services..."
  gh api repos/hereisderek/proxmox-services/contents/docs/infra/SKILLS.md -H 'Accept: application/vnd.github.raw' > "$HOME_SNAP/SKILLS.md"
  say "✓ Updated $HOME_SNAP/SKILLS.md from GitHub API"
else
  say "⚠ GitHub authentication unavailable. Falling back to public HTTP endpoint..."
  if curl -fsSL https://sketch.hereisderek.dpdns.org/sites/node -o "$HOME_SNAP/SKILLS.md"; then
    say "✓ Updated $HOME_SNAP/SKILLS.md from https://sketch.hereisderek.dpdns.org/sites/node"
  else
    say "✗ Public HTTP endpoint unreachable; keeping existing snapshot."
  fi
fi

# 2. Update Oracle Proxmox Snapshot
say "\n--> Checking Oracle Proxmox (oracle-node)..."
mkdir -p "$ORACLE_SNAP"

if [ -d "$ORACLE_LOCAL" ]; then
  say "✓ Local repository found at $ORACLE_LOCAL"
  if [ -d "$ORACLE_LOCAL/../../.git" ]; then
    git -C "$ORACLE_LOCAL/../.." pull -q --ff-only 2>/dev/null || true
  fi
  cp -R "$ORACLE_LOCAL"/* "$ORACLE_SNAP/"
  say "✓ Updated $ORACLE_SNAP from local working copy"
elif command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
  say "✓ GitHub CLI authenticated. Fetching from hereisderek/oracle-proxmox..."
  gh api repos/hereisderek/oracle-proxmox/contents/docs/lxc/SKILLS.md -H 'Accept: application/vnd.github.raw' > "$ORACLE_SNAP/SKILLS.md"
  say "✓ Updated $ORACLE_SNAP/SKILLS.md from GitHub API"
else
  say "⚠ GitHub authentication unavailable. Falling back to public HTTP endpoint..."
  if curl -fsSL https://sites.derekoracle.cc.cd/node/SKILLS.md -o "$ORACLE_SNAP/SKILLS.md"; then
    say "✓ Updated $ORACLE_SNAP/SKILLS.md from https://sites.derekoracle.cc.cd/node/SKILLS.md"
  else
    say "✗ Public HTTP endpoint unreachable; keeping existing snapshot."
  fi
fi

say "\n============================================================"
say "Snapshot update complete!"
say "Home Proxmox files:   $(find "$HOME_SNAP" -type f | wc -l | tr -d ' ')"
say "Oracle Proxmox files: $(find "$ORACLE_SNAP" -type f | wc -l | tr -d ' ')"
say "============================================================"
