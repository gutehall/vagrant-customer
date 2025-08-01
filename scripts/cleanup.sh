#!/bin/bash
set -euo pipefail

# Configuration
LOG_FILE="/tmp/cleanup.log"
DRY_RUN=false

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

# Check for root privileges
check_root() {
    if [[ "$(id -u)" -ne 0 ]]; then
        error_exit "This script must be run as root."
    fi
}

# Clean package cache
clean_package_cache() {
    info "Cleaning package cache..."
    
    # Remove old kernel packages
    local current_kernel=$(uname -r)
    local package_list=$(dpkg --list | awk '{ print $2 }')
    
    # Remove old kernel headers and images
    echo "$package_list" | grep -E 'linux-(headers|image|modules|source)' | grep -v "$current_kernel" | while read -r package; do
        if [[ -n "$package" ]]; then
            info "Removing old kernel package: $package"
            apt-get -y purge "$package" || warning "Failed to remove $package"
        fi
    done
    
    # Remove development packages
    echo "$package_list" | grep -- '-dev\(:[a-z0-9]\+\)\?\|-doc$' | while read -r package; do
        if [[ -n "$package" ]]; then
            info "Removing development package: $package"
            apt-get -y purge "$package" || warning "Failed to remove $package"
        fi
    done
    
    # Clean apt cache
    apt-get -y autoremove --purge
    apt-get -y clean
    
    success "Package cache cleaned"
}

# Clean temporary files
clean_temp_files() {
    info "Cleaning temporary files..."
    
    # Clean common temp directories
    local temp_dirs=("/tmp" "/var/tmp" "/var/cache" "/var/log")
    
    for dir in "${temp_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            info "Cleaning $dir"
            find "$dir" -type f -delete 2>/dev/null || warning "Failed to clean some files in $dir"
        fi
    done
    
    # Remove specific temporary files
    local temp_files=(
        "/var/lib/systemd/random-seed"
        "/etc/machine-id"
        "/var/lib/dbus/machine-id"
        "/root/.wget-hsts"
    )
    
    for file in "${temp_files[@]}"; do
        if [[ -f "$file" ]]; then
            info "Removing $file"
            rm -f "$file" || warning "Failed to remove $file"
        fi
    done
    
    success "Temporary files cleaned"
}

# Clean documentation and firmware
clean_documentation() {
    info "Cleaning documentation and firmware..."
    
    # Remove documentation
    rm -rf /usr/share/doc/* 2>/dev/null || warning "Failed to remove some documentation"
    
    # Remove firmware (keep essential)
    find /lib/firmware -type f ! -name "*.fw" -delete 2>/dev/null || warning "Failed to remove some firmware files"
    
    success "Documentation and firmware cleaned"
}

# Clean shell history
clean_shell_history() {
    info "Cleaning shell history..."
    
    # Clear command history
    export HISTSIZE=0
    export HISTFILESIZE=0
    
    # Remove history files
    local history_files=(
        "/root/.bash_history"
        "/root/.zsh_history"
        "/home/vagrant/.bash_history"
        "/home/vagrant/.zsh_history"
    )
    
    for file in "${history_files[@]}"; do
        if [[ -f "$file" ]]; then
            info "Removing history file: $file"
            rm -f "$file" || warning "Failed to remove $file"
        fi
    done
    
    success "Shell history cleaned"
}

# Clean npm cache
clean_npm_cache() {
    info "Cleaning npm cache..."
    
    if command -v npm &> /dev/null; then
        npm cache clean --force 2>/dev/null || warning "Failed to clean npm cache"
    fi
    
    # Clean global node_modules
    if [[ -d "/usr/local/lib/node_modules" ]]; then
        chown -R vagrant: /usr/local/lib/node_modules 2>/dev/null || warning "Failed to fix node_modules ownership"
    fi
    
    success "npm cache cleaned"
}

# Clean Docker cache
clean_docker_cache() {
    info "Cleaning Docker cache..."
    
    if command -v docker &> /dev/null; then
        docker system prune -af 2>/dev/null || warning "Failed to clean Docker cache"
    fi
    
    success "Docker cache cleaned"
}

# Optimize system
optimize_system() {
    info "Optimizing system..."
    
    # Update package database
    apt-get update 2>/dev/null || warning "Failed to update package database"
    
    # Optimize filesystem
    if command -v fstrim &> /dev/null; then
        fstrim -v / 2>/dev/null || warning "Failed to trim filesystem"
    fi
    
    success "System optimized"
}

# Main cleanup function
main() {
    info "Starting system cleanup..."
    
    # Initialize log file
    echo "=== Cleanup Log - $(date) ===" > "$LOG_FILE"
    
    # Check root privileges
    check_root
    
    # Perform cleanup operations
    clean_package_cache
    clean_temp_files
    clean_documentation
    clean_shell_history
    clean_npm_cache
    clean_docker_cache
    optimize_system
    
    success "Cleanup completed successfully"
    
    # Show disk usage
    info "Disk usage after cleanup:"
    df -h / 2>/dev/null || warning "Failed to get disk usage"
}

# Run main function
main "$@"