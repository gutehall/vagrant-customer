#!/bin/bash

UPDATE="sudo apt-get update"
INSTALL="sudo apt-get -y install"

# create ssh keys
ssh-keygen -t rsa -b 2048 -f "/home/vagrant/.ssh/id_rsa" -N "" &&
    cp /home/vagrant/.ssh/id_rsa.pub /home/vagrant/.ssh/authorized_keys

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

# minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-arm64 &&
sudo install minikube-linux-arm64 /usr/local/bin/minikube

# kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/arm64/kubectl" && 
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

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

# docker - Only use if customer has got license
# sudo install -m 0755 -d /etc/apt/keyrings &&
#     curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg &&
#     sudo chmod a+r /etc/apt/keyrings/docker.gpg

# echo \
#     "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
#   $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |
#     sudo tee /etc/apt/sources.list.d/docker.list >/dev/null &&
#     $UPDATE && $INSTALL docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# sudo usermod -aG docker vagrant

# podman & podman-compose
$UPDATE && $INSTALL podman
pip3 install podman-compose

# tfenv
# git clone --depth=1 https://github.com/tfutils/tfenv.git ~/.tfenv
# echo 'export PATH="$HOME/.tfenv/bin:$PATH"' >>~/.zprofile

# terrascan
curl -L "$(curl -s https://api.github.com/repos/tenable/terrascan/releases/latest | grep -o -E "https://.+?_Linux_x86_64.tar.gz")" >terrascan.tar.gz
tar -xf terrascan.tar.gz terrascan && rm terrascan.tar.gz
install terrascan /usr/local/bin && rm terrascan

# terrahub
npm install --global terrahub

# terraform docs
curl -Lo ./terraform-docs.tar.gz https://github.com/terraform-docs/terraform-docs/releases/download/v0.17.0/terraform-docs-v0.17.0-linux-arm64.tar.gz
tar -xzf terraform-docs.tar.gz && rm terraform-docs.tar.gz
chmod +x terraform-docs
mv terraform-docs /usr/local/bin/terraform-docs

# tfsec
curl -s https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | bash

# infracost
curl -fsSL https://raw.githubusercontent.com/infracost/infracost/master/scripts/install.sh | sh

# clean up
sudo apt-get clean && sudo apt-get autoremove --purge -y && sudo rm -rf /var/lib/apt/lists/*g
