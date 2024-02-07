#!/bin/bash
set -eux

# Check for root privileges
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root."
    exit 1
fi

# Store the list of packages in a variable
package_list=$(dpkg --list | awk '{ print $2 }')

# Remove unnecessary packages
echo "$package_list" | grep -E 'linux-(headers|image|modules|source)' | grep -v "$(uname -r)" | xargs apt-get -y purge
echo "$package_list" | grep -- '-dev\(:[a-z0-9]\+\)\?\|-doc$' | xargs apt-get -y purge

# Combine cleanup commands
rm -rf /lib/firmware/* /usr/share/doc/linux-firmware/* /usr/share/doc/* /tmp/* /var/tmp/*

# Remove specific files if they exist
rm -f /var/lib/systemd/random-seed /etc/machine-id /var/lib/dbus/machine-id

# Combine find commands for cleanup
find /var/cache /var/log -type f -delete

# Additional cleanup
apt-get -y autoremove --purge
apt-get -y clean

# Remove wget history file
rm -f /root/.wget-hsts

# Clear command history
export HISTSIZE=0

echo "Cleanup completed successfully."
