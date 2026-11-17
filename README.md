# machine-kit-skill

Derek's machine profiles, global rules, and Proxmox infrastructure manifests, shared across every machine and agent he uses. Cloned to `~/.agents/machine-kit-skill` on each machine and linked into agent configs by `install.sh`. For AI agents working in this repo, see [AGENTS.md](AGENTS.md).

> **This repository is public.** Never commit passwords, tokens, API keys, private keys, personal data, or public IP addresses. A pre-commit hook (enabled by `install.sh`) blocks obvious secrets and warns about emails and public IPs. What is here on purpose: private LAN IPs (`172.16.x.x`), LXC IDs and hostnames, Derek's public domains, his GitHub username, ssh key *file names*. Anything that must stay private goes in the private `proxmox-services` or `oracle-proxmox` repos or on the machine itself.

> **Companion repo.** All reusable engineering skills (Android/KMP, worktree-workflow, release-cicd, markdown-converter, docker-hosts, StageDroid device testing, and orchestration) live in [hereisderek/derek-agent-skills](https://github.com/hereisderek/derek-agent-skills). This repository (`machine-kit-skill`) strictly holds machine-specific profiles, global agent rules, and infrastructure snapshot manifests.

## Layout

```
rules/*.md                  global rules, loaded every session, identical on every machine
machines/<profile>.md       facts that differ per machine; installed as rules/99-machine.md
snapshots/                  local fallback snapshots of Proxmox infrastructure manifests
  home-proxmox/             mirrored from hereisderek/proxmox-services (docs/infra)
  oracle-proxmox/           mirrored from hereisderek/oracle-proxmox (docs/lxc)
scripts/update-snapshots.sh syncs local snapshots from GitHub or local repos
install.sh                  compiles rules and links machine-kit-skill into agents
test.sh                     smoke test of install.sh and the hook (throwaway copy and $HOME)
.githooks/pre-commit        the public-repo guard
AGENTS.md                   instructions for agents working in this repo
```

## Proxmox Infrastructure Resolution (3-Tier Priority)

When looking up hosts, LXC containers, ports, networks, or machine specs across Derek's two Proxmox clusters (Home PVE and Oracle PVE), load from top to bottom (Tier A -> Tier B -> Tier C):

### 1. Home Proxmox (`home-proxmox`, `pve`)
- **Tier A (GitHub Live, Private)**: `https://github.com/hereisderek/proxmox-services/tree/main/docs/infra/machines` and `docs/infra/SKILLS.md`.
  - *Access*: Private repository. Requires GitHub login in browser or `gh` authentication in CLI (`gh api repos/hereisderek/proxmox-services/contents/docs/infra/SKILLS.md -H 'Accept: application/vnd.github.raw'`). On Derek's Mac, the local clone is at `/Volumes/private/workspace/my-lab/proxmox-services/docs/infra`.
- **Tier B (Public HTTP Endpoint, No Auth)**: `https://sketch.hereisderek.dpdns.org/sites/node`. Direct reverse proxy on Caddy (LXC 2006).
- **Tier C (Local Snapshot Fallback)**: Read `snapshots/home-proxmox/SKILLS.md` and `snapshots/home-proxmox/machines/` in `machine-kit-skill`. Use only when Tiers A and B fail.

### 2. Oracle Proxmox (`oracle-proxmox`, Oracle A1)
- **Tier A (GitHub Live, Private)**: `https://github.com/hereisderek/oracle-proxmox/tree/main/docs/lxc` (`SKILLS.md` and `docs/lxc/*.md`).
  - *Access*: Private repository. Requires GitHub login in browser or `gh` authentication in CLI (`gh api repos/hereisderek/oracle-proxmox/contents/docs/lxc/SKILLS.md -H 'Accept: application/vnd.github.raw'`). On Derek's Mac, the local clone is at `/Volumes/private/workspace/my-lab/oracle-proxmox/docs/lxc`.
- **Tier B (Public HTTP Endpoint, No Auth)**: `https://sites.derekoracle.cc.cd/node/SKILLS.md`. Direct reverse proxy on Caddy (LXC 102).
- **Tier C (Local Snapshot Fallback)**: Read `snapshots/oracle-proxmox/SKILLS.md` and `snapshots/oracle-proxmox/*.md` in `machine-kit-skill`. Use only when Tiers A and B fail.

---

## Updating Local Snapshots

To refresh local snapshots in `snapshots/` with the latest upstream configurations:

```bash
./scripts/update-snapshots.sh
```

The script:
1. Verifies GitHub accessibility (`gh auth status`).
2. Checks for local working copies in `/Volumes/private/workspace/my-lab/`.
3. Falls back to public HTTP endpoints if unauthenticated.
4. Updates `snapshots/home-proxmox/` and `snapshots/oracle-proxmox/`.

---

## What differs per machine

Anything specific to one machine goes in `machines/<profile>.md`, never in a shared rule or skill. Shared files say "see the machine notes" instead.

| | `mac` | `agent-lxc` | `generic` |
|---|---|---|---|
| Machine | Derek's main Mac, macOS, zsh | LXC 2026 `agent`, Debian 13, bash | any other environment: another laptop, a VM, CI |
| Workspace | `/Volumes/private/workspace/` | `/workspace` | the repo you are in |
| Install tools with | Homebrew | apt, or `/opt/tools/<name>` (no brew, no uv, no pip) | whatever it has; discovered at runtime |
| Docker | native (OrbStack) | none, use LXC 2028 / 2029 | native if present, else LXC 2028 / 2029 |
| Worktrunk | brew | installed by `wt-startup.sh` | discovered; ask before installing |
| Kit updated by | `git pull` + `install.sh` | `agent-kit-startup.sh` on every start; `updater.sh update` pulls | `git pull` + `install.sh` |
| Agents wired | Claude, Codex, Gemini/Antigravity, opencode, Pi (whichever are installed) | same (config dirs under `/opt/config`) | same |

`generic` assumes nothing: it tells the agent to find out. Add `machines/<name>.md` when a machine becomes a regular one.

## Install

```bash
git clone git@github.com:hereisderek/machine-kit-skill.git ~/.agents/machine-kit-skill
~/.agents/machine-kit-skill/install.sh --dry-run     # shows every link and file it would change
~/.agents/machine-kit-skill/install.sh
```

The profile is resolved as: `--profile`, else the one remembered from the last run (`~/.agents/.agent-kit-profile`), else `agent-lxc` on the agent LXC, else `generic`. It never guesses `mac`: on Derek's main Mac run `install.sh --profile mac` once, and it is remembered. `install.sh` is idempotent and never overwrites a real file or directory: it prints `SKIP` and leaves it for you to move away.

What it does:

1. Links `machine-kit-skill` intact into `~/.agents/skills/machine-kit-skill` and into every agent's `skills/` dir that exists.
2. Builds `.build/rules/` (symlinks to `rules/*.md` plus the machine file as `99-machine.md`), points `~/.agents/rules` at it, and `~/.claude/rules` at that. Claude Code reads it directly.
3. Codex, Gemini/Antigravity, opencode, and Pi have no rules directory, so each gets one managed block between `BEGIN machine-kit-skill` / `END machine-kit-skill` markers in its global `AGENTS.md` / `GEMINI.md`. Re-running replaces the block. Anything outside the markers (such as the ARTEMIS block) is untouched. Agents that are not installed are skipped.
4. Enables the pre-commit hook in this clone (`git config core.hooksPath .githooks`).
