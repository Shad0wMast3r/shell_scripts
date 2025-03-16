#!/bin/bash

# Written by Andy Kukuc
# A simple script to "properly" delete a file.
# Choose between sending to trash or secure deletion.

echo "Choose deletion mode:"
echo "  1) Move file to Trash (recoverable)"
echo "  2) Securely delete file (overwrite data)"

# Loop until the user enters a valid choice (1 or 2)
while true; do
    read -p "Enter your choice (1 or 2): " choice
    if [[ "$choice" == "1" || "$choice" == "2" ]]; then
        break
    else
        echo "Invalid choice. Please enter 1 or 2."
    fi
done

read -p "Enter the file name to delete: " file

if [[ ! -f "$file" ]]; then
    echo "File '$file' does not exist or is not a regular file."
    exit 1
fi

if [ "$choice" == "1" ]; then
    # Ensure trash-cli is installed or alert the user
    if ! command -v trash-put &> /dev/null; then
        echo "trash-put command not found. Please install trash-cli."
        exit 1
    fi
    trash-put "$file"
    echo "File moved to trash."
elif [ "$choice" == "2" ]; then
    shred -u "$file"
    if [ $? -eq 0 ]; then
        echo "File securely deleted."
    else
        echo "Failed to securely delete file."
    fi
fi
