# jj-workspace-manager - Manage jj workspaces with FZF
#
# Source this file in your .bashrc or .zshrc:
#   source /path/to/jj-workspace-manager.sh
#
# Usage: jj-workspace-manager

jj-workspace-manager() {
    # Check dependencies
    command -v jj >/dev/null 2>&1 || { echo "Error: jj is not installed" >&2; return 1; }
    command -v fzf >/dev/null 2>&1 || { echo "Error: fzf is not installed" >&2; return 1; }

    # Get list of workspaces
    local workspaces
    workspaces=$(jj workspace list 2>/dev/null)

    if [[ -z "$workspaces" ]]; then
        echo "No workspaces found"
        return 0
    fi

    # Step 1: Select workspace with FZF
    local selected
    selected=$(echo "$workspaces" | fzf \
        --header="Select a workspace (ESC to cancel)" \
        --height=40% \
        --reverse \
        --border \
        --prompt="Workspace > ")

    # Exit if nothing selected (user pressed ESC)
    if [[ -z "$selected" ]]; then
        echo "Cancelled"
        return 0
    fi

    # Extract workspace name (everything before the colon)
    local workspace_name
    workspace_name=$(echo "$selected" | cut -d':' -f1 | xargs)

    # Get workspace path using jj workspace root
    local workspace_path
    workspace_path=$(jj workspace root --name "$workspace_name" 2>/dev/null)
    
    if [[ -z "$workspace_path" ]]; then
        echo "Error: Could not determine path for workspace '$workspace_name'" >&2
        return 1
    fi

    # Step 2: Select operation with FZF
    local operation
    operation=$(printf "switch\ndelete" | fzf \
        --header="Workspace: $workspace_name" \
        --height=20% \
        --reverse \
        --border \
        --prompt="Operation > ")

    # Exit if nothing selected (user pressed ESC)
    if [[ -z "$operation" ]]; then
        echo "Cancelled"
        return 0
    fi

    case "$operation" in
        switch)
            cd "$workspace_path" || return 1
            echo "Switched to workspace '$workspace_name'"
            ;;
        delete)
            # Prevent deletion of the default workspace
            if [[ "$workspace_name" == "default" ]]; then
                echo "Error: Cannot delete the default workspace" >&2
                return 1
            fi
            
            # Confirm removal with FZF and offer directory deletion option
            local confirmation
            confirmation=$(printf "No\nYes (keep directory)\nYes (delete directory too)" | fzf \
                --header="Remove workspace '$workspace_name'?" \
                --height=20% \
                --reverse \
                --border \
                --prompt="Confirm > ")

            case "$confirmation" in
                "Yes (keep directory)")
                    jj workspace forget "$workspace_name"
                    echo "Workspace '$workspace_name' has been removed (directory kept at $workspace_path)"
                    ;;
                "Yes (delete directory too)")
                    # Check if we're currently inside the workspace being deleted
                    local current_dir
                    current_dir=$(pwd)
                    local need_to_relocate=false
                    
                    if [[ "$current_dir" == "$workspace_path" || "$current_dir" == "$workspace_path"/* ]]; then
                        need_to_relocate=true
                    fi
                    
                    # Get default workspace path before deletion (in case we need to relocate)
                    local default_workspace_path
                    if [[ "$need_to_relocate" == true ]]; then
                        default_workspace_path=$(jj workspace root --name default 2>/dev/null)
                    fi
                    
                    jj workspace forget "$workspace_name"
                    if [[ -d "$workspace_path" ]]; then
                        rm -rf "$workspace_path"
                        echo "Workspace '$workspace_name' and directory '$workspace_path' have been removed"
                    else
                        echo "Workspace '$workspace_name' removed (directory '$workspace_path' not found)"
                    fi
                    
                    # Relocate to default workspace if we were inside the deleted workspace
                    if [[ "$need_to_relocate" == true && -n "$default_workspace_path" ]]; then
                        cd "$default_workspace_path" || return 1
                        echo "Changed directory to default workspace: $default_workspace_path"
                    fi
                    ;;
                *)
                    echo "Cancelled"
                    ;;
            esac
            ;;
    esac
}

alias jjw="jj-workspace-manager"
alias jja="jj workspace add"
