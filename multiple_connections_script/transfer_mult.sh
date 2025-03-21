#!/bin/bash

# Author: Andy Kukuc
# Overview: 
# This script synchronizes files and directories from local source directories to remote destination directories 
# using rsync over SSH. It supports concurrent transfers for improved performance.
#
# Note: The SSH private key must be present on the destination server for the script to work.

# Prompt the user for SSH details
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

# Prompt the user for the number of concurrent connections
while true; do
  echo "Note: 1 concurrent connection is the minimum, and 8 is the maximum (extreme)."
  read -p "Enter the number of concurrent connections (1-8): " CONCURRENT
  if [[ "$CONCURRENT" =~ ^[1-8]$ ]]; then
    break
  else
    echo "Invalid input. Please enter a number between 1 and 8."
  fi
done

# Validate directories and create missing destination directories
for INDEX in "${!SOURCE_DIRS[@]}"; do
  SOURCE="${SOURCE_DIRS[$INDEX]}"
  DESTINATION="${DEST_DIRS[$INDEX]}"

  # Check if the source directory exists locally
  if [ ! -d "$SOURCE" ]; then
    echo "Error: Source directory $SOURCE does not exist. Please check the directory and try again."
    exit 1
  fi

  # Check if the destination directory exists on the remote server
  ssh -i "$KEY_FILE" -p "$SSH_PORT" "$REMOTE_USER@$REMOTE_HOST" "[ -d \"$DESTINATION\" ]"
  if [ $? -ne 0 ]; then
    echo "Destination directory $DESTINATION does not exist on the remote server. Creating it..."
    ssh -i "$KEY_FILE" -p "$SSH_PORT" "$REMOTE_USER@$REMOTE_HOST" "mkdir -p \"$DESTINATION\""
    if [ $? -ne 0 ]; then
      echo "Error: Could not create destination directory $DESTINATION on the remote server."
      exit 1
    fi
  fi
done

# Iterate over source and destination directories
for INDEX in "${!SOURCE_DIRS[@]}"; do
  SOURCE="${SOURCE_DIRS[$INDEX]}"
  DESTINATION="${DEST_DIRS[$INDEX]}"
  
  # Start rsync for each directory
  ((i=i%CONCURRENT)); ((i++==0)) && wait
  echo "Starting sync for: $SOURCE to $DESTINATION"
  rsync -av --delete --progress -e "ssh -i $KEY_FILE -p $SSH_PORT" "$SOURCE/" "$REMOTE_USER@$REMOTE_HOST:$DESTINATION/" &
done

# Wait for all background jobs to complete
wait

# Notify when all syncs are done
echo "All directories have been synchronized successfully."
