# AGENTS

## Scope

This repository provisions a local AMD64 Debian development machine. It manages no remote hosts.

## Never change infrastructure state

Do not run `ansible-playbook` except as a `--check` run, unless the user explicitly asked for that exact apply.
Read-only commands such as `ansible-lint`, `ansible-playbook --syntax-check`, and `ansible-playbook --check` are allowed.

Every playbook run needs `--ask-become-pass`. Do not assume passwordless escalation.

## Toolchain

- The Ansible toolchain is pinned in `pyproject.toml` and `uv.lock`. Change the pins and regenerate the lock in the same commit.
- Playbooks use fully qualified module names (`ansible.builtin.apt`, not `apt`).
- Packages and binaries are managed by roles under `roles/`. Do not add a `shell`, `command`, or `raw` task when a module covers the job.
- This repo is a part of the Wywy repo line. Follow dotfiles repo conventions.

## Testing

Run suites through `scripts/tests/**`. If no suite exists, report that instead of inventing one.
Never commit with `--no-verify`.
