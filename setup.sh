#!/bin/bash

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="/tmp/vagrant_setup.log"
CLIENT_DIR="client"
DEFAULT_LOCAL_PATH="$HOME/Projects"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Check prerequisites
check_prerequisites() {
    info "Checking prerequisites..."
    
    # Check if Vagrant is installed
    if ! command -v vagrant &> /dev/null; then
        error_exit "Vagrant is not installed. Please install Vagrant first."
    fi
    
    # Check if required files exist
    local required_files=("Vagrantfile" "scripts/install.sh")
    for file in "${required_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            error_exit "Required file '$file' not found."
        fi
    done
    
    # Check if setup.sh has execute permissions
    if [[ ! -x "$0" ]]; then
        error_exit "This script does not have execute permissions. Run: chmod +x $0"
    fi
    
    success "Prerequisites check passed"
}

# Function to prompt for input and validate folder name
prompt_folder_name() {
    while true; do
        echo -e "${BLUE}Enter the name for the new client:${NC} "
        read -r folder_name
        
        # Validate folder name
        if [[ -z "$folder_name" ]]; then
            echo -e "${RED}Error: Folder name cannot be empty.${NC}"
            continue
        fi
        
        if [[ "$folder_name" =~ ^[[:alnum:]]+$ ]]; then
            # Check if folder already exists
            if [[ -d "$CLIENT_DIR/$folder_name" ]]; then
                echo -e "${YELLOW}Warning: Client folder '$folder_name' already exists.${NC}"
                read -p "Do you want to overwrite it? (y/N): " -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    rm -rf "$CLIENT_DIR/$folder_name"
                    break
                else
                    continue
                fi
            else
                break
            fi
        else
            echo -e "${RED}Error: Folder name can only contain letters and numbers.${NC}"
        fi
    done
}

# Function to prompt for input and validate local path
prompt_local_path() {
    while true; do
        echo -e "${BLUE}Enter the path where you want to sync locally (default: $DEFAULT_LOCAL_PATH):${NC} "
        read -r local_path
        
        # Use default if empty
        if [[ -z "$local_path" ]]; then
            local_path="$DEFAULT_LOCAL_PATH"
        fi
        
        # Create directory if it doesn't exist
        if [[ ! -d "$local_path" ]]; then
            echo -e "${YELLOW}Directory '$local_path' does not exist.${NC}"
            read -p "Do you want to create it? (Y/n): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Nn]$ ]]; then
                continue
            else
                if mkdir -p "$local_path"; then
                    success "Created directory '$local_path'"
                else
                    error_exit "Failed to create directory '$local_path'"
                fi
            fi
        fi
        
        # Check if path is writable
        if [[ ! -w "$local_path" ]]; then
            error_exit "Directory '$local_path' is not writable."
        fi
        
        break
    done
}

# Function to create folders and copy files
create_and_copy_files() {
    info "Creating client directory structure..."
    
    # Create client directory
    if mkdir -p "$CLIENT_DIR/$folder_name"; then
        success "Created client directory '$CLIENT_DIR/$folder_name'"
    else
        error_exit "Failed to create client directory"
    fi
    
    # Create local sync directory
    if mkdir -p "$local_path/$folder_name"; then
        success "Created local sync directory '$local_path/$folder_name'"
    else
        error_exit "Failed to create local sync directory"
    fi
    
    # Copy required files
    local files_to_copy=("Vagrantfile" "scripts/install.sh")
    for file in "${files_to_copy[@]}"; do
        if [[ -f "$file" ]]; then
            if cp "$file" "$CLIENT_DIR/$folder_name/$(basename "$file")"; then
                success "Copied '$(basename "$file")' to client directory"
            else
                error_exit "Failed to copy '$file'"
            fi
        else
            error_exit "Required file '$file' not found"
        fi
    done
}

# Function to update Vagrantfile with sync folder
update_vagrantfile() {
    info "Updating Vagrantfile with sync folder configuration..."
    
    local vagrantfile_path="$CLIENT_DIR/$folder_name/Vagrantfile"
    local sync_config="config.vm.synced_folder \"$local_path/$folder_name\", \"/home/vagrant/code/\", :owner => \"vagrant\""
    
    # Add sync folder configuration after box_check_update line
    if sed -i "/config.vm.box_check_update = false/a\\
    $sync_config" "$vagrantfile_path"; then
        success "Updated Vagrantfile with sync folder configuration"
    else
        error_exit "Failed to update Vagrantfile"
    fi
}

# Function to prompt for installation choices
prompt_installation() {
    info "Configuring tool installation..."
    
    local choices=()
    local choice
    local options=(
        # Cloud CLIs
        "GitHub CLI" "AWS CLI v2" "Azure CLI" "Bicep" "Gcloud CLI"
        # Kubernetes
        "Minikube" "Kubectl" "Helm" "Kind" "Kustomize"
        # Infrastructure
        "Open Policy Agent" "Terraform" "Packer" "Ansible"
        # Containers
        "Docker & Docker Compose" "Colima" "Podman & Podman Compose"
        # Security
        "Terrascan" "Trivy" "Tfsec"
        # Terraform Tools
        "Terraform Docs" "Tfswitch" "Tflint" "Terratag" "Infracost"
        # Development
        "AWS CDK" "Shfmt" "Serverless" "Terrahub"
        # Monitoring
        "Prometheus" "Grafana" "Jaeger" "Fluentd" "Elasticsearch"
        # CI/CD
        "Jenkins" "GitLab CLI" "ArgoCD" "Tekton" "CircleCI CLI"
        # Database
        "PostgreSQL Client" "MySQL Client" "Redis CLI" "MongoDB Tools" "SQLite"
        # Networking
        "Istio" "Linkerd" "Consul" "Vault" "Nginx"
        # Testing
        "Selenium" "JMeter" "Artillery" "K6" "Postman"
        # Productivity
        "JQ" "YQ" "FZF" "Ripgrep" "Bat"
    )

    while true; do
        echo -e "\n${BLUE}Which applications would you like to install?${NC}"
        echo -e "${YELLOW}0. Select All${NC}"
        for i in "${!options[@]}"; do
            echo "$((i + 1)). ${options[$i]}"
        done
        echo -e "${YELLOW}29. Exit${NC}"

        echo -e "\n${BLUE}Enter your choices (space-separated):${NC} "
        read -r choices_input

        if [[ $choices_input == "0" ]]; then
            choices=("${options[@]}")
            break
        else
            for choice in $choices_input; do
                if ((choice >= 1 && choice <= ${#options[@]})); then
                    choices+=("${options[$((choice - 1))]}")
                elif [[ $choice == "29" ]]; then
                    break 2
                else
                    echo -e "${RED}Invalid choice: $choice. Please enter valid numbers from the menu.${NC}"
                fi
            done
        fi

        if [[ ${#choices[@]} -gt 0 ]]; then
            echo -e "\n${GREEN}Selected tools:${NC}"
            printf '%s\n' "${choices[@]}"
            
            read -p "Are you done selecting applications? (Y/n): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Nn]$ ]]; then
                choices=()
                continue
            else
                break
            fi
        fi
    done

    # Create install script
    local install_script="$CLIENT_DIR/$folder_name/install.sh"
    echo "#!/bin/bash" > "$install_script"
    echo "set -euo pipefail" >> "$install_script"
    echo "" >> "$install_script"
    
    for choice in "${choices[@]}"; do
        echo "install_${choice// /_}" >> "$install_script"
    done
    
    chmod +x "$install_script"
    success "Created installation script with ${#choices[@]} tools"
}

# Function to start Vagrant
start_vagrant() {
    info "Starting Vagrant environment..."
    
    cd "$CLIENT_DIR/$folder_name" || error_exit "Failed to change to client directory"
    
    # Run vagrant up
    echo -e "\n${BLUE}Running vagrant up...${NC}"
    if vagrant up; then
        success "Vagrant environment started successfully"
    else
        error_exit "Failed to start Vagrant environment"
    fi
    
    # Show SSH configuration
    echo -e "\n${BLUE}SSH Configuration:${NC}"
    vagrant ssh-config
    
    echo -e "\n${GREEN}Setup completed successfully!${NC}"
    echo -e "${BLUE}To connect to your environment:${NC}"
    echo -e "  cd $CLIENT_DIR/$folder_name"
    echo -e "  vagrant ssh"
    echo -e "\n${BLUE}Your code will be synced to:${NC}"
    echo -e "  Local: $local_path/$folder_name"
    echo -e "  VM: /home/vagrant/code/"
}

# Main execution
main() {
    echo -e "${BLUE}=== Vagrant DevOps Environment Setup ===${NC}\n"
    
    # Initialize log file
    echo "=== Vagrant Setup Log - $(date) ===" > "$LOG_FILE"
    
    check_prerequisites
    prompt_folder_name
    prompt_local_path
    create_and_copy_files
    update_vagrantfile
    prompt_installation
    start_vagrant
}

# Run main function
main "$@"