#!/bin/bash

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
if mkdir "client/$folder_name" && sudo -u mathias mkdir "$local_path/$folder_name"; then
    echo "Folders 'client/$folder_name' and '$local_path/$folder_name' created successfully."

    # Copy files into the new folder
    source_files=("Vagrantfile" "scripts/install.sh")

    for file in "${source_files[@]}"; do
        if [ -e "$file" ]; then
            if [ "$file" == "scripts/install.sh" ]; then
                cp "$file" "client/$folder_name/install.sh"
                echo "File 'install.sh' copied successfully."
            else
                cp "$file" "client/$folder_name/$file"
                echo "File '$file' copied successfully."
            fi
        else
            echo "Error: File '$file' does not exist. Skipping..."
        fi
    done
else
    echo "Error: Failed to create folders."
    exit 1
fi

# Move to the new folder
cd "client/$folder_name"

# Add client folder into the Vagrantfile
new_line="config.vm.synced_folder \"~/Development/Nordcloud/Clients/$folder_name\", \"/home/vagrant/\", :owner => \"vagrant\""
pattern='config.vm.box_version = "2024.01.21"'
sed "\|$pattern|a\\
$new_line
" Vagrantfile >temp_Vagrantfile
mv temp_Vagrantfile Vagrantfile

# Add client name into the Vagrantfile
pattern='prl.cpus = 2'
sed "/$pattern/a\\
prl.name = \"$folder_name\"
" Vagrantfile >temp_Vagrantfile
mv temp_Vagrantfile Vagrantfile

# Function to prompt the user for installation choices and echo into install.sh
prompt_installation() {
    local choices=()
    local choice

    while true; do
        echo "Which applications would you like to install?"
        echo "   [ ] GitHub CLI"
        echo "   [ ] AWS CLI v2"
        echo "   [ ] Azure CLI"
        echo "   [ ] Gcloud CLI"
        echo "   [ ] Minikube"
        echo "   [ ] Kubectl"
        echo "   [ ] Helm"
        echo "   [ ] Kind"
        echo "   [ ] Kustomize"
        echo "   [ ] Open Policy Agent"
        echo "   [ ] Terraform"
        echo "   [ ] Packer"
        echo "   [ ] Ansible"
        echo "   [ ] Podman & Podman Compose"
        echo "   [ ] Colima"
        echo "   [ ] Terrascan"
        echo "   [ ] Terrahub"
        echo "   [ ] Terraform Docs"
        echo "   [ ] Tfsec"
        echo "   [ ] Infracost"
        echo "   [ ] Tfswitch"
        echo "   [ ] Tflint"
        echo "   [ ] AWS-CDK"
        echo "   [ ] Shfmt"
        echo "   [x] Exit"

        read -p "Enter your choices (space-separated): " choices_input

        # If "Exit" is chosen, break the loop
        if [[ $choices_input == *"Exit"* ]]; then
            break
        else
            # Split input by spaces and append selected choices to the array
            for choice in $choices_input; do
                case $choice in
                "GitHub") choices+=(install_gh_cli) ;;
                "AWS") choices+=(install_aws_cli) ;;
                "Azure") choices+=(install_azure_cli) ;;
                "Gcloud") choices+=(install_gcloud_cli) ;;
                "Minikube") choices+=(install_minikube) ;;
                "Kubectl") choices+=(install_kubectl) ;;
                "Helm") choices+=(install_helm) ;;
                "Kind") choices+=(install_kind) ;;
                "Kustomize") choices+=(install_kustomize) ;;
                "Open") choices+=(install_opa) ;;
                "Terraform") choices+=(install_terraform) ;;
                "Packer") choices+=(install_packer) ;;
                "Ansible") choices+=(install_ansible) ;;
                "Podman") choices+=(install_podman) ;;
                "Colima") choices+=(install_colima) ;;
                "Terrascan") choices+=(install_terrascan) ;;
                "Terrahub") choices+=(install_terrahub) ;;
                "Terraform") choices+=(install_terraform_docs) ;;
                "Tfsec") choices+=(install_tfsec) ;;
                "Infracost") choices+=(install_infracost) ;;
                "Tfswitch") choices+=(install_tfswitch) ;;
                "Tflint") choices+=(install_tflint) ;;
                "AWS-CDK") choices+=(install_aws_cdk) ;;
                "Shfmt") choices+=(install_shfmt) ;;
                *) echo "Invalid choice: $choice. Please enter valid options from the menu." ;;
                esac
            done
        fi

        read -p "Are you done selecting applications? (yes/no): " done_input
        if [[ $done_input == "yes" ]]; then
            break
        fi
    done

    # Define the path to the install.sh file in the client folder
    install_script="install.sh"

    # Insert the choices before the main function in the install.sh file
    for function_name in "${choices[@]}"; do
        escaped_function_name=$(echo "$function_name" | sed 's/[\/&]/\\&/g')
        temp_file=$(mktemp)
        sed "/^main\$/a\\
$escaped_function_name
" "$install_script" >"$temp_file" && mv "$temp_file" "$install_script"
    done
}

# Call the function to prompt the user for installation choices and echo into install.sh
prompt_installation

# Run vagrant up and build the machine
echo "Running vagrant up"
vagrant up
