# Never Use `rm`, Only `trash`

Always use the `trash` command to delete files or directories instead of `rm`. This moves items to the macOS Trash, allowing for recovery if a mistake is made.

## Why
- `rm` is destructive and permanent.
- `trash` is safe and reversible (via the Trash bin).
- As an AI agent, safety is paramount. High-stakes deletions must always be reversible.

## Usage
Basic deletion:
```bash
trash <path_to_file_or_directory>
```

Multiple items:
```bash
trash file1.txt dir1/ important_data/
```

With verbose output (recommended for verification):
```bash
trash -v <path>
```

## Flags
- `-v`, `--verbose`: Show what is being moved to where.
- `-s`, `--stopOnError`: Stop processing if an error occurs.
- `-h`, `--help`: Show usage help.

## Implementation Details
The `trash` utility (typically found at `/usr/bin/trash` or installed via Homebrew) interfaces with macOS system APIs to safely move files. Unlike `rm`, it preserves the ability to "Put Back" files from the Finder interface.
