#!/bin/bash

TARGET_USER="vagrant"
PACKAGE_MANAGER="sudo apt-get"
UPDATE="${PACKAGE_MANAGER} update"
INSTALL="${PACKAGE_MANAGER} -y install"

# Function to install GitHub CLI
install_gh_cli() {
    echo "Installing GitHub CLI..."
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg &&
        sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg &&
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null &&
        ${UPDATE} && ${INSTALL} gh
}

# Function to install AWS CLI v2
install_aws_cli() {
    echo "Installing AWS CLI..."
    curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip"
    unzip -q awscliv2.zip
    sudo ./aws/install
    rm -rf aws*
}

# Function to install Azure CLI
install_azure_cli() {
    echo "Installing Azure CLI..."
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/azure-cli.list
    curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg >/dev/null
    ${UPDATE} && ${INSTALL} azure-cli
}

# Function to install Minikube
install_minikube() {
    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-arm64 &&
        sudo install minikube-linux-arm64 /usr/local/bin/minikube
    rm minikube-linux-arm64
}

# Function to install Kubectl
install_kubectl() {
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/arm64/kubectl" &&
        sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm kubectl
}

# Function to install Open Policy Agent
install_opa() {
    curl -L -o opa https://openpolicyagent.org/downloads/v0.60.0/opa_linux_amd64_static &&
        sudo install -m 0755 opa /usr/local/bin/opa
    rm opa
}

# Function to install Terraform & Packer
install_terraform_packer() {
    wget -O- https://apt.releases.hashicorp.com/gpg |
        gpg --dearmor |
        tee /usr/share/keyrings/hashicorp-archive-keyring.gpg

    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
    https://apt.releases.hashicorp.com $(lsb_release -cs) main" |
        tee /etc/apt/sources.list.d/hashicorp.list &&
        $UPDATE && $INSTALL terraform packer
}

# Function to install Ansible
install_ansible() {
    add-apt-repository --yes --update ppa:ansible/ansible
    $UPDATE && $INSTALL ansible
}

# Function to install Podman & Podman Compose
install_podman() {
    $UPDATE && $INSTALL podman
    pip3 install podman-compose
}

# Function to install Terrascan
install_terrascan() {
    curl -L "$(curl -s https://api.github.com/repos/tenable/terrascan/releases/latest | grep -o -E "https://.+?_Linux_x86_64.tar.gz")" >terrascan.tar.gz
    tar -xf terrascan.tar.gz terrascan && rm terrascan.tar.gz
    install terrascan /usr/local/bin && rm terrascan
}

# Function to install Terrahub
install_terrahub() {
    npm install --global terrahub
}

# Function to install Terraform Docs
install_terraform_docs() {
    curl -Lo ./terraform-docs.tar.gz https://github.com/terraform-docs/terraform-docs/releases/download/v0.17.0/terraform-docs-v0.17.0-linux-arm64.tar.gz
    tar -xzf terraform-docs.tar.gz && rm terraform-docs.tar.gz
    chmod +x terraform-docs
    mv terraform-docs /usr/local/bin/terraform-docs
    rm LICENSE README.md
}

# Function to install Tfsec
install_tfsec() {
    curl -s https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | bash
}

# Function to install Infracost
install_infracost() {
    curl -fsSL https://raw.githubusercontent.com/infracost/infracost/master/scripts/install.sh | sh
}

# Main function
main() {
    install_gh_cli
    install_aws_cli
    install_azure_cli
    install_minikube
    install_kubectl
    install_opa
    install_terraform_packer
    install_ansible
    install_podman
    install_terrascan
    install_terrahub
    install_terraform_docs
    install_tfsec
    install_infracost
}

# Run the script
main
