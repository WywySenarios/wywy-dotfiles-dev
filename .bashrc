# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
*i*) ;;
*) return ;;
esac

DOTFILES="${DOTFILES:-$HOME/.config/dotfiles/repos/wywy-dotfiles-dev}"

# Source a directory of modular shell snippets.
# Loads *.sh and *.env at the top level and one directory deep.
# Portable: works in bash (including 3.2) — no globstar, no readlink -f.
load_dir() {
	_d="$1"
	[ -d "$_d" ] || return 0
	for _f in "$_d"/*.sh "$_d"/*.env "$_d"/*/*.sh "$_d"/*/*.env; do
		[ -r "$_f" ] && . "$_f"
	done
	unset _d _f
}

# Bash configuration (environment, history, prompt, aliases, completion).
load_dir "$DOTFILES/.bashrc.d"
