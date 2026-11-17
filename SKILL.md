---
name: machine-kit-skill
description: Derek's machine profiles, hardware configuration facts, and global agent rules. Cloned to ~/.agents/machine-kit-skill and linked into agent configs via install.sh.
---

# Machine Kit Skill (`machine-kit-skill`)

Derek's machine profiles and global rules, shared across every machine and agent he uses.

## Layout

- `rules/*.md`: Global behavioral and governance rules enforced across all agent sessions.
- `machines/<profile>.md`: Machine-specific facts (Mac, Agent LXC, generic environment).
- `install.sh`: Compiles rules and machine profiles into agent configuration files.
- `test.sh`: Automated smoke test for rules compilation and secret leakage guards.

> **Reusable Skills:** Reusable engineering skills (Android/KMP, worktree-workflow, release-cicd, markdown-converter, docker-hosts, StageDroid device testing, and orchestration) live in [hereisderek/derek-agent-skills](https://github.com/hereisderek/derek-agent-skills).
