#!/bin/bash

CLIENT="GlobeTech"
UPDATE="sudo apt-get update"
INSTALL="sudo apt-get -y install"

# create new ssh key
[[ ! -f /home/vagrant/.ssh/$CLIENT ]] &&
    mkdir -p /home/vagrant/.ssh &&
    ssh-keygen -f /home/vagrant/.ssh/$CLIENT -N ''

# awscli
curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
sudo ./aws/install
rm -rf aws*

# terraform & packer
wget -O- https://apt.releases.hashicorp.com/gpg |
    gpg --dearmor |
    tee /usr/share/keyrings/hashicorp-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
    https://apt.releases.hashicorp.com $(lsb_release -cs) main" |
    tee /etc/apt/sources.list.d/hashicorp.list &&
    $UPDATE && $INSTALL terraform packer

# ansible
add-apt-repository --yes --update ppa:ansible/ansible
$UPDATE && $INSTALL ansible

# docker
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
$UPDATE && $INSTALL docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo usermod -aG docker vagrant
