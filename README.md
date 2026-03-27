# jj-workspace-manager

Interactive [jj](https://github.com/martinvonz/jj) workspace manager using [fzf](https://github.com/junegunn/fzf).

## Installation

Source in your shell config:
```bash
source /path/to/jj-workspace-manager.sh
```

## Usage

```bash
jjw              # Launch workspace manager
jja <path>       # Alias for 'jj workspace add'
```

## Features

- **Select workspace** — FZF-powered workspace picker
- **Switch** — `cd` to workspace directory
- **Delete** — Remove workspace with options:
  - Keep directory on disk
  - Delete directory too (auto-relocates to default workspace if needed)
- **Safety** — Default workspace cannot be deleted

## Dependencies

- `jj` — Jujutsu VCS
- `fzf` — Fuzzy finder
