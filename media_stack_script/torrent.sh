#!/bin/bash

# Written by Andy Kukuc
# This script sets up a media stack using Docker Compose. The stack includes Transmission, Sonarr, Radarr, Prowlarr, and SABnzbd.

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
  echo "ERROR: Docker is not installed. Please install Docker before running this script."
  exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
  echo "ERROR: Docker Compose is not installed. Please install Docker Compose before running this script."
  exit 1
fi

# Default values
DEFAULT_LOCAL_NETWORK="192.168.0.0/24"
DEFAULT_OPENVPN_CONFIG="us_chicago"

# Ask the user for local network and VPN configuration
read -p "Enter your local network: " LOCAL_NETWORK
while [[ -z "$LOCAL_NETWORK" ]]; do
  echo "Local network cannot be empty. Please enter a valid value."
  read -p "Enter your local network: " LOCAL_NETWORK
done

read -p "Enter your OpenVPN configuration: " OPENVPN_CONFIG
while [[ -z "$OPENVPN_CONFIG" ]]; do
  echo "OpenVPN configuration cannot be empty. Please enter a valid value."
  read -p "Enter your OpenVPN configuration: " OPENVPN_CONFIG
done

read -p "Enter the path for downloads directory: " HOST_DOWNLOADS
while [[ -z "$HOST_DOWNLOADS" ]]; do
  echo "Downloads directory path cannot be empty. Please enter a valid value."
  read -p "Enter the path for downloads directory: " HOST_DOWNLOADS
done

read -p "Enter the path for TV shows directory: " HOST_TV
while [[ -z "$HOST_TV" ]]; do
  echo "TV shows directory path cannot be empty. Please enter a valid value."
  read -p "Enter the path for TV shows directory: " HOST_TV
done

read -p "Enter the path for movies directory: " HOST_MOVIES
while [[ -z "$HOST_MOVIES" ]]; do
  echo "Movies directory path cannot be empty. Please enter a valid value."
  read -p "Enter the path for movies directory: " HOST_MOVIES
done

read -p "Enter the path for Sonarr configuration directory: " HOST_SONARR_CONFIG
while [[ -z "$HOST_SONARR_CONFIG" ]]; do
  echo "Sonarr configuration directory path cannot be empty. Please enter a valid value."
  read -p "Enter the path for Sonarr configuration directory: " HOST_SONARR_CONFIG
done

read -p "Enter the path for Radarr configuration directory: " HOST_RADARR_CONFIG
while [[ -z "$HOST_RADARR_CONFIG" ]]; do
  echo "Radarr configuration directory path cannot be empty. Please enter a valid value."
  read -p "Enter the path for Radarr configuration directory: " HOST_RADARR_CONFIG
done

read -p "Enter the path for Transmission configuration directory: " HOST_TRANSMISSION_CONFIG
while [[ -z "$HOST_TRANSMISSION_CONFIG" ]]; do
  echo "Transmission configuration directory path cannot be empty. Please enter a valid value."
  read -p "Enter the path for Transmission configuration directory: " HOST_TRANSMISSION_CONFIG
done

read -p "Enter the path for Prowlarr configuration directory: " HOST_PROWLARR_CONFIG
while [[ -z "$HOST_PROWLARR_CONFIG" ]]; do
  echo "Prowlarr configuration directory path cannot be empty. Please enter a valid value."
  read -p "Enter the path for Prowlarr configuration directory: " HOST_PROWLARR_CONFIG
done

read -p "Enter the path for SABnzbd configuration directory: " HOST_SABNZBD_CONFIG
while [[ -z "$HOST_SABNZBD_CONFIG" ]]; do
  echo "SABnzbd configuration directory path cannot be empty. Please enter a valid value."
  read -p "Enter the path for SABnzbd configuration directory: " HOST_SABNZBD_CONFIG
done

read -p "Enter the path for OpenVPN credentials file: " OPENVPN_CREDENTIALS
while [[ -z "$OPENVPN_CREDENTIALS" ]]; do
  echo "OpenVPN credentials file path cannot be empty. Please enter a valid value."
  read -p "Enter the path for OpenVPN credentials file: " OPENVPN_CREDENTIALS
done

# Variables
COMPOSE_FILE="docker-compose.yml"
PUID=981
PGID=981
TZ="US/Chicago"

# Function to Check if a Container is Running
is_container_running() {
  local container_name=$1
  docker ps --filter "name=^/${container_name}$" --format "{{.Names}}" | grep -wq "$container_name"
}

# Step 1: Create Necessary Directories
echo "Creating necessary directories for Sonarr, Radarr, Transmission, Prowlarr, and SABnzbd..."
mkdir -p "$HOST_DOWNLOADS" "$HOST_TV" "$HOST_MOVIES" "$HOST_SONARR_CONFIG" "$HOST_RADARR_CONFIG" "$HOST_TRANSMISSION_CONFIG" "$HOST_PROWLARR_CONFIG" "$HOST_SABNZBD_CONFIG"

# Step 2: Modify Permissions for All Relevant Directories
echo "Setting permissions for directories..."
sudo chown -R "$PUID":"$PGID" "$HOST_DOWNLOADS" "$HOST_TV" "$HOST_MOVIES" "$HOST_SONARR_CONFIG" "$HOST_RADARR_CONFIG" "$HOST_TRANSMISSION_CONFIG" "$HOST_PROWLARR_CONFIG" "$HOST_SABNZBD_CONFIG"
sudo chmod -R 775 "$HOST_DOWNLOADS" "$HOST_TV" "$HOST_MOVIES" "$HOST_SONARR_CONFIG" "$HOST_RADARR_CONFIG" "$HOST_TRANSMISSION_CONFIG" "$HOST_PROWLARR_CONFIG" "$HOST_SABNZBD_CONFIG"

# Step 3: Generate docker-compose.yml file if it doesn't exist
if [ ! -f "$COMPOSE_FILE" ]; then
  echo "Generating docker-compose.yml file with user input..."
  cat <<EOL > $COMPOSE_FILE
version: '3.8'

services:
  transmission:
    image: haugene/transmission-openvpn
    container_name: torrent
    cap_add:
      - NET_ADMIN
    environment:
      - OPENVPN_PROVIDER=PIA
      - OPENVPN_CONFIG=$OPENVPN_CONFIG
      - OPENVPN_USERNAME=**None**
      - OPENVPN_PASSWORD=**None**
      - LOCAL_NETWORK=$LOCAL_NETWORK
      - DISABLE_PORT_UPDATER=true
    volumes:
      - $HOST_DOWNLOADS:/data/completed
      - $HOST_TRANSMISSION_CONFIG:/config
      - $OPENVPN_CREDENTIALS:/config/openvpn-credentials.txt
    ports:
      - 9091:9091
    restart: unless-stopped

  sonarr:
    image: lscr.io/linuxserver/sonarr:latest
    container_name: sonarr
    environment:
      - PUID=$PUID
      - PGID=$PGID
      - TZ=$TZ
    volumes:
      - $HOST_DOWNLOADS:/data/completed
      - $HOST_TV:/tv
      - $HOST_SONARR_CONFIG:/config
    ports:
      - 8989:8989
    restart: unless-stopped

  radarr:
    image: lscr.io/linuxserver/radarr:latest
    container_name: radarr
    environment:
      - PUID=$PUID
      - PGID=$PGID
      - TZ=$TZ
    volumes:
      - $HOST_DOWNLOADS:/data/completed
      - $HOST_MOVIES:/movies
      - $HOST_RADARR_CONFIG:/config
    ports:
      - 7878:7878
    restart: unless-stopped

  prowlarr:
    image: lscr.io/linuxserver/prowlarr:latest
    container_name: prowlarr
    environment:
      - PUID=$PUID
      - PGID=$PGID
      - TZ=$TZ
    volumes:
      - $HOST_PROWLARR_CONFIG:/config
    ports:
      - 9696:9696
    restart: unless-stopped

  sabnzbd:
    image: linuxserver/sabnzbd:latest
    container_name: sabnzbd
    environment:
      - PUID=$PUID
      - PGID=$PGID
      - TZ=$TZ
    volumes:
      - $HOST_DOWNLOADS:/data/completed
      - $HOST_SABNZBD_CONFIG:/config
    ports:
      - 8080:8080
    restart: unless-stopped
EOL
else
  echo "docker-compose.yml already exists. Skipping file generation."
fi

# Step 4: Deploy or Skip Already Running Containers
echo "Deploying the media stack using Docker Compose..."
for container in torrent sonarr radarr prowlarr sabnzbd; do
  if is_container_running "$container"; then
    echo "Container '$container' is already running. Skipping..."
  else
    echo "Starting container '$container'..."
    docker-compose up -d "$container"
  fi
done

# Step 5: Verify the Setup
echo "Verifying the setup..."
docker-compose ps

echo "Setup complete! Access the services at:"
echo " - Transmission: http://<host_ip>:9091"
echo " - Sonarr: http://<host_ip>:8989"
echo " - Radarr: http://<host_ip>:7878"
echo " - Prowlarr: http://<host_ip>:9696"
echo " - SABnzbd: http://<host_ip>:8080"

# Step 6: Reminder to Open Ports
echo "IMPORTANT: Ensure the following TCP ports are open in your firewall or router for the media stack to function properly:"
echo " - Transmission: TCP 9091"
echo " - Sonarr: TCP 8989"
echo " - Radarr: TCP 7878"
echo " - Prowlarr: TCP 9696"
echo " - SABnzbd: TCP 8080"
echo "You may need to configure port forwarding on your router or adjust your firewall settings to allow these ports."
