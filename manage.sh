#!/bin/bash

# Vagrant DevOps Environment Manager
# This script provides comprehensive management capabilities for the project

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/config.yaml"
LOG_FILE="/tmp/vagrant_manager.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
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

# Check prerequisites
check_prerequisites() {
    info "Checking prerequisites..."
    
    # Check if Vagrant is installed
    if ! command -v vagrant &> /dev/null; then
        error_exit "Vagrant is not installed. Please install Vagrant first."
    fi
    
    # Check if required files exist
    local required_files=("Vagrantfile" "setup.sh" "scripts/install.sh")
    for file in "${required_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            error_exit "Required file '$file' not found."
        fi
    done
    
    success "Prerequisites check passed"
}

# Show help
show_help() {
    cat << EOF
${BLUE}Vagrant DevOps Environment Manager${NC}

${CYAN}Usage:${NC} $0 [COMMAND] [OPTIONS]

${CYAN}Commands:${NC}
  ${GREEN}setup${NC} [client_name]     Create a new client environment
  ${GREEN}list${NC}                   List all client environments
  ${GREEN}start${NC} [client_name]    Start a client environment
  ${GREEN}stop${NC} [client_name]     Stop a client environment
  ${GREEN}destroy${NC} [client_name]  Destroy a client environment
  ${GREEN}ssh${NC} [client_name]      SSH into a client environment
  ${GREEN}status${NC} [client_name]   Show status of client environment
  ${GREEN}cleanup${NC} [client_name]  Clean up a client environment
  ${GREEN}update${NC}                 Update all client environments
  ${GREEN}backup${NC} [client_name]   Backup a client environment
  ${GREEN}restore${NC} [client_name]  Restore a client environment
  ${GREEN}logs${NC} [client_name]     Show logs for a client environment
  ${GREEN}config${NC}                 Show current configuration
  ${GREEN}validate${NC}               Validate project configuration
  ${GREEN}help${NC}                   Show this help message

${CYAN}Examples:${NC}
  $0 setup myclient
  $0 start myclient
  $0 ssh myclient
  $0 list
  $0 status myclient

${CYAN}Options:${NC}
  -v, --verbose    Enable verbose output
  -q, --quiet      Suppress output
  -f, --force      Force operation without confirmation
  -h, --help       Show this help message

EOF
}

# List all client environments
list_clients() {
    info "Listing client environments..."
    
    local client_dir="client"
    if [[ ! -d "$client_dir" ]]; then
        info "No client environments found."
        return 0
    fi
    
    echo -e "\n${BLUE}Client Environments:${NC}"
    echo -e "${CYAN}Name\t\tStatus\t\tProvider\t\tCreated${NC}"
    echo "----------------------------------------"
    
    for client in "$client_dir"/*; do
        if [[ -d "$client" ]]; then
            local client_name=$(basename "$client")
            local vagrantfile="$client/Vagrantfile"
            
            if [[ -f "$vagrantfile" ]]; then
                cd "$client" 2>/dev/null || continue
                
                # Get VM status
                local status=$(vagrant status --machine-readable 2>/dev/null | grep ",state," | cut -d',' -f4 || echo "unknown")
                
                # Get provider
                local provider=$(vagrant status --machine-readable 2>/dev/null | grep ",provider-name," | cut -d',' -f4 || echo "unknown")
                
                # Get creation date
                local created=$(stat -c %y "$vagrantfile" 2>/dev/null | cut -d' ' -f1 || echo "unknown")
                
                echo -e "${GREEN}$client_name\t\t$status\t\t$provider\t\t$created${NC}"
                
                cd - > /dev/null
            fi
        fi
    done
}

# Start a client environment
start_client() {
    local client_name="$1"
    
    if [[ -z "$client_name" ]]; then
        error_exit "Client name is required."
    fi
    
    local client_dir="client/$client_name"
    if [[ ! -d "$client_dir" ]]; then
        error_exit "Client environment '$client_name' not found."
    fi
    
    info "Starting client environment '$client_name'..."
    
    cd "$client_dir" || error_exit "Failed to change to client directory"
    
    if vagrant up; then
        success "Client environment '$client_name' started successfully"
    else
        error_exit "Failed to start client environment '$client_name'"
    fi
    
    cd - > /dev/null
}

# Stop a client environment
stop_client() {
    local client_name="$1"
    
    if [[ -z "$client_name" ]]; then
        error_exit "Client name is required."
    fi
    
    local client_dir="client/$client_name"
    if [[ ! -d "$client_dir" ]]; then
        error_exit "Client environment '$client_name' not found."
    fi
    
    info "Stopping client environment '$client_name'..."
    
    cd "$client_dir" || error_exit "Failed to change to client directory"
    
    if vagrant halt; then
        success "Client environment '$client_name' stopped successfully"
    else
        error_exit "Failed to stop client environment '$client_name'"
    fi
    
    cd - > /dev/null
}

# Destroy a client environment
destroy_client() {
    local client_name="$1"
    local force="$2"
    
    if [[ -z "$client_name" ]]; then
        error_exit "Client name is required."
    fi
    
    local client_dir="client/$client_name"
    if [[ ! -d "$client_dir" ]]; then
        error_exit "Client environment '$client_name' not found."
    fi
    
    if [[ "$force" != "true" ]]; then
        echo -e "${YELLOW}Warning: This will permanently destroy the client environment '$client_name'${NC}"
        read -p "Are you sure you want to continue? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            info "Operation cancelled"
            return 0
        fi
    fi
    
    info "Destroying client environment '$client_name'..."
    
    cd "$client_dir" || error_exit "Failed to change to client directory"
    
    if vagrant destroy -f; then
        success "Client environment '$client_name' destroyed successfully"
        
        # Remove client directory
        cd - > /dev/null
        if rm -rf "$client_dir"; then
            success "Client directory removed"
        else
            warning "Failed to remove client directory"
        fi
    else
        error_exit "Failed to destroy client environment '$client_name'"
    fi
}

# SSH into a client environment
ssh_client() {
    local client_name="$1"
    
    if [[ -z "$client_name" ]]; then
        error_exit "Client name is required."
    fi
    
    local client_dir="client/$client_name"
    if [[ ! -d "$client_dir" ]]; then
        error_exit "Client environment '$client_name' not found."
    fi
    
    info "Connecting to client environment '$client_name'..."
    
    cd "$client_dir" || error_exit "Failed to change to client directory"
    
    # Check if VM is running
    local status=$(vagrant status --machine-readable 2>/dev/null | grep ",state," | cut -d',' -f4)
    if [[ "$status" != "running" ]]; then
        warning "VM is not running. Starting it first..."
        vagrant up
    fi
    
    vagrant ssh
}

# Show status of a client environment
status_client() {
    local client_name="$1"
    
    if [[ -z "$client_name" ]]; then
        error_exit "Client name is required."
    fi
    
    local client_dir="client/$client_name"
    if [[ ! -d "$client_dir" ]]; then
        error_exit "Client environment '$client_name' not found."
    fi
    
    info "Status of client environment '$client_name':"
    
    cd "$client_dir" || error_exit "Failed to change to client directory"
    
    vagrant status
    
    cd - > /dev/null
}

# Clean up a client environment
cleanup_client() {
    local client_name="$1"
    
    if [[ -z "$client_name" ]]; then
        error_exit "Client name is required."
    fi
    
    local client_dir="client/$client_name"
    if [[ ! -d "$client_dir" ]]; then
        error_exit "Client environment '$client_name' not found."
    fi
    
    info "Cleaning up client environment '$client_name'..."
    
    cd "$client_dir" || error_exit "Failed to change to client directory"
    
    # Run cleanup script inside VM
    if vagrant ssh -c "sudo /vagrant/cleanup.sh"; then
        success "Client environment '$client_name' cleaned successfully"
    else
        error_exit "Failed to clean client environment '$client_name'"
    fi
    
    cd - > /dev/null
}

# Show logs for a client environment
show_logs() {
    local client_name="$1"
    
    if [[ -z "$client_name" ]]; then
        error_exit "Client name is required."
    fi
    
    local client_dir="client/$client_name"
    if [[ ! -d "$client_dir" ]]; then
        error_exit "Client environment '$client_name' not found."
    fi
    
    info "Logs for client environment '$client_name':"
    
    cd "$client_dir" || error_exit "Failed to change to client directory"
    
    # Show Vagrant logs
    vagrant ssh-config
    
    # Show recent log files
    echo -e "\n${BLUE}Recent log files:${NC}"
    find . -name "*.log" -type f -exec ls -la {} \; 2>/dev/null || echo "No log files found"
    
    cd - > /dev/null
}

# Validate project configuration
validate_config() {
    info "Validating project configuration..."
    
    # Check required files
    local required_files=("Vagrantfile" "setup.sh" "scripts/install.sh" "scripts/cleanup.sh")
    local missing_files=()
    
    for file in "${required_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            missing_files+=("$file")
        fi
    done
    
    if [[ ${#missing_files[@]} -gt 0 ]]; then
        error_exit "Missing required files: ${missing_files[*]}"
    fi
    
    # Check file permissions
    if [[ ! -x "setup.sh" ]]; then
        warning "setup.sh is not executable. Run: chmod +x setup.sh"
    fi
    
    # Check Vagrant installation
    if ! command -v vagrant &> /dev/null; then
        error_exit "Vagrant is not installed"
    fi
    
    success "Project configuration is valid"
}

# Main function
main() {
    local command="$1"
    shift
    
    # Initialize log file
    echo "=== Vagrant Manager Log - $(date) ===" > "$LOG_FILE"
    
    case "$command" in
        "setup")
            check_prerequisites
            ./setup.sh "$@"
            ;;
        "list")
            list_clients
            ;;
        "start")
            start_client "$1"
            ;;
        "stop")
            stop_client "$1"
            ;;
        "destroy")
            destroy_client "$1" "$2"
            ;;
        "ssh")
            ssh_client "$1"
            ;;
        "status")
            status_client "$1"
            ;;
        "cleanup")
            cleanup_client "$1"
            ;;
        "logs")
            show_logs "$1"
            ;;
        "validate")
            validate_config
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        "")
            show_help
            ;;
        *)
            error_exit "Unknown command: $command. Use 'help' for usage information."
            ;;
    esac
}

# Run main function
main "$@" 