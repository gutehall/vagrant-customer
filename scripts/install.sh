#!/bin/bash

# Before running the script, comment out what's not needed in main function below.

PACKAGE_MANAGER="sudo apt-get"
UPDATE="${PACKAGE_MANAGER} update"
INSTALL="${PACKAGE_MANAGER} -y install"

# Function to install GitHub CLI
install_gh_cli() {
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg &&
        sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg &&
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null &&
        ${UPDATE} && ${INSTALL} gh
}

# Function to install AWS CLI v2
install_aws_cli() {
    curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip"
    unzip -q awscliv2.zip
    sudo ./aws/install
    rm -rf aws*
}

# Function to install Azure CLI
install_azure_cli() {
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/azure-cli.list
    curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg >/dev/null
    ${UPDATE} && ${INSTALL} azure-cli
}

# Function to install Bicep
install_bicep() {
    curl -Lo bicep https://github.com/Azure/bicep/releases/latest/download/bicep-linux-x64
    chmod +x ./bicep
    sudo mv ./bicep /usr/local/bin/bicep
}

# Function to install Gcloud CLI
install_gcloud_cli() {
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
    ${UPDATE} && ${INSTALL} google-cloud-cli
}

# Function to install PowerShell
install_powershell() {
    source /etc/os-release
    wget -q https://packages.microsoft.com/config/debian/$VERSION_ID/packages-microsoft-prod.deb
    sudo dpkg -i packages-microsoft-prod.deb
    rm packages-microsoft-prod.deb
    ${UPDATE} && ${INSTALL} powershell
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

# Function to install Helm
install_helm() {
    curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg >/dev/null
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
    ${UPDATE} && ${INSTALL} helm
}

# Function to install Kind
install_kind() {
    [ $(uname -m) = aarch64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.21.0/kind-linux-arm64
    chmod +x ./kind
    sudo mv ./kind /usr/local/bin/kind
}

# Function to install Kustomize
install_kustomize() {
    curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash
}

# Function to install Open Policy Agent
install_opa() {
    curl -L -o opa https://openpolicyagent.org/downloads/v0.60.0/opa_linux_amd64_static &&
        sudo install -m 0755 opa /usr/local/bin/opa
    rm opa
}

# Function to install Terraform
install_terraform() {
    wget -O- https://apt.releases.hashicorp.com/gpg |
        gpg --dearmor |
        tee /usr/share/keyrings/hashicorp-archive-keyring.gpg

    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
    https://apt.releases.hashicorp.com $(lsb_release -cs) main" |
        tee /etc/apt/sources.list.d/hashicorp.list &&
        $UPDATE && $INSTALL terraform
}

# Function to install Packer
install_packer() {
    $UPDATE && $INSTALL packer
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

# Function to install Colima
install_colima() {
    curl -LO https://github.com/abiosoft/colima/releases/download/v0.6.0/colima-$(uname)-$(uname -m)
    install colima-$(uname)-$(uname -m) /usr/local/bin/colima
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

# Function to install TerraTag
install_terratag() {
    curl -Lo ./terratag.tar.gz https://github.com/env0/terratag/releases/download/v0.3.1/terratag_0.3.1_linux_arm64.tar.gz
    tar -xzf terratag.tar.gz && rm terratag.tar.gz
    chmod +x terratag
    mv terratag /usr/local/bin/terratag
    rm LICENSE README.md
}

# Function to install Tfsec
install_trivy() {
    wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg >/dev/null
    echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
    $UPDATE && $INSTALL trivy

}

# Function to install Infracost
install_infracost() {
    curl -fsSL https://raw.githubusercontent.com/infracost/infracost/master/scripts/install.sh | sh
}

# Function to install TFSwitch
install_tfswitch() {
    curl -L https://raw.githubusercontent.com/warrensbox/terraform-switcher/release/install.sh | bash
}

# Function to install TFLint
install_tflint() {
    curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash
}

# Function to install AWS CDK
install_aws_cdk() {
    $UPDATE && $INSTALL npm
    npm install -g aws-cdk
}

# Function to install shfmt
install_shfmt() {
    curl -sS https://webi.sh/shfmt | sh
    source ~/.config/envman/PATH.env
}

# Run the script
main
