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
echo "$package_list" | grep 'linux-headers' | xargs apt-get -y purge
echo "$package_list" | grep 'linux-image-.*-generic' | grep -v "$(uname -r)" | xargs apt-get -y purge
echo "$package_list" | grep 'linux-modules-.*-generic' | grep -v "$(uname -r)" | xargs apt-get -y purge
echo "$package_list" | grep 'linux-source' | xargs apt-get -y purge
echo "$package_list" | grep -- '-dev\(:[a-z0-9]\+\)\?$' | xargs apt-get -y purge
echo "$package_list" | grep -- '-doc$' | xargs apt-get -y purge

# Combine cleanup commands
rm -rf /lib/firmware/* /usr/share/doc/linux-firmware/* /usr/share/doc/* /tmp/* /var/tmp/* #/var/cache /var/log

# Remove specific files if they exist
if [ -e /var/lib/systemd/random-seed ]; then
    rm -f /var/lib/systemd/random-seed
fi

# Truncate files
truncate -s 0 /etc/machine-id /var/lib/dbus/machine-id

# Combine find commands
find /var/cache /var/log -type f -exec rm -rf {} \;

# Additional cleanup
apt-get -y autoremove --purge
apt-get -y clean

# Remove wget history file
rm -f /root/.wget-hsts

# Clear command history
export HISTSIZE=0

echo "Cleanup completed successfully."
