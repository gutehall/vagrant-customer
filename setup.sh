#!/bin/bash

USR="sudo -u vagrant"
UPDATE="sudo apt-get update"
INSTALL="sudo apt-get -y install"

# Install various utilities
install_utilities() {
    $USR bash <<EOF
    # Ultimate vimrc
    git clone --depth=1 https://github.com/amix/vimrc.git /home/vagrant/.vim_runtime
    sh /home/vagrant/.vim_runtime/install_awesome_vimrc.sh

    # Oh-my-zsh
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

    # Plugins
    git clone https://github.com/zsh-users/zsh-autosuggestions /home/vagrant/.oh-my-zsh/custom/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git /home/vagrant/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
    git clone https://github.com/renovate-bot/z-shell-_-zsh-eza.git /home/vagrant/.oh-my-zsh/custom/plugins/zsh-eza

    # Themes
    mkdir -p /home/vagrant/.vim/colors/
    curl -sSL https://github.com/jnurmine/Zenburn/raw/master/colors/zenburn.vim -o /home/vagrant/.vim/colors/zenburn.vim
EOF
}

# Prompt the user for the folder name
echo "Enter the name for the new client: "
read folder_name

# Validate folder name - check if it contains only alphanumeric characters
if [[ ! "$folder_name" =~ ^[[:alnum:]]+$ ]]; then
    echo "Error: Folder name can only contain letters and numbers."
    exit 1
fi

# Create the client folder locally
echo "Enter the path where you want to sync locally: "
read local_path

# Validate local path - check if it exists
if [ ! -d "$local_path" ]; then
    echo "Error: The specified path does not exist."
    exit 1
fi

# Create the new folder
if mkdir -p "client/$folder_name" && sudo -u "$USER" mkdir -p "$local_path/$folder_name"; then
    echo "Folders 'client/$folder_name' and '$local_path/$folder_name' created successfully."

    # Copy files into the new folder
    source_files=("Vagrantfile" "scripts/install.sh")

    for file in "${source_files[@]}"; do
        if [ -e "$file" ]; then
            cp "$file" "client/$folder_name/$(basename "$file")"
            echo "File '$file' copied successfully."
        else
            echo "Error: File '$file' does not exist. Skipping..."
        fi
    done
else
    echo "Error: Failed to create folders."
    exit 1
fi

# Move to the new folder
cd "client/$folder_name" || exit 1

# Add client folder into the Vagrantfile
pattern='config.vm.box_check_update = false'
sed "/$pattern/a\\
config.vm.synced_folder \"$local_path/$folder_name\", \"/home/vagrant/code/\", :owner => \"vagrant\"
" Vagrantfile >temp_Vagrantfile && mv temp_Vagrantfile Vagrantfile

# Update Vagrantfile based on the environment
update_vagrantfile() {
    local env_command="$1"
    local pattern="$2"
    local append_text="$3"

    if [ "$($env_command --version)" ]; then
        sed "/$pattern/a\\
    $append_text
    " Vagrantfile >temp_Vagrantfile && mv temp_Vagrantfile Vagrantfile
    fi
}

update_vagrantfile "VBoxManage" 'config.vm.provider "virtualbox" do |vb|' 'vb.name = "'$folder_name'"'
update_vagrantfile "prlctl" 'prl.cpus = 2' 'prl.name = "'$folder_name'"'
update_vagrantfile "vmrun" 'vm.cpu = 2' 'vm.name = "'$folder_name'"'

# Prompt the user for installation choices and echo into install.sh
install_applications() {
    declare -A options=(
        [0]="install_gh_cli install_aws_cli install_azure_cli install_bicep install_gcloud_cli install_minikube install_kubectl install_helm install_kind install_kustomize install_opa install_terraform install_packer install_ansible install_podman install_colima install_terrascan install_terrahub install_terraform_docs install_trivy install_infracost install_tfswitch install_tflint install_terratag"
        [1]="install_gh_cli"
        [2]="install_aws_cli"
        [3]="install_azure_cli"
        [4]="install_bicep"
        [5]="install_gcloud_cli"
        [6]="install_minikube"
        [7]="install_kubectl"
        [8]="install_helm"
        [9]="install_kind"
        [10]="install_kustomize"
        [11]="install_opa"
        [12]="install_terraform"
        [13]="install_packer"
        [14]="install_ansible"
        [15]="install_podman"
        [16]="install_colima"
        [17]="install_terrascan"
        [18]="install_terrahub"
        [19]="install_terraform_docs"
        [20]="install_trivy"
        [21]="install_infracost"
        [22]="install_tfswitch"
        [23]="install_tflint"
        [24]="install_terratag"
    )

    echo "Which applications would you like to install? (Enter the numbers separated by spaces)"
    echo "0. Select All"
    for i in "${!options[@]}"; do
        if [ "$i" -ne 0 ]; then
            echo "$i. ${options[$i]//install_/}"
        fi
    done
    echo "25. Exit"

    read -p "Enter your choices (space-separated): " choices_input

    if [[ $choices_input == "0" ]]; then
        choices=(${options[0]})
    else
        choices=()
        for choice in $choices_input; do
            if [ "$choice" -eq 25 ]; then
                break 2
            elif [[ -n "${options[$choice]}" ]]; then
                choices+=("${options[$choice]}")
            else
                echo "Invalid choice: $choice. Please enter valid numbers from the menu."
            fi
        done
    fi

    # Define the path to the install.sh file in the client folder
    install_script="install.sh"

    # Insert the choices before the main function in the install.sh file
    for function_name in "${choices[@]}"; do
        sed -i "/^main\$/a\\
$function_name
" "$install_script"
    done
}

# Install utilities and selected applications
install_utilities
install_eza
install_applications

# Run vagrant up and build the machine
echo "Running vagrant up"
vagrant up

# Run vagrant ssh-config and inserts it into ~/.ssh/config
vagrant_ssh_config=$(vagrant ssh-config)
host_name=$(echo "$vagrant_ssh_config" | grep -oP "HostName \K.*")
sed -i "s/Host Default/Host $host_name/" ~/.ssh/config

echo "Successfully updated ~/.ssh/config with Host $host_name"

rm install.sh
