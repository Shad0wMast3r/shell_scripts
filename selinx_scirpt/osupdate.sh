#!/usr/bin/env bash
# Set up a robust environment for SNMP
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
export HOME="/root"
export TERM="dumb"
export LC_ALL="C"

################################################################
# Copy this script to /etc/snmp/ and make it executable:
#   chmod +x /etc/snmp/osupdate
# ------------------------------------------------------------
# Edit your snmpd.conf and include:
#   extend osupdate /etc/snmp/osupdate
#--------------------------------------------------------------
# Restart snmpd and activate the app for desired host
#--------------------------------------------------------------
# Ensure you have the correct path/binaries below
################################################################
BIN_WC='/usr/bin/env wc'
BIN_GREP='/usr/bin/env grep'
CMD_GREP='-c'
CMD_WC='-l'
BIN_ZYPPER='/usr/bin/env zypper'
CMD_ZYPPER='-q lu'
BIN_YUM='/usr/bin/env yum'
CMD_YUM='-q check-update'
BIN_DNF='/usr/bin/env dnf'
# We'll use --cacheonly to avoid metadata_lock issues, and omit -q for debugging.
BIN_TDNF='/usr/bin/env tdnf'
CMD_TDNF='-q check-update'
BIN_APT='/usr/bin/env apt-get'
CMD_APT='-qq -s upgrade'
BIN_PACMAN='/usr/bin/env pacman'
CMD_PACMAN='-Sup'
BIN_CHECKUPDATES='/usr/bin/env checkupdates'
BIN_PKG='/usr/sbin/pkg'
CMD_PKG=' audit -q -F'
BIN_APK='/sbin/apk'
CMD_APK=' version'

# For debugging, define a file to capture dnf output
DEBUG_LOG="/tmp/dnf_debug.log"

################################################################
# Main logic: Determine available package manager and output update count
################################################################
if command -v zypper &>/dev/null ; then
    # OpenSUSE branch
    UPDATES=$($BIN_ZYPPER $CMD_ZYPPER | $BIN_WC $CMD_WC)
    if [ "$UPDATES" -ge 2 ]; then
        echo $(($UPDATES-2))
    else
        echo "0"
    fi

elif command -v dnf &>/dev/null ; then
    # Fedora branch - use --cacheonly so we don't trigger metadata_lock.pid errors.
    # Log the raw output for debugging.
    $BIN_DNF --cacheonly check-update 2>/dev/null > "$DEBUG_LOG"
    UPDATES=$($BIN_DNF --cacheonly check-update 2>/dev/null | $BIN_WC $CMD_WC)
    # For debugging, you might want to output the raw dnf debug log to a file.
    # (Check /tmp/dnf_debug.log to see if any updates are listed.)
    if [ "$UPDATES" -ge 1 ]; then
        echo $(($UPDATES-1))
    else
        echo "0"
    fi

elif command -v tdnf &>/dev/null ; then
    # PhotonOS branch
    UPDATES=$($BIN_TDNF $CMD_TDNF | $BIN_WC $CMD_WC)
    if [ "$UPDATES" -ge 1 ]; then
        echo "$UPDATES"
    else
        echo "0"
    fi

elif command -v pacman &>/dev/null ; then
    # Arch branch; use checkupdates if possible.
    if command -v checkupdates &>/dev/null ; then
        UPDATES=$($BIN_CHECKUPDATES | $BIN_WC $CMD_WC)
    else
        UPDATES=$($BIN_PACMAN $CMD_PACMAN | $BIN_WC $CMD_WC)
    fi
    if [ "$UPDATES" -ge 1 ]; then
        echo $(($UPDATES-1))
    else
        echo "0"
    fi

elif command -v yum &>/dev/null ; then
    # CentOS/RedHat branch
    UPDATES=$($BIN_YUM $CMD_YUM | $BIN_WC $CMD_WC)
    if [ "$UPDATES" -ge 1 ]; then
        echo $(($UPDATES-1))
    else
        echo "0"
    fi

elif command -v apt-get &>/dev/null ; then
    # Debian/Ubuntu branch
    UPDATES=$($BIN_APT $CMD_APT | $BIN_GREP $CMD_GREP 'Inst')
    if [ "$UPDATES" -ge 1 ]; then
        echo "$UPDATES"
    else
        echo "0"
    fi

elif command -v pkg &>/dev/null ; then
    # FreeBSD branch
    UPDATES=$($BIN_PKG $CMD_PKG | $BIN_WC $CMD_WC)
    if [ "$UPDATES" -ge 1 ]; then
        echo "$UPDATES"
    else
        echo "0"
    fi

elif command -v apk &>/dev/null ; then
    # Alpine branch
    UPDATES=$($BIN_APK $CMD_APK | $BIN_WC $CMD_WC)
    if [ "$UPDATES" -ge 2 ]; then
        echo $(($UPDATES-1))
    else
        echo "0"
    fi

else
    echo "0"
fi
