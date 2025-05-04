# Operating System Update Script (osupdate.sh)

## Overview

Operating system updates can be automated using this script. It detects the package manager present on the system, and then returns the number of available updates. This script supports multiple linox distributions.

## Features

- Supports multiple linux-based distributions, including:
  - OpenSUSE/Suse
  - Fedora/Redhat
  - Debian/Ubuntu
  - Arch
  - FreeBSD
  - Alpine
- Detects the package manager present on the system.
- Returns the number of available updates.
- Clearly commented sections for each distribution.

## Usage

Copy the script to /etc/snmp/ and make it writable:

 chmod +x /etc/snmp/osupdate

and then add this line to your snmpd.conf:

extend osupdate /etc/snmp/osupdate

Finally, restart the snmp service to activate the script:

sudo systemctl start snmpd


## How It Works

1. The script detects the package manager present on the system.
2. Based on the manager, it runs the corresponding command to determine the number of available updates.
3. The script supports multiple distributions, including:
  - OpenSUSE/Suse
  - Fedora/Redhat
  - Debian/Ubuntu
  - Arch
  - FreeBSD
  - Alpine
4. The script outputs the number of available updates.

## Script Output

The script provides output for the number of available updates for the corresponding package manager. If no updates are found, it will output "0".

## Example Script Output


```sh
OpenSUSE: 3
Fedeora: 0
Debian: 2
Arch: 0
FreeBSD: 0
Alpine: 0
```

## License

This code is provided as-is, without warranty. Use at your own risk.
