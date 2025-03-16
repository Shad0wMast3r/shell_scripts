# File Deletion Script

## Description

This script provides a convenient way to delete files with two options:
1. **Move to Trash (Recoverable)**: Safely moves the file to the trash for potential recovery.
2. **Secure Deletion (Irreversible)**: Permanently deletes the file by overwriting its data to ensure it cannot be recovered.

The script is designed to be user-friendly, offering a clear choice and verifying the file's existence before performing any action.

## Features

- Interactive menu to choose deletion mode.
- Ensures safe deletion by checking the file's existence.
- Uses `trash-cli` for recoverable deletion.
- Implements `shred` for secure, irreversible deletion.

## Prerequisites

- **trash-cli**: Required for the "Move to Trash" option. Install it with:
  ```bash
  sudo apt install trash-cl