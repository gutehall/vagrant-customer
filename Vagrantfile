# Configuration variables
$TIMEZONE = "Europe/Stockholm"
$BASE_BOX = "gutehall/debian-12"
$VM_MEMORY = 2048
$VM_CPUS = 2
$VM_NAME = "devbox"

# Shell setup script
$shell_setup_script = <<-'SCRIPT'
set -euo pipefail

USER="sudo -u vagrant"
LOG_FILE="/tmp/vagrant_setup.log"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Error handling
error_exit() {
    log "ERROR: $1"
    exit 1
}

log "Starting shell environment setup..."

# Ultimate vimrc
log "Installing Ultimate vimrc..."
$USER git clone --depth=1 https://github.com/amix/vimrc.git /home/vagrant/.vim_runtime || error_exit "Failed to clone vimrc"
$USER sh /home/vagrant/.vim_runtime/install_awesome_vimrc.sh || error_exit "Failed to install vimrc"

# Oh-my-zsh
log "Installing Oh-my-zsh..."
$USER sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || error_exit "Failed to install Oh-my-zsh"

# Zsh plugins
log "Installing zsh plugins..."
$USER git clone https://github.com/zsh-users/zsh-autosuggestions /home/vagrant/.oh-my-zsh/custom/plugins/zsh-autosuggestions || error_exit "Failed to clone zsh-autosuggestions"
$USER git clone https://github.com/zsh-users/zsh-syntax-highlighting.git /home/vagrant/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting || error_exit "Failed to clone zsh-syntax-highlighting"
$USER git clone https://github.com/z-shell/zsh-eza.git /home/vagrant/.oh-my-zsh/custom/plugins/zsh-eza || error_exit "Failed to clone zsh-eza"

# Vim theme
log "Installing vim theme..."
$USER mkdir -p /home/vagrant/.vim/colors/
$USER curl -sSL https://raw.githubusercontent.com/jnurmine/Zenburn/master/colors/zenburn.vim >/home/vagrant/.vim/colors/zenburn.vim || error_exit "Failed to download vim theme"

log "Shell environment setup completed successfully"
SCRIPT

Vagrant.configure(2) do |config|
    # Timezone configuration
    if Vagrant.has_plugin?("vagrant-timezone")
        config.timezone.value = $TIMEZONE
    end
    
    # VM configuration
    config.vm.box = $BASE_BOX
    config.vm.box_check_update = false
    config.vm.hostname = $VM_NAME
    
    # Create code directory
    config.vm.provision "shell", inline: "mkdir -p /home/vagrant/code"
    
    # Shell environment setup
    config.vm.provision "shell", inline: $shell_setup_script
    
    # Change default shell to zsh
    config.vm.provision "shell", inline: "sudo chsh -s /bin/zsh vagrant"
    
    # Install DevOps tools
    config.vm.provision "shell", path: "install.sh"
    
    # Copy configuration files
    config.vm.provision "file", source: "../../source/.zshrc", destination: "/home/vagrant/.zshrc"
    config.vm.provision "file", source: "../../source/.vimrc", destination: "/home/vagrant/.vimrc"
    config.vm.provision "file", source: "../../source/bullet-train.zsh-theme", destination: "/home/vagrant/.oh-my-zsh/themes/bullet-train.zsh-theme"
    
    # Cleanup
    config.vm.provision "shell", path: "../../scripts/cleanup.sh"

    # Provider configurations
    config.vm.provider "parallels" do |prl|
        prl.memory = $VM_MEMORY
        prl.cpus = $VM_CPUS
        prl.name = $VM_NAME
        prl.update_guest_tools = true
    end

    config.vm.provider "virtualbox" do |vb|
        vb.memory = $VM_MEMORY
        vb.cpus = $VM_CPUS
        vb.name = $VM_NAME
        vb.gui = false
        vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    end

    config.vm.provider "vmware_desktop" do |v|
        v.memory = $VM_MEMORY
        v.cpus = $VM_CPUS
        v.name = $VM_NAME
    end

    config.vm.provider "hyperv" do |h|
        h.memory = $VM_MEMORY
        h.cpus = $VM_CPUS
        h.name = $VM_NAME
    end
end
