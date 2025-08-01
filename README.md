# Vagrant DevOps Environment Setup

A comprehensive, optimized Vagrant-based DevOps environment setup tool that creates isolated development environments for different clients.

## 🚀 Features

### Core Features
- **Isolated Client Environments**: Each client gets their own isolated VM environment
- **Multi-Provider Support**: Works with Parallels, VirtualBox, VMware, and Hyper-V
- **Comprehensive DevOps Toolset**: 61+ tools across 12 categories
- **Automated Setup**: One-command setup with interactive tool selection
- **File Synchronization**: Automatic sync between local and VM directories

### Tool Categories
- **Cloud CLIs** (5 tools) - AWS, Azure, GCP, GitHub
- **Kubernetes** (5 tools) - Minikube, Kubectl, Helm, Kind, Kustomize
- **Infrastructure** (4 tools) - Terraform, Packer, Ansible, OPA
- **Containers** (4 tools) - Docker, Podman, Colima, Apple Containerization
- **Security** (3 tools) - Terrascan, Trivy, Tfsec
- **Terraform Ecosystem** (5 tools) - Docs, Tfswitch, Tflint, Terratag, Infracost
- **Development** (4 tools) - AWS CDK, Shfmt, Serverless, Terrahub
- **Monitoring** (5 tools) - Prometheus, Grafana, Jaeger, Fluentd, Elasticsearch
- **CI/CD** (5 tools) - Jenkins, GitLab CLI, ArgoCD, Tekton, CircleCI CLI
- **Database** (5 tools) - PostgreSQL, MySQL, Redis, MongoDB, SQLite
- **Networking** (5 tools) - Istio, Linkerd, Consul, Vault, Nginx
- **Testing** (5 tools) - Selenium, JMeter, Artillery, K6, Postman
- **Productivity** (5 tools) - JQ, YQ, FZF, Ripgrep, Bat

## 🛠️ Prerequisites

- **Vagrant** (2.4.1 or later)
- **Virtualization Provider**: Parallels Desktop 19, VMware Fusion 13.5, VirtualBox 7, or Hyper-V
- **macOS Sonoma** (tested platform)
- **Bash** shell

## 📦 Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/gutehall/vagrant-customer.git
   cd vagrant-customer
   ```

2. **Install dependencies** (optional but recommended):
   ```bash
   make install-deps
   ```

3. **Validate the installation**:
   ```bash
   make validate
   ```

## 🎮 Usage

### Quick Start

```bash
# Create a new client environment
make setup CLIENT=myclient

# Start the environment
make start CLIENT=myclient

# Connect to the environment
make ssh CLIENT=myclient

# Check status
make status CLIENT=myclient
```

### 🎯 **Primary Interface: Makefile**

The **Makefile is the primary interface** for all operations. It provides a clean, consistent way to manage your DevOps environments:

```bash
# 🚀 Quick Start Commands
make setup CLIENT=myproject    # Create new environment
make start CLIENT=myproject    # Start environment
make ssh CLIENT=myproject      # Connect to environment
make status CLIENT=myproject   # Check environment status

# 🔧 Management Commands
make validate                  # Validate configuration
make clean                     # Clean up temporary files
make test                      # Run all tests

# 🛠️ Development Commands
make docs                      # Generate documentation
make install-deps              # Install development dependencies
make update-deps               # Update dependencies
make lint                      # Check script syntax

# 📚 Examples and Templates
make example NAME=myexample    # Create new example
make install                   # Install globally
make uninstall                 # Uninstall global commands

# 📖 Show all available commands
make help
```

### 🔄 **Alternative Interface: Direct Scripts**

For advanced users, you can also use the scripts directly:

```bash
# Direct script usage (not recommended for regular use)
./scripts/core/manage.sh setup myproject
./scripts/core/manage.sh start myproject
./scripts/core/manage.sh ssh myproject
```

### Management Commands

The `manage.sh` script provides comprehensive environment management:

```bash
# List all client environments
./manage.sh list

# Start a client environment
./manage.sh start <client_name>

# Stop a client environment
./manage.sh stop <client_name>

# Destroy a client environment
./manage.sh destroy <client_name>

# SSH into a client environment
./manage.sh ssh <client_name>

# Show environment status
./manage.sh status <client_name>

# Clean up a client environment
./manage.sh cleanup <client_name>

# Show logs
./manage.sh logs <client_name>

# Validate project configuration
./manage.sh validate

# Show help
./manage.sh help
```

### Direct Setup (Legacy Method)

```bash
# Run the interactive setup
./setup.sh
```

## 🛠️ Available Tools

### Cloud CLIs
- **GitHub CLI** - GitHub command-line interface
- **AWS CLI v2** - Amazon Web Services CLI
- **Azure CLI** - Microsoft Azure CLI
- **Bicep** - Azure Bicep language
- **Google Cloud CLI** - Google Cloud Platform CLI

### Kubernetes Tools
- **Minikube** - Local Kubernetes cluster
- **Kubectl** - Kubernetes command-line tool
- **Helm** - Kubernetes package manager
- **Kind** - Kubernetes in Docker
- **Kustomize** - Kubernetes native configuration management

### Infrastructure Tools
- **Terraform** - Infrastructure as Code
- **Packer** - Machine image creation
- **Ansible** - Configuration management
- **Open Policy Agent** - Policy engine

### Container Tools
- **Docker & Docker Compose** - Container platform
- **Podman & Podman Compose** - Container engine
- **Colima** - Container runtime for macOS
- **Apple Containerization** - Native Linux containers on Apple Silicon

### Security Tools
- **Terrascan** - Security scanner for IaC
- **Trivy** - Vulnerability scanner
- **Tfsec** - Terraform security scanner

### Terraform Ecosystem
- **Terraform Docs** - Documentation generator
- **Tfswitch** - Terraform version manager
- **Tflint** - Terraform linter
- **Terratag** - Resource tagging
- **Infracost** - Cost estimation

### Development Tools
- **AWS CDK** - Cloud Development Kit
- **Shfmt** - Shell script formatter
- **Serverless** - Serverless framework
- **Terrahub** - Terraform automation

### Monitoring & Observability
- **Prometheus** - Monitoring system and time series database
- **Grafana** - Analytics and monitoring platform
- **Jaeger** - Distributed tracing system
- **Fluentd** - Data collection and forwarding
- **Elasticsearch** - Search and analytics engine

### CI/CD Tools
- **Jenkins** - Automation server
- **GitLab CLI** - GitLab command-line interface
- **ArgoCD** - GitOps continuous delivery
- **Tekton** - Cloud-native CI/CD
- **CircleCI CLI** - CircleCI command-line interface

### Database Tools
- **PostgreSQL Client** - PostgreSQL command-line tools
- **MySQL Client** - MySQL command-line tools
- **Redis CLI** - Redis command-line interface
- **MongoDB Tools** - MongoDB utilities and shell
- **SQLite** - Lightweight database engine

### Networking & Service Mesh
- **Istio** - Service mesh platform
- **Linkerd** - Lightweight service mesh
- **Consul** - Service mesh and service discovery
- **Vault** - Secrets management and encryption
- **Nginx** - Web server and reverse proxy

### Testing Tools
- **Selenium** - Web browser automation
- **JMeter** - Load testing and performance measurement
- **Artillery** - Load testing toolkit
- **K6** - Modern load testing tool
- **Postman** - API development and testing

### Productivity Tools
- **JQ** - Command-line JSON processor
- **YQ** - Command-line YAML processor
- **FZF** - Fuzzy finder for command line
- **Ripgrep** - Fast line-oriented search tool
- **Bat** - Cat clone with syntax highlighting

## ⚙️ Configuration

The project uses a centralized `config.yaml` file for all configuration:

```yaml
# VM Configuration
vm:
  box: "gutehall/debian-12"
  memory: 2048
  cpus: 2
  name: "devbox"
  timezone: "Europe/Stockholm"

# Provider configurations
providers:
  parallels:
    memory: 2048
    cpus: 2
    update_guest_tools: true

# Available tools
tools:
  cloud_cli: ["GitHub CLI", "AWS CLI v2", "Azure CLI"]
  kubernetes: ["Minikube", "Kubectl", "Helm"]
  # ... more tool categories
```


## 🔧 Customization

### Adding New Tools

1. **Add tool to `config.yaml`**:
   ```yaml
   tools:
     new_category:
       - "New Tool Name"
   ```

2. **Create installation function in `scripts/install.sh`**:
   ```bash
   install_new_tool() {
       info "Installing New Tool..."
       retry "installation_command" "Install New Tool"
       success "New Tool installed"
   }
   ```

3. **Update setup script to include the new tool in the options list**

### Modifying VM Configuration

Edit the `config.yaml` file to modify:
- VM resources (memory, CPU)
- Base box
- Provider-specific settings
- Timezone
- Network configuration

## 🐛 Troubleshooting

### Common Issues

1. **Vagrant not found**:
   ```bash
   # Install Vagrant
   brew install vagrant
   ```

2. **Permission denied**:
   ```bash
   chmod +x setup.sh manage.sh
   ```

3. **VM fails to start**:
   ```bash
   # Check provider status
   ./manage.sh status <client_name>
   
   # View logs
   ./manage.sh logs <client_name>
   ```

4. **Tool installation fails**:
   ```bash
   # Clean up and retry
   ./manage.sh cleanup <client_name>
   ./manage.sh start <client_name>
   ```

### Log Files

- **Setup logs**: `/tmp/vagrant_setup.log`
- **Installation logs**: `/tmp/install.log`
- **Cleanup logs**: `/tmp/cleanup.log`
- **Manager logs**: `/tmp/vagrant_manager.log`

## 🔄 Updates and Maintenance

### Updating the Project

```bash
# Pull latest changes
git pull origin main

# Validate configuration
./manage.sh validate

# Update existing environments (if needed)
./manage.sh update
```

### Cleaning Up

```bash
# Clean up a specific environment
./manage.sh cleanup <client_name>

# Destroy unused environments
./manage.sh destroy <client_name>

# Clean up all environments
./manage.sh destroy --all
```

