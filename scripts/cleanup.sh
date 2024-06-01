#!/bin/bash
set -eux

# Check for root privileges
if [ "$(id -u)" -ne 0; then
    echo "This script must be run as root."
    exit 1
fi

# Function to purge packages based on pattern
purge_packages() {
    local pattern="$1"
    dpkg --list | awk '{ print $2 }' | grep -E "$pattern" | grep -v "$(uname -r)" | xargs apt-get -y purge
}

# Remove unnecessary packages
purge_packages 'linux-(headers|image|modules|source)'
purge_packages '--dev(:[a-z0-9]+)?|--doc$'

# Combine cleanup commands
rm -rf /lib/firmware/* /usr/share/doc/linux-firmware/* /usr/share/doc/* /tmp/* /var/tmp/* \
       /var/lib/systemd/random-seed /etc/machine-id /var/lib/dbus/machine-id \
       /root/.wget-hsts

# Combine find commands for cleanup
find /var/cache /var/log -type f -delete

# Additional cleanup
apt-get -y autoremove --purge
apt-get -y clean

# Clear command history
export HISTSIZE=0

echo "Cleanup completed successfully."
