#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$CURRENT_DIR/scripts/helpers.sh"

## which key table to bind in (default: 'prefix')
floating_table="$(get_tmux_option '@floating_key_table' 'prefix')"

default_floating_scratch_term="M-i"
default_floating_scratch_to_active_win="M-h"
default_floating_scratch_to_win="M-l"
default_floating_active_pane_to_scratch="M-m"
default_floating_session_name="floating"

floating_session_name="$(get_tmux_option '@floating_session_name' "$default_floating_session_name")"

set_floating_scratch_term_binding() {
	local key_bindings="$(get_tmux_option "@floating_scratch_term" "$default_floating_scratch_term")"
	local key
	for key in $key_bindings; do
			tmux bind-key -T "$floating_table" "$key" "if-shell -F '#{==:#S,floating}' { 
				detach-client 
			} {
			display-popup -E -d '#{pane_current_path}' -x C -y C -w '70%' -h '70%' \
			'sh -lc \"env -u TMUX tmux attach -t \"\"$floating_session_name\"\" || env -u TMUX tmux new -s \"\"$floating_session_name\"\"\"'
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
		 run-shell 'bash -lc \"tmux break-pane -s '\"$floating_session_name\"' -t \\\"$(tmux show -gvq '@last_session_name'):\\\"\"'
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
		 run-shell 'bash -lc \"tmux break-pane -d -s '\"$floating_session_name\"' -t \\\"$(tmux show -gvq '@last_session_name'):\\\"\"'
	  }"
	done
}

set_floating_active_pane_to_scratch() {
	local key_bindings="$(get_tmux_option "@floating_active_pane_to_scratch" "$default_floating_active_pane_to_scratch")"
	local key
	for key in $key_bindings; do
		tmux bind-key -T "$floating_table" "$key" "if-shell -F '#{==:#S,floating}' {
		 select-pane -m 
		 display-popup -E -d '#{pane_current_path}' -x C -y C -w '70%' -h '70%' \
           'sh -lc \"env -u TMUX tmux attach -t '\"$floating_session_name\"' || env -u TMUX tmux new -s '\"$floating_session_name\"'; tmux join-pane -s \\\"#{marked}\\\"\"'
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
