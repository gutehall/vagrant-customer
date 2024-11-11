#!/bin/bash

# Function to prompt for input and validate folder name
prompt_folder_name() {
    while true; do
        read -p "Enter the name for the new client: " folder_name
        if [[ "$folder_name" =~ ^[[:alnum:]]+$ ]]; then
            break
        else
            echo "Error: Folder name can only contain letters and numbers."
        fi
    done
}

# Function to prompt for input and validate local path
prompt_local_path() {
    while true; do
        read -p "Enter the path where you want to sync locally: " local_path
        if [ -d "$local_path" ]; then
            break
        else
            echo "Error: The specified path does not exist."
        fi
    done
}

# Function to create folders and copy files
create_and_copy_files() {
    if mkdir -p "client/$folder_name" && sudo -u mathias mkdir -p "$local_path/$folder_name"; then
        echo "Folders 'client/$folder_name' and '$local_path/$folder_name' created successfully."
        for file in "Vagrantfile" "scripts/install.sh"; do
            if [ -e "$file" ]; then
                cp "$file" "client/$folder_name/$(basename "$file")"
                echo "File '$(basename "$file")' copied successfully."
            else
                echo "Error: File '$file' does not exist. Skipping..."
            fi
        done
    else
        echo "Error: Failed to create folders."
        exit 1
    fi
}

# Function to update Vagrantfile
update_vagrantfile() {
    local pattern='config.vm.box_check_update = false'
    sed "/$pattern/a\\
config.vm.synced_folder \"$local_path/$folder_name\", \"/home/vagrant/code/\", :owner => \"vagrant\"
" Vagrantfile >temp_Vagrantfile && mv temp_Vagrantfile Vagrantfile
}

# Function to prompt for installation choices
prompt_installation() {
    local choices=()
    local choice
    local options=(
        "GitHub CLI" "AWS CLI v2" "Azure CLI" "Bicep" "Gcloud CLI" "Minikube" "Kubectl" "Helm" "Kind" "Kustomize"
        "Open Policy Agent" "Terraform" "Packer" "Ansible" "Docker & Docker Compose" "Colima" "Terrascan" "Terrahub"
        "Terraform Docs" "Trivy" "Infracost" "Tfswitch" "Tflint" "Terratag" "AWS CDK" "Shfmt" "Serverless" "Podman & Podman Compose"
    )

    while true; do
        echo "Which applications would you like to install? (Enter the numbers separated by spaces)"
        echo "0. Select All"
        for i in "${!options[@]}"; do
            echo "$((i + 1)). ${options[$i]}"
        done
        echo "29. Exit"

        read -p "Enter your choices (space-separated): " choices_input

        if [[ $choices_input == "0" ]]; then
            choices=("${options[@]}")
        else
            for choice in $choices_input; do
                if ((choice >= 1 && choice <= ${#options[@]})); then
                    choices+=("${options[$((choice - 1))]}")
                elif [[ $choice == "29" ]]; then
                    break 2
                else
                    echo "Invalid choice: $choice. Please enter valid numbers from the menu."
                fi
            done
        fi

        read -p "Are you done selecting applications? (yes/no): " done_input
        if [[ $done_input == "yes" ]]; then
            break
        fi
    done

    local install_script="client/$folder_name/install.sh"
    for choice in "${choices[@]}"; do
        echo "install_${choice// /_}" >> "$install_script"
    done
}

# Main script execution
prompt_folder_name
prompt_local_path
create_and_copy_files
cd "client/$folder_name" || exit
update_vagrantfile
prompt_installation

# Set correct permissions
sudo chown -R vagrant: /usr/local/lib/node_modules

# Run vagrant up and build the machine
echo "Running vagrant up"
vagrant up

echo "Running vagrant ssh-config"
vagrant ssh-config