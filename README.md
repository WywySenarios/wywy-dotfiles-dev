# wywy-dotfiles-dev

This repo is part of the Wywy repo line and is subject to Wywy conventions.

Wywy development machine configuration.

## Prerequisites

- AMD64 Debian
- `sudo`, with a password
- `git`
- `uv`
- `curl` and `ca-certificates`

## Setup

```bash
git clone --recurse-submodules https://github.com/WywySenarios/wywy-dotfiles-dev ~/.config/dotfiles/repos/wywy-dotfiles-dev
cd ~/.config/dotfiles/repos/wywy-dotfiles-dev
scripts/install.sh
```

## Usage

Preview the changes:

```bash
uv run ansible-playbook playbooks/site.yaml --check --diff --ask-become-pass
```

Apply them:

```bash
uv run ansible-playbook playbooks/site.yaml --ask-become-pass
```

Verify the installed machine:

```bash
scripts/verify.sh
```

## Configuration

`roles/<role>/defaults/main.yaml`.

## Status

Unstable.
