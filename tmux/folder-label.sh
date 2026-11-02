#!/usr/bin/env bash
pane_pid="$1"
pane_path="$2"

# Walk the process tree looking for "devcontainer exec --workspace-folder"
pid="$pane_pid"
while [[ -n "$pid" && "$pid" != "0" && "$pid" != "1" ]]; do
    cmd=$(ps -o args= -p "$pid" 2>/dev/null | xargs)
    if [[ "$cmd" == *"devcontainer exec"*"--workspace-folder"* ]]; then
        workspace="${cmd#*--workspace-folder }"
        workspace="${workspace%% *}"
        folder=$(basename "$workspace")
        echo "devcontainer - '$folder'"
        exit 0
    fi
    pid=$(ps -o ppid= -p "$pid" 2>/dev/null | xargs)
done

basename "$pane_path"
