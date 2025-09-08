#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$CURRENT_DIR/scripts/helpers.sh"

## which key table to bind in (default: 'prefix')
floating_table="$(get_tmux_option '@floating_key_table' 'prefix')"

default_floating_scratch_term="M-i"
default_floating_scratch_to_active_win="M-h"
default_floating_scratch_to_win="M-l"
default_floating_active_pane_to_scratch="M-m"

set_floating_scratch_term_binding() {
	local key_bindings="$(get_tmux_option "@floating_scratch_term" "$default_floating_scratch_term")"
	local key
	for key in $key_bindings; do
			tmux bind-key -T "$floating_table" "$key" "if-shell -F '#{==:#S,floating}' { 
				detach-client 
			} {
			set -gF '@last_session_name' '#S'
			setenv -F FLOATING_SESSION_NAME 'floating'
			popup -d '#{pane_current_path}' -xC -yC -w70% -h70% -E 'env -u TMUX tmux attach -t $FLOATING_SESSION_NAME || env -u TMUX tmux new -s $FLOATING_SESSION_NAME'
		}"
	done
}

set_floating_scratch_to_win() {
	local key_bindings="$(get_tmux_option "@floating_scratch_to_win" "$default_floating_scratch_to_win")"
	local key
	for key in $key_bindings; do
		tmux bind-key -T "$floating_table" "$key" "if-shell -F '#{==:#S,floating}' {
		 break-pane -d 
		} {
		 run-shell 'bash -c \"tmux break-pane -s floating -t \"$(tmux show -gvq '@last_session_name'):\"\"'
	 }"
	done
}

set_floating_scratch_to_active_win() {
	local key_bindings="$(get_tmux_option "@floating_scratch_to_active_win" "$default_floating_scratch_to_active_win")"
	local key
	for key in $key_bindings; do
		tmux bind-key -T "$floating_table" "$key" "if-shell -F '#{==:#S,floating}' {
		 break-pane 
		 } { 
		 run-shell 'bash -c \"tmux break-pane -d -s floating -t \"$(tmux show -gvq '@last_session_name'):\"\"'
	  }"
	done
}

set_floating_active_pane_to_scratch() {
	local key_bindings="$(get_tmux_option "@floating_active_pane_to_scratch" "$default_floating_active_pane_to_scratch")"
	local key
	for key in $key_bindings; do
		tmux bind-key -T "$floating_table" "$key" "if-shell -F '#{==:#S,floating}' {
		 select-pane -m 
		 popup -d '#{pane_current_path}' -xC -yC -w70% -h70% -E 'tmux new -A -s floating tmux join-pane'
	 }"
	done
}

main() {
	set_floating_scratch_term_binding
	set_floating_scratch_to_active_win
	set_floating_scratch_to_win
	set_floating_active_pane_to_scratch
}
main
