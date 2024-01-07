#!/bin/bash

CLIENT=""
UPDATE="sudo apt-get update"
INSTALL="sudo apt-get -y install"

# create new ssh key
[[ ! -f /home/vagrant/.ssh/$CLIENT ]] &&
    mkdir -p /home/vagrant/.ssh &&
    ssh-keygen -f /home/vagrant/.ssh/$CLIENT -N ''

# github cli
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg &&
    sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg &&
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null &&
    $UPDATE && $INSTALL gh

# aws cli
curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
sudo ./aws/install
rm -rf aws*

# azure cli
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# gcloud sdk
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg &&
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" |
    sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list &&
    $UPDATE && $INSTALL google-cloud-cli

# kubectl & minikube
$INSTALL kubectl google-cloud-cli-minikube

# adding hashicorps keys and source
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg &&
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" |
    sudo tee /etc/apt/sources.list.d/hashicorp.list

# terraform, packer, consul and vault
$UPDATE && $INSTALL terraform packer consul vault

# ansible
sudo add-apt-repository --yes --update ppa:ansible/ansible
$UPDATE && $INSTALL ansible

# aws cdk
npm install -g aws-cdk

# docker
sudo install -m 0755 -d /etc/apt/keyrings &&
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg &&
    sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |
    sudo tee /etc/apt/sources.list.d/docker.list >/dev/null &&
    $UPDATE && $INSTALL docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo usermod -aG docker vagrant

# terrascan
curl -L "$(curl -s https://api.github.com/repos/tenable/terrascan/releases/latest | grep -o -E "https://.+?_Linux_x86_64.tar.gz")" >terrascan.tar.gz
tar -xf terrascan.tar.gz terrascan && rm terrascan.tar.gz
install terrascan /usr/local/bin && rm terrascan

# terrahub
npm install --global terrahub

# tfsec
curl -s https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | bash

# infracost
curl -fsSL https://raw.githubusercontent.com/infracost/infracost/master/scripts/install.sh | sh

# localstack
curl -Lo localstack-cli-3.0.2-linux-arm64-onefile.tar.gz \
    https://github.com/localstack/localstack-cli/releases/download/v3.0.2/localstack-cli-3.0.2-linux-arm64-onefile.tar.gz
sudo tar xvzf localstack-cli-3.0.2-linux-*-onefile.tar.gz -C /usr/local/bin
rm -rf localstack-cli-3.0.2-linux-arm64-onefile.tar.gz

# clean up
sudo apt-get clean && sudo apt-get autoremove --purge -y && sudo rm -rf /var/lib/apt/lists/*
