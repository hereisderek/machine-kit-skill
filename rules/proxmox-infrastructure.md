# Proxmox infrastructure resolution (Home & Oracle)

When looking up hosts, LXC containers, ports, networks, or machine specs across Derek's two Proxmox clusters (Home PVE and Oracle PVE), load from top to bottom (Priority Tier A -> B -> C):

## 1. Home Proxmox (`home-proxmox`, `pve`)
- **Tier A (GitHub Live, Private)**: `https://github.com/hereisderek/proxmox-services/tree/main/docs/infra/machines` and `docs/infra/SKILLS.md`. Requires GitHub authentication (`gh` CLI or token). Local repo on Mac: `/Volumes/private/workspace/my-lab/proxmox-services/docs/infra`.
- **Tier B (Public HTTP Endpoint, No Auth)**: `curl -fsSL https://sketch.hereisderek.dpdns.org/sites/node`. Live snapshot served by Caddy (LXC 2006).
- **Tier C (Local Snapshot Fallback)**: Read `snapshots/home-proxmox/SKILLS.md` and `snapshots/home-proxmox/machines/` in `machine-kit-skill`. Use only when Tiers A and B fail.

## 2. Oracle Proxmox (`oracle-proxmox`, Oracle A1)
- **Tier A (GitHub Live, Private)**: `https://github.com/hereisderek/oracle-proxmox/tree/main/docs/lxc` (`SKILLS.md` and `docs/lxc/*.md`). Requires GitHub authentication (`gh` CLI or token). Local repo on Mac: `/Volumes/private/workspace/my-lab/oracle-proxmox/docs/lxc`.
- **Tier B (Public HTTP Endpoint, No Auth)**: `curl -fsSL https://sites.derekoracle.cc.cd/node/SKILLS.md`. Live snapshot served by Oracle Caddy (LXC 102).
- **Tier C (Local Snapshot Fallback)**: Read `snapshots/oracle-proxmox/SKILLS.md` and `snapshots/oracle-proxmox/*.md` in `machine-kit-skill`. Use only when Tiers A and B fail.
