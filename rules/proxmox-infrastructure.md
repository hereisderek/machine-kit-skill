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

## 3. SSH Connection Conventions
All hosts use key-based SSH (`~/.ssh/key.ed25519`) and are configured in `~/.ssh/config` using a 3-name convention:
- **Home LAN:** `<name>.lab` (resolved by DNS LXC 1005 `172.16.2.5`) or direct LAN IP `<name>.lab.ip` (e.g., `ssh derek@saltbox.lab`, `ssh root@pve.lab`).
- **Remote / Outside LAN:** `<name>.lab.proxy` (ProxyJump via Oracle node `pve.oracle.proxy`, e.g., `ssh derek@saltbox.lab.proxy`).
- **Oracle Internal:** `<name>.oracle` (resolved by dnsmasq `10.10.10.1`) or `<name>.oracle.ip` (e.g., `ssh derek@agent.oracle`).
- **Oracle Public Direct:** `<name>.oracle.proxy` (`137.23.1.118`, e.g., `ssh derek@pve.oracle.proxy`).

## 4. Tailnet (Tailscale and Headscale)
- Three subnet-router and exit-node members on the official Tailscale tailnet: `pve-lab` (home LXC 2032, `172.16.0.0/16`), `pve-oracle` (Oracle LXC 120, `10.10.10.0/24` and `fd00:10:10::/64`) and `china-fnos` (the China fnOS NAS, `192.168.1.0/24`, userspace mode, never reboot it). Split DNS in the Tailscale admin console: `lab` to `172.16.2.5`, `oracle` to `10.10.10.1` (domains without a leading dot).
- Headscale (Oracle LXC 119) at `https://hs.derekoracle.cc.cd`, user `derek`. Only the phone is on it so far. The `hs` Cloudflare record must stay DNS-only (unproxied CNAME to `ip.derekoracle.cc.cd`).
- For details and open items read `network.md` (Tier A: `docs/infra/network.md`) and the sheets `2032-tailscale`, `feiniu-fnos` (home) and `119-headscale`, `120-tailscale` (Oracle).
