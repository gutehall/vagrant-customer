#!/bin/bash

# Validation utility script
# This script provides various validation functions for the project

set -euo pipefail

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
    echo -e "[${timestamp}] [${level}] ${message}"
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

# Validate project structure
validate_project_structure() {
    info "Validating project structure..."
    
    local required_dirs=(
        "config"
        "docs"
        "examples"
        "scripts/install"
        "scripts/cleanup"
        "scripts/utils"
        "source"
        "templates"
    )
    
    local required_files=(
        "Vagrantfile"
        "scripts/core/setup.sh"
        "scripts/core/manage.sh"
        "Makefile"
        "README.md"
        ".gitignore"
        "config/config.yaml"
        "scripts/install/install.sh"
        "scripts/cleanup/cleanup.sh"
        "source/.zshrc"
        "source/.vimrc"
        "source/bullet-train.zsh-theme"
    )
    
    # Check directories
    for dir in "${required_dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            error_exit "Required directory '$dir' not found"
        fi
    done
    
    # Check files
    for file in "${required_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            error_exit "Required file '$file' not found"
        fi
    done
    
    success "Project structure validation passed"
}

# Validate script permissions
validate_script_permissions() {
    info "Validating script permissions..."
    
    local scripts=(
        "scripts/core/setup.sh"
        "scripts/core/manage.sh"
        "scripts/install/install.sh"
        "scripts/cleanup/cleanup.sh"
        "scripts/utils/validate.sh"
    )
    
    for script in "${scripts[@]}"; do
        if [[ ! -x "$script" ]]; then
            warning "Script '$script' is not executable. Fixing..."
            chmod +x "$script"
        fi
    done
    
    success "Script permissions validation passed"
}

# Validate configuration
validate_configuration() {
    info "Validating configuration..."
    
    # Check if config file exists and is valid YAML
    if [[ ! -f "config/config.yaml" ]]; then
        error_exit "Configuration file 'config/config.yaml' not found"
    fi
    
    # Basic YAML validation (if python and yaml module are available)
    if command -v python3 &> /dev/null; then
        if python3 -c "import yaml" 2>/dev/null; then
            if ! python3 -c "import yaml; yaml.safe_load(open('config/config.yaml'))" 2>/dev/null; then
                error_exit "Configuration file 'config/config.yaml' is not valid YAML"
            fi
        else
            warning "Python yaml module not available, skipping YAML validation"
        fi
    else
        warning "Python3 not available, skipping YAML validation"
    fi
    
    success "Configuration validation passed"
}

# Validate dependencies
validate_dependencies() {
    info "Validating dependencies..."
    
    # Check Vagrant
    if ! command -v vagrant &> /dev/null; then
        error_exit "Vagrant is not installed"
    fi
    
    # Check virtualization providers
    local providers=("virtualbox" "parallels" "vmware_desktop" "hyperv")
    local found_provider=false
    
    for provider in "${providers[@]}"; do
        case $provider in
            "virtualbox")
                if command -v VBoxManage &> /dev/null; then
                    found_provider=true
                    info "Found VirtualBox provider"
                fi
                ;;
            "parallels")
                if command -v prlctl &> /dev/null; then
                    found_provider=true
                    info "Found Parallels provider"
                fi
                ;;
            "vmware_desktop")
                if command -v vmrun &> /dev/null; then
                    found_provider=true
                    info "Found VMware provider"
                fi
                ;;
            "hyperv")
                if command -v hyperv &> /dev/null; then
                    found_provider=true
                    info "Found Hyper-V provider"
                fi
                ;;
        esac
    done
    
    if [[ "$found_provider" == "false" ]]; then
        warning "No virtualization provider found. Install VirtualBox, Parallels, VMware, or Hyper-V"
    fi
    
    success "Dependencies validation passed"
}

# Validate client environments
validate_client_environments() {
    info "Validating client environments..."
    
    local client_dir="client"
    if [[ ! -d "$client_dir" ]]; then
        info "No client environments found (this is normal for new installations)"
        return 0
    fi
    
    local valid_environments=0
    local invalid_environments=0
    
    for client in "$client_dir"/*; do
        if [[ -d "$client" ]]; then
            local client_name=$(basename "$client")
            local vagrantfile="$client/Vagrantfile"
            
            if [[ -f "$vagrantfile" ]]; then
                info "Validating client environment: $client_name"
                
                # Check if Vagrantfile is valid
                if cd "$client" && vagrant validate >/dev/null 2>&1; then
                    success "Client environment '$client_name' is valid"
                    ((valid_environments++))
                else
                    warning "Client environment '$client_name' has issues"
                    ((invalid_environments++))
                fi
                
                cd - > /dev/null
            else
                warning "Client environment '$client_name' missing Vagrantfile"
                ((invalid_environments++))
            fi
        fi
    done
    
    info "Client environments summary: $valid_environments valid, $invalid_environments with issues"
}

# Main validation function
main() {
    local command="${1:-all}"
    
    case "$command" in
        "structure")
            validate_project_structure
            ;;
        "permissions")
            validate_script_permissions
            ;;
        "config")
            validate_configuration
            ;;
        "deps")
            validate_dependencies
            ;;
        "clients")
            validate_client_environments
            ;;
        "all")
            validate_project_structure
            validate_script_permissions
            validate_configuration
            validate_dependencies
            validate_client_environments
            success "All validations completed successfully"
            ;;
        *)
            echo "Usage: $0 [structure|permissions|config|deps|clients|all]"
            echo "  structure  - Validate project structure"
            echo "  permissions - Validate script permissions"
            echo "  config     - Validate configuration files"
            echo "  deps       - Validate dependencies"
            echo "  clients    - Validate client environments"
            echo "  all        - Run all validations (default)"
            exit 1
            ;;
    esac
}

# Run main function
main "$@" 