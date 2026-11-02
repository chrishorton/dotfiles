#!/bin/bash
pane_pid=$1
pane_path=$2
pane_cmd=$3
pane_tty=$4

# Check for classification markers (cached per directory, refreshed every 60s)
classify=""
cache_dir="/tmp/tmux-classify"
mkdir -p "$cache_dir" 2>/dev/null
cache_key=$(echo "$pane_path" | md5 -q 2>/dev/null || echo "$pane_path" | md5sum 2>/dev/null | cut -d' ' -f1)
cache_file="$cache_dir/$cache_key"

if [ -f "$cache_file" ] && [ $(($(date +%s) - $(stat -f%m "$cache_file" 2>/dev/null || stat -c%Y "$cache_file" 2>/dev/null || echo 0))) -lt 60 ]; then
    classify=$(cat "$cache_file")
else
    if [ -d "$pane_path" ]; then
        # Check common classification marker locations
        for marker in "$pane_path/.classification" "$pane_path/CLASSIFICATION" "$pane_path/SECURITY.md"; do
            if [ -f "$marker" ] && grep -qi "CUI" "$marker" 2>/dev/null; then
                classify="CUI"
                break
            fi
        done
        # Check banner/header files if no marker file found
        if [ -z "$classify" ]; then
            for f in "$pane_path/README.md" "$pane_path/README" "$pane_path/.banner"; do
                if [ -f "$f" ] && head -5 "$f" 2>/dev/null | grep -qi "CUI\|controlled unclassified"; then
                    classify="CUI"
                    break
                fi
            done
        fi
    fi
    echo "$classify" > "$cache_file"
fi

suffix=""
if [ -n "$classify" ]; then
    suffix=" [$classify]"
fi

# Detect if inside a devcontainer
in_container=""
if [ -f "$pane_path/.devcontainer/devcontainer.json" ] || [ -f "$pane_path/.devcontainer.json" ]; then
    in_container=""
fi

# If it's just the shell, show directory name
if [ "$pane_cmd" = "fish" ] || [ "$pane_cmd" = "bash" ] || [ "$pane_cmd" = "zsh" ]; then
    echo "${in_container}$(basename "$pane_path")${suffix}"
    exit 0
fi

# Find the foreground process via the tty
tty_short="${pane_tty#/dev/}"
args=$(ps -t "$tty_short" -o pid=,args= 2>/dev/null | grep -v "fish" | grep -v "ps -t" | grep "$pane_cmd" | head -1 | sed 's/^[[:space:]]*[0-9]* //')

# Fallback: try pgrep
if [ -z "$args" ]; then
    child_pid=$(pgrep -P "$pane_pid" 2>/dev/null | head -1)
    if [ -n "$child_pid" ]; then
        args=$(ps -o args= -p "$child_pid" 2>/dev/null)
    fi
fi

# Detect Electron apps masquerading as "node"
if [ "$pane_cmd" = "node" ]; then
    if echo "$args" | grep -qi "cursor"; then
        echo "${in_container}cursor:$(basename "$pane_path")${suffix}"
        exit 0
    elif echo "$args" | grep -qi "code"; then
        echo "${in_container}vscode:$(basename "$pane_path")${suffix}"
        exit 0
    fi
fi

# No args found, just show cmd:dir
if [ -z "$args" ]; then
    echo "${in_container}$pane_cmd:$(basename "$pane_path")${suffix}"
    exit 0
fi

name=""
case "$pane_cmd" in
    vim|nvim|vi)
        file=$(echo "$args" | awk '{for(i=NF;i>=1;i--) if($i !~ /^[-+]/) {print $i; exit}}')
        if [ -z "$file" ] || [ "$file" = "$pane_cmd" ] || [ "$file" = "." ] || [ -d "$file" ]; then
            name="$pane_cmd:$(basename "$pane_path")"
        else
            name="$pane_cmd:$(basename "$file")"
        fi
        ;;
    python|python3|node|ruby|perl|cargo|go)
        script=$(echo "$args" | awk '{for(i=2;i<=NF;i++) if($i !~ /^-/) {print $i; exit}}')
        if [ -n "$script" ]; then
            name="$pane_cmd:$(basename "$script")"
        else
            name="$pane_cmd:$(basename "$pane_path")"
        fi
        ;;
    ssh)
        host=$(echo "$args" | awk '{print $NF}')
        name="ssh:$host"
        ;;
    make|npm|pnpm|yarn|docker|kubectl)
        sub=$(echo "$args" | awk '{if(NF>=2) print $2; else print ""}')
        if [ -n "$sub" ] && [ "$sub" != "$pane_cmd" ]; then
            name="$pane_cmd:$sub"
        else
            name="$pane_cmd"
        fi
        ;;
    git)
        sub=$(echo "$args" | awk '{for(i=2;i<=NF;i++) if($i !~ /^-/) {print $i; exit}}')
        if [ -n "$sub" ]; then
            name="git:$sub"
        else
            name="git"
        fi
        ;;
    *)
        name="$pane_cmd:$(basename "$pane_path")"
        ;;
esac

echo "${in_container}${name}${suffix}"
