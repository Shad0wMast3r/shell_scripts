#!/bin/bash

# Written by Andy Kukuc
# This script sets up a media stack using Docker Compose. The stack includes Transmission, Sonarr, Radarr, Prowlarr, and SABnzbd.

# Default values
DEFAULT_LOCAL_NETWORK="192.168.0.0/24"
DEFAULT_OPENVPN_CONFIG="us_chicago"

# Ask the user for local network and VPN configuration
read -p "Enter your local network (default: $DEFAULT_LOCAL_NETWORK): " LOCAL_NETWORK
LOCAL_NETWORK=${LOCAL_NETWORK:-$DEFAULT_LOCAL_NETWORK}

read -p "Enter your OpenVPN configuration (default: $DEFAULT_OPENVPN_CONFIG): " OPENVPN_CONFIG
OPENVPN_CONFIG=${OPENVPN_CONFIG:-$DEFAULT_OPENVPN_CONFIG}

# Variables
COMPOSE_FILE="docker-compose.yml"
PUID=981
PGID=981
TZ="US/Chicago"
HOST_DOWNLOADS="/data/torrent/downloads"
HOST_TV="/data/plex/tv_shows"
HOST_MOVIES="/data/plex/movies"
HOST_SONARR_CONFIG="/data/torrent/sonarr"
HOST_RADARR_CONFIG="/data/torrent/radarr"
HOST_TRANSMISSION_CONFIG="/data/torrent/config/works"
HOST_PROWLARR_CONFIG="/data/torrent/prowlarr"
HOST_SABNZBD_CONFIG="/data/torrent/sabnzbd"
OPENVPN_CREDENTIALS="/data/torrent/config/openvpn-credentials.txt"

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
