# File Deletion Script

## Disclaimer

This script and its functionality are provided as-is, without any warranty. It is intended solely for **personal use**. The author is not responsible for any unintended consequences, data loss, or legal issues arising from the use of this script.

---

### ⚠️ **Warning**

The secure deletion option (`shred`) is **irreversible**. Be absolutely certain before using this option, as securely deleted files cannot be recovered. Misuse of this script is at your own risk.

---

## Description

This script provides a convenient way to delete files with two options:
1. **Move to Trash (Recoverable)**: Safely moves the file to the trash for potential recovery.
2. **Secure Deletion (Irreversible)**: Permanently deletes the file by overwriting its data to ensure it cannot be recovered.

The script is designed to be user-friendly, offering a clear choice and verifying the file's existence before performing any action.

---

## Features

- Interactive menu to choose deletion mode.
- Ensures safe deletion by checking the file's existence.
- Uses `trash-cli` for recoverable deletion.
- Implements `shred` for secure, irreversible deletion.
- Can be configured to run from anywhere on a Linux machine.

---

## Prerequisites

To use this script, ensure the following tools are installed on your system:

1. **`trash-cli`**:
   - Required for the "Move to Trash" option.
   - Install it on Debian-based systems with:
     ```bash
     sudo apt install trash-cli
     ```

2. **`shred`**:
   - Comes pre-installed on most Linux systems.
   - Used for securely deleting files.

---

## Run the Script from Anywhere on Linux

### Step 1: Verify Directories in `$PATH`

Run the following command to view the directories in your system's `$PATH`:
```bash
echo $PATH
```

### Common Directories in `$PATH`

Below are some commonly used directories where you can place your script to make it accessible system-wide:

| Directory                  | Description                                                 |
|----------------------------|-------------------------------------------------------------|
| `/usr/local/bin`           | Standard location for user-installed scripts and programs.  |
| `/usr/bin`                 | System-wide binary executables (may require `sudo` access). |
| `/bin`                     | Essential system binaries (typically for core tools).       |
| `/home/<username>/bin`     | User-specific binaries (create this directory if it doesn’t exist). |
| `/opt/bin`                 | Optional software and binaries (often used for third-party tools). |

### Step 2: Move the Script to a Directory in `$PATH`

Move the script to one of the directories in `$PATH`:
```bash
sudo mv delete_file.sh /usr/local/bin
```

---

### Ensure the Script is Executable

Set executable permissions on the script:
```bash
chmod +x /usr/local/bin/delete_file.sh
```

---

### Rename for Simplicity (Optional)

Rename the script while moving it for easier usage:
```bash
sudo mv delete_file.sh /usr/local/bin/delete_file
```

This way, you can run the script by simply typing:
```bash
delete_file
```

---

### Adding Custom Directories to `$PATH` (Optional)

If you wish to use a custom directory like `/home/<username>/bin`, ensure it is included in your `$PATH`. Add it by editing your shell configuration file (e.g., `.bashrc` or `.zshrc`):

1. Add the directory to your `$PATH`:
   ```bash
   export PATH=$PATH:/home/<username>/bin
   ```

2. Reload your shell configuration to apply the changes:
   ```bash
   source ~/.bashrc
   ```

---

## Follow the Prompts

When you run the script, follow the on-screen prompts to proceed:

1. **Select the deletion mode**:
   - The script will display the following options:
     ```
     Choose deletion mode:
       1) Move file to Trash (recoverable)
       2) Securely delete file (overwrite data)
     Enter your choice (1 or 2):
     ```
   - Enter `1` to move the file to the trash, or `2` to securely delete it.

2. **Specify the file to delete**:
   - After selecting the deletion mode, the script will prompt you to enter the file name:
     ```
     Enter the file name to delete: example.txt
     ```
   - Ensure the file name is entered correctly, as the script will verify if it exists.

3. **View the outcome**:
   - Based on your input, you will see one of the following messages:
     - For **Move to Trash**:
       ```
       File moved to trash.
       ```
       If `trash-cli` is not installed:
       ```
       trash-put command not found. Please install trash-cli.
       ```
     - For **Securely Delete**:
       ```
       File securely deleted.
       ```
       If `shred` encounters an issue:
       ```
       Failed to securely delete file.
       ```

4. **Invalid Input Handling**:
   - If an invalid choice is made:
     ```
     Invalid choice.
     ```
   - If the specified file does not exist or is not a regular file:
     ```
     File 'example.txt' does not exist or is not a regular file.
     ```

---

## Example Interaction

Here’s an example run-through:

```bash
Choose deletion mode:
  1) Move file to Trash (recoverable)
  2) Securely delete file (overwrite data)
Enter your choice (1 or 2): 1
Enter the file name to delete: example.txt
File moved to trash.
```

---

## Notes

- **Ensure the file name is correct**: The script verifies if the file exists before proceeding. Double-check the file name to avoid unnecessary errors.
- **Secure deletion is permanent**: The secure deletion option (`shred`) will overwrite the file's data, making recovery impossible. Use this option with caution.
- **File permissions**: Ensure you have the necessary permissions to delete the specified file, or the operation will fail.

---

## Author

**Author**:  
Andy Kukuc  

Feel free to reach out for any feedback, questions, or suggestions!
