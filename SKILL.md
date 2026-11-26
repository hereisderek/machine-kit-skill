---
name: machine-kit-skill
description: Derek's machine profiles, hardware configuration facts, global agent rules, and Proxmox infrastructure resolution tiers. Cloned to ~/.agents/machine-kit-skill and linked into agent configs via install.sh.
---

# Machine Kit Skill (`machine-kit-skill`)

Derek's machine profiles, global rules, and Proxmox infrastructure manifests, shared across every machine and agent he uses.

## Layout

- `rules/*.md`: Global behavioral and governance rules enforced across all agent sessions.
- `machines/<profile>.md`: Machine-specific facts (Mac, Agent LXC, generic environment).
- `snapshots/`: Local fallback snapshots of Proxmox infrastructure manifests and container profiles.
  - `snapshots/home-proxmox/`: Mirrored from `hereisderek/proxmox-services` (`docs/infra`).
  - `snapshots/oracle-proxmox/`: Mirrored from `hereisderek/oracle-proxmox` (`docs/lxc`).
- `scripts/update-snapshots.sh`: Sync script to refresh local snapshots from GitHub or local repos.
- `install.sh`: Compiles rules and machine profiles into agent configuration files.
- `test.sh`: Automated smoke test for rules compilation and secret leakage guards.

---

## PVE repos (for changes, not just lookups)

- Home PVE: [hereisderek/proxmox-services](https://github.com/hereisderek/proxmox-services). Oracle PVE: [hereisderek/oracle-proxmox](https://github.com/hereisderek/oracle-proxmox).
- `scripts/link-pve-repos.sh` finds local clones and symlinks them to `repos/home-proxmox` and `repos/oracle-proxmox` (gitignored; `install.sh` runs it). Override a path with `HOME_PVE_REPO` / `ORACLE_PVE_REPO`.
- Any change on a server follows that repo's `AGENTS.md`, including its documentation rules. Open `repos/<name>/AGENTS.md` first.

---

## Proxmox Infrastructure Resolution (3-Tier Priority)

When an agent needs information on hosts, containers, networks, or ports across Derek's clusters, load from top to bottom:

### 1. Home Proxmox (`home-proxmox`, `pve`)
1. **Tier A (GitHub Live - Most Up-to-Date)**:
   - URL: `https://github.com/hereisderek/proxmox-services/tree/main/docs/infra/machines` and `docs/infra/SKILLS.md`
   - *Private Repo*: Requires GitHub login or token (`gh api repos/hereisderek/proxmox-services/contents/docs/infra/SKILLS.md -H 'Accept: application/vnd.github.raw'`).
   - Local clone on Mac: `/Volumes/private/workspace/my-lab/proxmox-services/docs/infra`.
2. **Tier B (Public HTTP Endpoint)**:
   - URL: `https://sketch.hereisderek.dpdns.org/sites/node`
   - Unauthenticated direct fetch via Caddy (LXC 2006).
3. **Tier C (Local Snapshot Fallback)**:
   - File: `snapshots/home-proxmox/SKILLS.md` and `snapshots/home-proxmox/machines/`.
   - Used when Tiers A and B are unreachable.

### 2. Oracle Proxmox (`oracle-proxmox`, Oracle A1)
1. **Tier A (GitHub Live - Most Up-to-Date)**:
   - URL: `https://github.com/hereisderek/oracle-proxmox/tree/main/docs/lxc` (`SKILLS.md` and `docs/lxc/*.md`)
   - *Private Repo*: Requires GitHub login or token (`gh api repos/hereisderek/oracle-proxmox/contents/docs/lxc/SKILLS.md -H 'Accept: application/vnd.github.raw'`).
   - Local clone on Mac: `/Volumes/private/workspace/my-lab/oracle-proxmox/docs/lxc`.
2. **Tier B (Public HTTP Endpoint)**:
   - URL: `https://sites.derekoracle.cc.cd/node/SKILLS.md`
   - Unauthenticated direct fetch via Oracle Caddy (LXC 102).
3. **Tier C (Local Snapshot Fallback)**:
   - File: `snapshots/oracle-proxmox/SKILLS.md` and `snapshots/oracle-proxmox/*.md`.
   - Used when Tiers A and B are unreachable.

---

## Updating Local Snapshots

To refresh local snapshots in `snapshots/` with the latest upstream configurations:

```bash
./scripts/update-snapshots.sh
```

This script:
1. Checks GitHub accessibility and authentication via `gh`.
2. Checks for local clones in `/Volumes/private/workspace/my-lab/`.
3. Falls back to public HTTP endpoints if unauthenticated.
4. Updates `snapshots/home-proxmox/` and `snapshots/oracle-proxmox/`.

> **Reusable Skills:** Reusable engineering skills (Android/KMP, worktree-workflow, release-cicd, markdown-converter, docker-hosts, StageDroid device testing, and orchestration) live in [hereisderek/derek-agent-skills](https://github.com/hereisderek/derek-agent-skills).
