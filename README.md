# jj-workspace-manager

Interactive [jj](https://github.com/martinvonz/jj) workspace manager using [fzf](https://github.com/junegunn/fzf).

## Installation

Source in your shell config:
```bash
source /path/to/jj-workspace-manager.sh
```

## Usage

```bash
jjw                    # Launch workspace manager (switch/delete)
jja <path>             # Alias for 'jj workspace add' with tmux prompt
jja <path> -n <name>   # Add workspace with custom name
```

## Features

### `jjw` — Workspace Manager

- **Select workspace** — FZF-powered workspace picker
- **Multi-select** — TAB to select multiple workspaces for batch operations
- **Switch** — `cd` to workspace directory
- **Delete** — Remove workspace with options:
  - Keep directory on disk
  - Delete directory too
  - Batch delete multiple workspaces at once
  - Auto-relocates to default workspace if current directory is deleted
- **Safety** — Default workspace cannot be deleted (skipped in multi-select)

### `jja` — Add Workspace 

- **Alias for `jj workspace add`** — All existing options are supported
- **TMUX integration** — When adding a workspace from inside a tmux session:
  - Prompts to open a new window in the new workspace directory
  - Optional—can decline with "No" in FZF
- **Name detection** — Honors `--name`/`-n` flags, or uses the path basename
- **Path resolution** — Uses `jj workspace root` to find the workspace path

## Dependencies

- `jj` — Jujutsu VCS
- `fzf` — Fuzzy finder
