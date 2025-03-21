#!/bin/bash

# Author: Andy Kukuc
# Overview: 
# This script synchronizes files and directories from local source directories to remote destination directories 
# using rsync over SSH. It supports multiple parallel transfers using GNU Parallel for improved performance.
# The user can specify single or multiple source and destination directories.
#
# Note: The SSH private key must be present on the destination server for the script to work.

# Prompt for SSH details
read -p "Enter the SSH username: " REMOTE_USER
read -p "Enter the hostname or IP address of the target server: " REMOTE_HOST
read -p "Enter the custom SSH port: " SSH_PORT
read -p "Enter the full path to the private key file: " KEY_FILE

# Prompt for source directories
read -p "Do you want to specify a single source directory or multiple? (single/multiple): " SOURCE_TYPE
if [ "$SOURCE_TYPE" == "single" ]; then
  read -p "Enter the single source directory: " SINGLE_SOURCE
  SOURCE_DIRS=("$SINGLE_SOURCE")
else
  echo "Enter multiple source directories (one per line). Type 'done' when finished:"
  SOURCE_DIRS=()
  while true; do
    read -p "Source directory: " DIR
    if [ "$DIR" == "done" ]; then
      break
    fi
    SOURCE_DIRS+=("$DIR")
  done
fi

# Prompt for destination directories
read -p "Do you want to specify a single destination directory or multiple? (single/multiple): " DEST_TYPE
if [ "$DEST_TYPE" == "single" ]; then
  read -p "Enter the single destination directory: " SINGLE_DEST
  DEST_DIRS=("$SINGLE_DEST")
else
  echo "Enter multiple destination directories (one per line). Type 'done' when finished:"
  DEST_DIRS=()
  while true; do
    read -p "Destination directory: " DIR
    if [ "$DIR" == "done" ]; then
      break
    fi
    DEST_DIRS+=("$DIR")
  done
fi

# Ensure the number of source and destination directories match
if [ "${#SOURCE_DIRS[@]}" -ne "${#DEST_DIRS[@]}" ]; then
  echo "Error: The number of source directories does not match the number of destination directories."
  exit 1
fi

# Number of parallel streams
CONCURRENT=4  # Adjust this based on your system and network capabilities

# Ensure GNU Parallel is installed
if ! command -v parallel &> /dev/null; then
    echo "GNU Parallel is not installed. Please install it and try again."
    exit 1
fi

# Create a temporary file for source-destination pairs
TMP_FILE="/tmp/rsync_jobs.txt"
> "$TMP_FILE"

# Add source-destination pairs to the temporary file
for INDEX in "${!SOURCE_DIRS[@]}"; do
  echo "${SOURCE_DIRS[$INDEX]} ${DEST_DIRS[$INDEX]}" >> "$TMP_FILE"
done

# Ensure destination directories exist on the remote server
while IFS=" " read -r SOURCE DESTINATION; do
  echo "Ensuring destination exists: $DESTINATION"
  ssh -i "$KEY_FILE" -p "$SSH_PORT" "$REMOTE_USER@$REMOTE_HOST" "mkdir -p \"$DESTINATION\""
  if [ $? -ne 0 ]; then
    echo "Error: Could not create directory $DESTINATION on $REMOTE_HOST. Exiting."
    exit 1
  fi

  # Verify the directory exists
  ssh -i "$KEY_FILE" -p "$SSH_PORT" "$REMOTE_USER@$REMOTE_HOST" "[ -d \"$DESTINATION\" ]"
  if [ $? -ne 0 ]; then
    echo "Error: Directory $DESTINATION does not exist on $REMOTE_HOST after creation. Exiting."
    exit 1
  fi
done < "$TMP_FILE"

# Add a brief delay to ensure directories are recognized
echo "Waiting for directories to be ready..."
sleep 5  # Increased delay to ensure directories are recognized

# Run rsync for each pair using GNU Parallel with real-time progress
cat "$TMP_FILE" | parallel --line-buffer --verbose -j "$CONCURRENT" --colsep ' ' rsync -avz --delete --progress --partial --inplace --whole-file -e "\"ssh -i $KEY_FILE -p $SSH_PORT -o Compression=no -c aes128-ctr\"" {1} "$REMOTE_USER@$REMOTE_HOST:{2}/"

# Clean up the temporary file
rm -f "$TMP_FILE"

echo "All synchronization tasks have been completed successfully."
