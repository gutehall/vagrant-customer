#!/bin/bash

# Configuration
set -euo pipefail

# Constants
UPDATE="sudo apt-get update"
INSTALL="sudo apt-get -y install"
UPGRADE="sudo apt-get -y upgrade"
LOG_FILE="/tmp/install.log"
MAX_RETRIES=3

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Logging function
log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "[${timestamp}] [${level}] ${message}" | tee -a "$LOG_FILE"
}

# Error handling
error_exit() {
    log "ERROR" "$1"
    exit 1
}

# Success message
success() {
    log "SUCCESS" "$1"
}

# Warning message
warning() {
    log "WARNING" "$1"
}

# Info message
info() {
    log "INFO" "$1"
}

# Retry function
retry() {
    local cmd="$1"
    local description="$2"
    local retries=0
    
    while [[ $retries -lt $MAX_RETRIES ]]; do
        if eval "$cmd"; then
            return 0
        else
            retries=$((retries + 1))
            if [[ $retries -lt $MAX_RETRIES ]]; then
                warning "$description failed, retrying ($retries/$MAX_RETRIES)..."
                sleep 2
            else
                error_exit "$description failed after $MAX_RETRIES attempts"
            fi
        fi
    done
}

# Setup nameservers
setup_nameservers() {
    info "Setting up nameservers..."
    echo -e "nameserver 8.8.8.8\nnameserver 8.8.4.4" | sudo tee /etc/resolv.conf >/dev/null
    success "Nameservers configured"
}

# Update system
update_system() {
    info "Updating system packages..."
    retry "${UPDATE} && ${UPGRADE}" "System update"
    success "System updated successfully"
}

# Install essential packages
install_essentials() {
    info "Installing essential packages..."
    local essentials=(
        "curl" "wget" "git" "unzip" "software-properties-common"
        "apt-transport-https" "ca-certificates" "gnupg" "lsb-release"
    )
    
    for package in "${essentials[@]}"; do
        retry "${INSTALL} $package" "Install $package"
    done
    success "Essential packages installed"
}

# GitHub CLI
install_gh_cli() {
    info "Installing GitHub CLI..."
    retry "curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg" "Download GitHub CLI key"
    retry "sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg" "Set GitHub CLI key permissions"
    retry "echo 'deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main' | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null" "Add GitHub CLI repository"
    retry "${UPDATE} && ${INSTALL} gh" "Install GitHub CLI"
    success "GitHub CLI installed"
}

# AWS CLI v2
install_aws_cli() {
    info "Installing AWS CLI v2..."
    local arch=$(uname -m)
    local aws_url="https://awscli.amazonaws.com/awscli-exe-linux-${arch}.zip"
    
    retry "curl -L '$aws_url' -o awscliv2.zip" "Download AWS CLI"
    retry "unzip -q awscliv2.zip" "Extract AWS CLI"
    retry "sudo ./aws/install --update" "Install AWS CLI"
    retry "rm -rf aws*" "Clean up AWS CLI files"
    success "AWS CLI v2 installed"
}

# Azure CLI
install_azure_cli() {
    info "Installing Azure CLI..."
    retry "echo 'deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main' | sudo tee /etc/apt/sources.list.d/azure-cli.list" "Add Azure CLI repository"
    retry "curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg >/dev/null" "Add Microsoft GPG key"
    retry "${UPDATE} && ${INSTALL} azure-cli" "Install Azure CLI"
    success "Azure CLI installed"
}

# Bicep
install_bicep() {
    info "Installing Bicep..."
    retry "az bicep install" "Install Bicep"
    success "Bicep installed"
}

# Gcloud CLI
install_gcloud_cli() {
    info "Installing Google Cloud CLI..."
    retry "curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg" "Add Google Cloud GPG key"
    retry "echo 'deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main' | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list" "Add Google Cloud repository"
    retry "${UPDATE} && ${INSTALL} google-cloud-cli" "Install Google Cloud CLI"
    success "Google Cloud CLI installed"
}

# Minikube
install_minikube() {
    info "Installing Minikube..."
    local arch=$(uname -m)
    retry "curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-${arch}" "Download Minikube"
    retry "sudo install minikube-linux-${arch} /usr/local/bin/minikube" "Install Minikube"
    retry "rm minikube-linux-${arch}" "Clean up Minikube files"
    success "Minikube installed"
}

# Kubectl
install_kubectl() {
    info "Installing Kubectl..."
    local arch=$(uname -m)
    retry "curl -LO 'https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/${arch}/kubectl'" "Download Kubectl"
    retry "sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl" "Install Kubectl"
    retry "rm kubectl" "Clean up Kubectl files"
    success "Kubectl installed"
}

# Helm
install_helm() {
    info "Installing Helm..."
    retry "curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg >/dev/null" "Add Helm GPG key"
    retry "echo 'deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main' | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list" "Add Helm repository"
    retry "${UPDATE} && ${INSTALL} helm" "Install Helm"
    success "Helm installed"
}

# Kind
install_kind() {
    info "Installing Kind..."
    local arch=$(uname -m)
    retry "curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.21.0/kind-linux-${arch}" "Download Kind"
    retry "chmod +x ./kind && sudo mv ./kind /usr/local/bin/kind" "Install Kind"
    success "Kind installed"
}

# Kustomize
install_kustomize() {
    info "Installing Kustomize..."
    retry "curl -s 'https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh' | bash" "Install Kustomize"
    retry "sudo install -o root -g root -m 0755 kustomize /usr/local/bin/kustomize" "Move Kustomize to system path"
    retry "rm -rf kustomize" "Clean up Kustomize files"
    success "Kustomize installed"
}

# Open Policy Agent
install_opa() {
    info "Installing Open Policy Agent..."
    local arch=$(uname -m)
    retry "curl -L -o opa https://openpolicyagent.org/downloads/v0.60.0/opa_linux_${arch}_static" "Download OPA"
    retry "sudo install -m 0755 opa /usr/local/bin/opa" "Install OPA"
    retry "rm opa" "Clean up OPA files"
    success "Open Policy Agent installed"
}

# Terraform
install_terraform() {
    info "Installing Terraform..."
    retry "wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg" "Add HashiCorp GPG key"
    retry "echo 'deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main' | sudo tee /etc/apt/sources.list.d/hashicorp.list" "Add HashiCorp repository"
    retry "${UPDATE} && ${INSTALL} terraform" "Install Terraform"
    success "Terraform installed"
}

# Packer
install_packer() {
    info "Installing Packer..."
    retry "${UPDATE} && ${INSTALL} packer" "Install Packer"
    success "Packer installed"
}

# Ansible
install_ansible() {
    info "Installing Ansible..."
    retry "sudo add-apt-repository --yes --update ppa:ansible/ansible" "Add Ansible repository"
    retry "${UPDATE} && ${INSTALL} ansible" "Install Ansible"
    success "Ansible installed"
}

# Podman & Podman Compose
install_podman() {
    info "Installing Podman and Podman Compose..."
    retry "${UPDATE} && ${INSTALL} podman podman-compose" "Install Podman"
    success "Podman and Podman Compose installed"
}

# Colima
install_colima() {
    info "Installing Colima..."
    local os=$(uname -s | tr '[:upper:]' '[:lower:]')
    local arch=$(uname -m)
    retry "curl -LO https://github.com/abiosoft/colima/releases/download/v0.6.0/colima-${os}-${arch}" "Download Colima"
    retry "sudo install colima-${os}-${arch} /usr/local/bin/colima" "Install Colima"
    retry "rm colima-${os}-${arch}" "Clean up Colima files"
    success "Colima installed"
}



# Docker & Docker Compose
install_docker() {
    info "Installing Docker and Docker Compose..."
    retry "sudo install -m 0755 -d /etc/apt/keyrings" "Create Docker keyrings directory"
    retry "sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc" "Download Docker GPG key"
    retry "sudo chmod a+r /etc/apt/keyrings/docker.asc" "Set Docker key permissions"
    retry "echo 'deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable' | sudo tee /etc/apt/sources.list.d/docker.list" "Add Docker repository"
    retry "${UPDATE} && ${INSTALL} docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin" "Install Docker"
    retry "sudo curl -L 'https://github.com/docker/compose/releases/download/v2.28.1/docker-compose-$(uname -s)-$(uname -m)' -o /usr/local/bin/docker-compose" "Download Docker Compose"
    retry "sudo chmod +x /usr/local/bin/docker-compose" "Set Docker Compose permissions"
    success "Docker and Docker Compose installed"
}

# Terrascan
install_terrascan() {
    info "Installing Terrascan..."
    local arch=$(uname -m)
    retry "curl -L \"\$(curl -s https://api.github.com/repos/tenable/terrascan/releases/latest | grep -o -E 'https://.+?_Linux_${arch}.tar.gz')\" >terrascan.tar.gz" "Download Terrascan"
    retry "tar -xf terrascan.tar.gz terrascan && rm terrascan.tar.gz" "Extract Terrascan"
    retry "sudo install terrascan /usr/local/bin && rm terrascan" "Install Terrascan"
    success "Terrascan installed"
}

# Terrahub
install_terrahub() {
    info "Installing Terrahub..."
    retry "${UPDATE} && ${INSTALL} npm" "Install npm"
    retry "sudo npm install --global terrahub" "Install Terrahub"
    success "Terrahub installed"
}

# Terraform Docs
install_terraform_docs() {
    info "Installing Terraform Docs..."
    local arch=$(uname -m)
    retry "curl -Lo ./terraform-docs.tar.gz https://github.com/terraform-docs/terraform-docs/releases/download/v0.17.0/terraform-docs-v0.17.0-linux-${arch}.tar.gz" "Download Terraform Docs"
    retry "tar -xzf terraform-docs.tar.gz && rm terraform-docs.tar.gz" "Extract Terraform Docs"
    retry "sudo install terraform-docs /usr/local/bin/terraform-docs" "Install Terraform Docs"
    retry "rm LICENSE README.md" "Clean up Terraform Docs files"
    success "Terraform Docs installed"
}

# TerraTag
install_terratag() {
    info "Installing TerraTag..."
    local arch=$(uname -m)
    retry "curl -Lo ./terratag.tar.gz https://github.com/env0/terratag/releases/download/v0.3.1/terratag_0.3.1_linux_${arch}.tar.gz" "Download TerraTag"
    retry "tar -xzf terratag.tar.gz && rm terratag.tar.gz" "Extract TerraTag"
    retry "sudo install terratag /usr/local/bin/terratag" "Install TerraTag"
    retry "rm LICENSE README.md" "Clean up TerraTag files"
    success "TerraTag installed"
}

# Trivy
install_trivy() {
    info "Installing Trivy..."
    retry "wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg >/dev/null" "Add Trivy GPG key"
    retry "echo 'deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main' | sudo tee -a /etc/apt/sources.list.d/trivy.list" "Add Trivy repository"
    retry "${UPDATE} && ${INSTALL} trivy" "Install Trivy"
    success "Trivy installed"
}

# Infracost
install_infracost() {
    info "Installing Infracost..."
    retry "curl -fsSL https://raw.githubusercontent.com/infracost/infracost/master/scripts/install.sh | sh" "Install Infracost"
    success "Infracost installed"
}

# TFSwitch
install_tfswitch() {
    info "Installing TFSwitch..."
    retry "curl -L https://raw.githubusercontent.com/warrensbox/terraform-switcher/release/install.sh | bash" "Install TFSwitch"
    success "TFSwitch installed"
}

# TFLint
install_tflint() {
    info "Installing TFLint..."
    retry "curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash" "Install TFLint"
    success "TFLint installed"
}

# AWS CDK
install_aws_cdk() {
    info "Installing AWS CDK..."
    retry "sudo npm install -global aws-cdk" "Install AWS CDK"
    success "AWS CDK installed"
}

# shfmt
install_shfmt() {
    info "Installing shfmt..."
    retry "curl -sS https://webi.sh/shfmt | sh" "Install shfmt"
    retry "source ~/.config/envman/PATH.env" "Source shfmt environment"
    retry "rm -rf Downloads" "Clean up shfmt files"
    success "shfmt installed"
}

# Serverless
install_serverless() {
    info "Installing Serverless..."
    retry "sudo npm install -global serverless" "Install Serverless"
    success "Serverless installed"
}

# Monitoring Tools

# Prometheus
install_prometheus() {
    info "Installing Prometheus..."
    local arch=$(uname -m)
    retry "curl -LO https://github.com/prometheus/prometheus/releases/download/v2.48.0/prometheus-2.48.0.linux-${arch}.tar.gz" "Download Prometheus"
    retry "tar -xzf prometheus-2.48.0.linux-${arch}.tar.gz" "Extract Prometheus"
    retry "sudo install prometheus-2.48.0.linux-${arch}/prometheus /usr/local/bin/prometheus" "Install Prometheus"
    retry "rm -rf prometheus-2.48.0.linux-${arch}*" "Clean up Prometheus files"
    success "Prometheus installed"
}

# Grafana
install_grafana() {
    info "Installing Grafana..."
    retry "wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -" "Add Grafana GPG key"
    retry "echo 'deb https://packages.grafana.com/oss/deb stable main' | sudo tee /etc/apt/sources.list.d/grafana.list" "Add Grafana repository"
    retry "${UPDATE} && ${INSTALL} grafana" "Install Grafana"
    success "Grafana installed"
}

# Jaeger
install_jaeger() {
    info "Installing Jaeger..."
    local arch=$(uname -m)
    retry "curl -LO https://github.com/jaegertracing/jaeger/releases/download/v1.53.0/jaeger-1.53.0-linux-${arch}.tar.gz" "Download Jaeger"
    retry "tar -xzf jaeger-1.53.0-linux-${arch}.tar.gz" "Extract Jaeger"
    retry "sudo install jaeger-1.53.0-linux-${arch}/jaeger-all-in-one /usr/local/bin/jaeger-all-in-one" "Install Jaeger"
    retry "rm -rf jaeger-1.53.0-linux-${arch}*" "Clean up Jaeger files"
    success "Jaeger installed"
}

# Fluentd
install_fluentd() {
    info "Installing Fluentd..."
    retry "curl -L https://toolbelt.treasuredata.com/sh/install-debian-$(lsb_release -cs)-td-agent4.sh | sh" "Install Fluentd"
    success "Fluentd installed"
}

# Elasticsearch
install_elasticsearch() {
    info "Installing Elasticsearch..."
    retry "wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg" "Add Elasticsearch GPG key"
    retry "echo 'deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main' | sudo tee /etc/apt/sources.list.d/elastic-8.x.list" "Add Elasticsearch repository"
    retry "${UPDATE} && ${INSTALL} elasticsearch" "Install Elasticsearch"
    success "Elasticsearch installed"
}

# CI/CD Tools

# Jenkins
install_jenkins() {
    info "Installing Jenkins..."
    retry "curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null" "Add Jenkins GPG key"
    retry "echo 'deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/' | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null" "Add Jenkins repository"
    retry "${UPDATE} && ${INSTALL} jenkins" "Install Jenkins"
    success "Jenkins installed"
}

# GitLab CLI
install_gitlab_cli() {
    info "Installing GitLab CLI..."
    local arch=$(uname -m)
    retry "curl -Lo glab https://gitlab.com/gitlab-org/cli/-/releases/v1.35.0/downloads/glab_1.35.0_Linux_${arch}.tar.gz" "Download GitLab CLI"
    retry "tar -xzf glab && sudo install glab /usr/local/bin/glab" "Install GitLab CLI"
    retry "rm glab" "Clean up GitLab CLI files"
    success "GitLab CLI installed"
}

# ArgoCD
install_argocd() {
    info "Installing ArgoCD..."
    retry "curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64" "Download ArgoCD"
    retry "sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd" "Install ArgoCD"
    retry "rm argocd-linux-amd64" "Clean up ArgoCD files"
    success "ArgoCD installed"
}

# Tekton
install_tekton() {
    info "Installing Tekton CLI..."
    retry "curl -LO https://github.com/tektoncd/cli/releases/download/v0.32.0/tkn_0.32.0_Linux_x86_64.tar.gz" "Download Tekton CLI"
    retry "sudo tar xvzf tkn_0.32.0_Linux_x86_64.tar.gz -C /usr/local/bin/ tkn" "Install Tekton CLI"
    retry "rm tkn_0.32.0_Linux_x86_64.tar.gz" "Clean up Tekton CLI files"
    success "Tekton CLI installed"
}

# CircleCI CLI
install_circleci_cli() {
    info "Installing CircleCI CLI..."
    retry "curl -fLSs https://circle.ci/cli | bash" "Install CircleCI CLI"
    success "CircleCI CLI installed"
}

# Database Tools

# PostgreSQL Client
install_postgresql_client() {
    info "Installing PostgreSQL Client..."
    retry "${UPDATE} && ${INSTALL} postgresql-client" "Install PostgreSQL Client"
    success "PostgreSQL Client installed"
}

# MySQL Client
install_mysql_client() {
    info "Installing MySQL Client..."
    retry "${UPDATE} && ${INSTALL} mysql-client" "Install MySQL Client"
    success "MySQL Client installed"
}

# Redis CLI
install_redis_cli() {
    info "Installing Redis CLI..."
    retry "${UPDATE} && ${INSTALL} redis-tools" "Install Redis CLI"
    success "Redis CLI installed"
}

# MongoDB Tools
install_mongodb_tools() {
    info "Installing MongoDB Tools..."
    retry "wget -qO - https://www.mongodb.org/static/pgp/server-7.0.asc | sudo apt-key add -" "Add MongoDB GPG key"
    retry "echo 'deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse' | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list" "Add MongoDB repository"
    retry "${UPDATE} && ${INSTALL} mongodb-mongosh" "Install MongoDB Tools"
    success "MongoDB Tools installed"
}

# SQLite
install_sqlite() {
    info "Installing SQLite..."
    retry "${UPDATE} && ${INSTALL} sqlite3" "Install SQLite"
    success "SQLite installed"
}

# Networking Tools

# Istio
install_istio() {
    info "Installing Istio..."
    retry "curl -L https://istio.io/downloadIstio | sh -" "Download Istio"
    retry "sudo install istio-*/bin/istioctl /usr/local/bin/istioctl" "Install Istio CLI"
    retry "rm -rf istio-*" "Clean up Istio files"
    success "Istio CLI installed"
}

# Linkerd
install_linkerd() {
    info "Installing Linkerd..."
    retry "curl -sL https://run.linkerd.io/install | sh" "Install Linkerd"
    success "Linkerd installed"
}

# Consul
install_consul() {
    info "Installing Consul..."
    local arch=$(uname -m)
    retry "curl -LO https://releases.hashicorp.com/consul/1.16.0/consul_1.16.0_linux_${arch}.zip" "Download Consul"
    retry "unzip consul_1.16.0_linux_${arch}.zip && sudo install consul /usr/local/bin/consul" "Install Consul"
    retry "rm consul consul_1.16.0_linux_${arch}.zip" "Clean up Consul files"
    success "Consul installed"
}

# Vault
install_vault() {
    info "Installing Vault..."
    local arch=$(uname -m)
    retry "curl -LO https://releases.hashicorp.com/vault/1.15.0/vault_1.15.0_linux_${arch}.zip" "Download Vault"
    retry "unzip vault_1.15.0_linux_${arch}.zip && sudo install vault /usr/local/bin/vault" "Install Vault"
    retry "rm vault vault_1.15.0_linux_${arch}.zip" "Clean up Vault files"
    success "Vault installed"
}

# Nginx
install_nginx() {
    info "Installing Nginx..."
    retry "${UPDATE} && ${INSTALL} nginx" "Install Nginx"
    success "Nginx installed"
}

# Testing Tools

# Selenium
install_selenium() {
    info "Installing Selenium..."
    retry "${UPDATE} && ${INSTALL} chromium-browser" "Install Chromium for Selenium"
    retry "sudo npm install -global selenium-standalone" "Install Selenium Standalone"
    success "Selenium installed"
}

# JMeter
install_jmeter() {
    info "Installing JMeter..."
    retry "${UPDATE} && ${INSTALL} openjdk-11-jre" "Install Java for JMeter"
    retry "curl -LO https://downloads.apache.org/jmeter/binaries/apache-jmeter-5.6.2.tgz" "Download JMeter"
    retry "tar -xzf apache-jmeter-5.6.2.tgz && sudo mv apache-jmeter-5.6.2 /opt/jmeter" "Install JMeter"
    retry "sudo ln -s /opt/jmeter/bin/jmeter /usr/local/bin/jmeter" "Create JMeter symlink"
    retry "rm apache-jmeter-5.6.2.tgz" "Clean up JMeter files"
    success "JMeter installed"
}

# Artillery
install_artillery() {
    info "Installing Artillery..."
    retry "sudo npm install -global artillery" "Install Artillery"
    success "Artillery installed"
}

# K6
install_k6() {
    info "Installing K6..."
    retry "sudo gpg -k" "Initialize GPG"
    retry "sudo gpg --no-default-keyring --keyring /usr/share/keyrings/k6-archive-keyring.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C5AD17C747E3415A3642D57D77C6C491D6AC1D69" "Add K6 GPG key"
    retry "echo 'deb [signed-by=/usr/share/keyrings/k6-archive-keyring.gpg] https://dl.k6.io/deb stable main' | sudo tee /etc/apt/sources.list.d/k6.list" "Add K6 repository"
    retry "${UPDATE} && ${INSTALL} k6" "Install K6"
    success "K6 installed"
}

# Postman
install_postman() {
    info "Installing Postman..."
    retry "wget -O postman.tar.gz https://dl.pstmn.io/download/latest/linux64" "Download Postman"
    retry "sudo tar -xzf postman.tar.gz -C /opt" "Extract Postman"
    retry "sudo ln -s /opt/Postman/Postman /usr/local/bin/postman" "Create Postman symlink"
    retry "rm postman.tar.gz" "Clean up Postman files"
    success "Postman installed"
}

# Productivity Tools

# JQ
install_jq() {
    info "Installing JQ..."
    retry "${UPDATE} && ${INSTALL} jq" "Install JQ"
    success "JQ installed"
}

# YQ
install_yq() {
    info "Installing YQ..."
    local arch=$(uname -m)
    retry "curl -LO https://github.com/mikefarah/yq/releases/download/v4.40.5/yq_linux_${arch}.tar.gz" "Download YQ"
    retry "tar -xzf yq_linux_${arch}.tar.gz && sudo install yq_linux_${arch} /usr/local/bin/yq" "Install YQ"
    retry "rm yq_linux_${arch}*" "Clean up YQ files"
    success "YQ installed"
}

# FZF
install_fzf() {
    info "Installing FZF..."
    retry "git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf" "Clone FZF"
    retry "~/.fzf/install --all" "Install FZF"
    success "FZF installed"
}

# Ripgrep
install_ripgrep() {
    info "Installing Ripgrep..."
    retry "curl -LO https://github.com/BurntSushi/ripgrep/releases/download/14.0.3/ripgrep-14.0.3-x86_64-unknown-linux-musl.tar.gz" "Download Ripgrep"
    retry "tar -xzf ripgrep-14.0.3-x86_64-unknown-linux-musl.tar.gz" "Extract Ripgrep"
    retry "sudo install ripgrep-14.0.3-x86_64-unknown-linux-musl/rg /usr/local/bin/rg" "Install Ripgrep"
    retry "rm -rf ripgrep-14.0.3-x86_64-unknown-linux-musl*" "Clean up Ripgrep files"
    success "Ripgrep installed"
}

# Bat
install_bat() {
    info "Installing Bat..."
    local arch=$(uname -m)
    retry "curl -LO https://github.com/sharkdp/bat/releases/download/v0.24.0/bat-v0.24.0-x86_64-unknown-linux-musl.tar.gz" "Download Bat"
    retry "tar -xzf bat-v0.24.0-x86_64-unknown-linux-musl.tar.gz" "Extract Bat"
    retry "sudo install bat-v0.24.0-x86_64-unknown-linux-musl/bat /usr/local/bin/bat" "Install Bat"
    retry "rm -rf bat-v0.24.0-x86_64-unknown-linux-musl*" "Clean up Bat files"
    success "Bat installed"
}

# Main installation function
main() {
    info "Starting DevOps tools installation..."
    
    # Initialize log file
    echo "=== Installation Log - $(date) ===" > "$LOG_FILE"
    
    # Setup basic environment
    setup_nameservers
    update_system
    install_essentials
    
    # Install selected tools (these will be called based on user selection)
    # The actual calls are generated by the setup script
    success "Installation completed successfully"
}

# Run main function
main "$@"