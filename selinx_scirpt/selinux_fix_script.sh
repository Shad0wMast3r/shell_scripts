#!/usr/bin/env bash
# setup_snmp_selinux.sh
#
# This script automates the creation and installation of SELinux policy modules
# that grant the snmpd_t domain (used by SNMP/Net-SNMP running as root) additional 
# permissions needed to access Docker and dnf resources.
#
# Usage:
#   sudo ./setup_snmp_selinux.sh
#
# The script will:
#   1. Search for recent AVC denials related to the docker process.
#   2. Generate and install an SELinux module (snmp_docker) if denials are found.
#   3. Search for recent AVC denials related to the dnf process.
#   4. Generate and install an SELinux module (snmp_dnf) if denials are found.
#
# After running the script, your SNMP extend queries that reference Docker or dnf 
# should no longer trigger permission denied errors under SELinux.

set -euo pipefail
IFS=$'\n\t'

# Create a temporary directory for storing AVC logs and module files
TMPDIR=$(mktemp -d)
echo "Using temporary directory: $TMPDIR"

#######################################
# Generate and install module for Docker
#######################################
DOCKER_AVC="$TMPDIR/avc_docker.log"

echo "Generating AVC log for docker denials..."
# Capture AVC messages for docker (adjust the search criteria if needed)
if sudo ausearch -m avc -c docker --raw > "$DOCKER_AVC"; then 
    if [ -s "$DOCKER_AVC" ]; then
        echo "Docker AVC messages found. Generating SELinux policy module for Docker..."
        sudo audit2allow -M snmp_docker -i "$DOCKER_AVC"
        echo "Installing SELinux module 'snmp_docker'..."
        sudo semodule -i snmp_docker.pp
    else
        echo "No Docker AVC messages found for snmpd_t. Skipping Docker module creation."
    fi
else
    echo "Failed to generate Docker AVC messages."
fi

#######################################
# Generate and install module for dnf
#######################################
DNF_AVC="$TMPDIR/avc_dnf.log"

echo "Generating AVC log for dnf denials..."
# Capture AVC messages for dnf 
if sudo ausearch -m avc -c dnf --raw > "$DNF_AVC"; then
    if [ -s "$DNF_AVC" ]; then
        echo "dnf-related AVC messages found. Generating SELinux policy module for dnf..."
        sudo audit2allow -M snmp_dnf -i "$DNF_AVC"
        echo "Installing SELinux module 'snmp_dnf'..."
        sudo semodule -i snmp_dnf.pp
    else
        echo "No dnf AVC messages found for snmpd_t. Skipping dnf module creation."
    fi
else
    echo "Failed to generate dnf AVC messages."
fi

# Clean up the temporary directory
echo "Cleaning up temporary directory: $TMPDIR"
rm -rf "$TMPDIR"

echo "SELinux policy modules have been generated and installed."
echo "Review the installed modules with: sudo semodule -l | grep snmp"
echo "You may need to restart the SNMP service for changes to take effect."