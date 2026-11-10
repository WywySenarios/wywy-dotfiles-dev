#!/bin/bash
#
# End-to-end: apply the playbook on this host, then verify the result.
# This changes machine state. CI runs it on a dedicated stock or dotfiles host.
#
# Usage:
#   scripts/tests/e2e.sh [extra ansible-playbook arguments]
set -euo pipefail

REPO_ROOT="$(readlink -f "$(dirname "${BASH_SOURCE[0]}")/../..")"
cd "$REPO_ROOT"

# shellcheck source=../lib/output.sh
source "$REPO_ROOT/scripts/lib/output.sh"

header "Installing the Ansible toolchain"
"$REPO_ROOT/scripts/install.sh"

header "Applying playbooks/site.yaml"
uv run ansible-playbook playbooks/site.yaml "$@"

header "Verifying the installed machine"
"$REPO_ROOT/scripts/verify.sh"
