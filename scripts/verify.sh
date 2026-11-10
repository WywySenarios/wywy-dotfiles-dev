#!/bin/bash
#
# User-facing verification. Every expected tool must be on PATH and at or above
# its declared threshold. Unparseable output counts as unknown, which fails.
set -euo pipefail

REPO_ROOT="$(readlink -f "$(dirname "${BASH_SOURCE[0]}")/..")"

# shellcheck source=lib/output.sh
source "$REPO_ROOT/scripts/lib/output.sh"

status=0

version_ge() {
	# version_ge <installed> <minimum>
	[[ "$(printf '%s\n%s\n' "$2" "$1" | sort -V | head -n1)" == "$2" ]]
}

check_version() {
	local name="$1"
	local minimum="$2"
	local output installed

	shift 2

	if ! command -v "$name" >/dev/null 2>&1; then
		error "MISSING: $name"
		status=1
		return
	fi

	output="$("$@" 2>&1 | head -n1)" || true
	installed="$(printf '%s\n' "$output" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n1)" || true
	if [[ -z "$installed" ]]; then
		error "UNKNOWN: $name printed unparseable output: $output"
		status=1
		return
	fi
	if ! version_ge "$installed" "$minimum"; then
		error "BELOW THRESHOLD: $name $installed < $minimum"
		status=1
		return
	fi
	info "PASS: $name $installed (>= $minimum)"
}

check_present() {
	local name="$1"
	if ! command -v "$name" >/dev/null 2>&1; then
		error "MISSING: $name"
		status=1
		return
	fi
	info "PASS: $name present"
}

header "Verifying tool thresholds"
check_version node 22.0.0 node --version
check_version go 1.23.0 go version
check_version rg 14.0.0 rg --version
check_version gitleaks 8.24.0 gitleaks version
check_version betterleaks 1.9.0 betterleaks version
check_version kind 0.23.0 kind version
check_version air 0.13.0 air --version
check_present prettier
check_present opencode
check_present ruff

if [[ "$status" -ne 0 ]]; then
	error "Verification failed."
	exit 1
fi

info "All tools verified."
