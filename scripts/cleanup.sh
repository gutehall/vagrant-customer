#!/bin/sh -eux

dpkg --list |
    awk '{ print $2 }' |
    grep 'linux-headers' |
    xargs apt-get -y purge

dpkg --list |
    awk '{ print $2 }' |
    grep 'linux-image-.*-generic' |
    grep -v "$(uname -r)" |
    xargs apt-get -y purge

dpkg --list |
    awk '{ print $2 }' |
    grep 'linux-modules-.*-generic' |
    grep -v "$(uname -r)" |
    xargs apt-get -y purge

dpkg --list |
    awk '{ print $2 }' |
    grep linux-source |
    xargs apt-get -y purge

dpkg --list |
    awk '{ print $2 }' |
    grep -- '-dev\(:[a-z0-9]\+\)\?$' |
    xargs apt-get -y purge

dpkg --list |
    awk '{ print $2 }' |
    grep -- '-doc$' |
    xargs apt-get -y purge

rm -rf /lib/firmware/*
rm -rf /usr/share/doc/linux-firmware/*

apt-get -y autoremove && apt-get -y clean

rm -rf /usr/share/doc/*

find /var/cache -type f -exec rm -rf {} \;

find /var/log -type f -exec truncate --size=0 {} \;

truncate -s 0 /etc/machine-id
if test -f /var/lib/dbus/machine-id; then
    truncate -s 0 /var/lib/dbus/machine-id
fi

rm -rf /tmp/* /var/tmp/*

rm -f /var/lib/systemd/random-seed

rm -f /root/.wget-hsts
export HISTSIZE=0
