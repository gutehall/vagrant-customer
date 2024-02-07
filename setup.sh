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
# new_line="config.vm.synced_folder \"~/Development/Nordcloud/Clients/$folder_name\", \"/home/vagrant/\", :owner => \"vagrant\""
pattern='config.vm.box_check_update = false'
# sed "\|$pattern|a\\
sed "/$pattern/a\\
config.vm.synced_folder \"~/Development/Nordcloud/Clients/$folder_name\", \"/home/vagrant/code/\", :owner => \"vagrant\"
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
        echo "Which applications would you like to install? (Enter the numbers separated by spaces)"
        echo "0. Select All"
        echo "1. GitHub CLI"
        echo "2. AWS CLI v2"
        echo "3. Azure CLI"
        echo "4. Gcloud CLI"
        echo "5. Minikube"
        echo "6. Kubectl"
        echo "7. Helm"
        echo "8. Kind"
        echo "9. Kustomize"
        echo "10. Open Policy Agent"
        echo "11. Terraform"
        echo "12. Packer"
        echo "13. Ansible"
        echo "14. Podman & Podman Compose"
        echo "15. Colima"
        echo "16. Terrascan"
        echo "17. Terrahub"
        echo "18. Terraform Docs"
        echo "19. Tfsec"
        echo "20. Infracost"
        echo "21. Tfswitch"
        echo "22. Tflint"
        echo "23. Exit"

        read -p "Enter your choices (space-separated): " choices_input

        # If "Select All" is chosen, set choices to all available options
        if [[ $choices_input == "0" ]]; then
            choices=(install_gh_cli install_aws_cli install_azure_cli install_gcloud_cli install_minikube install_kubectl install_helm install_opa install_terraform install_packer install_ansible install_podman install_colima install_terrascan install_terrahub install_terraform_docs install_tfsec install_infracost install_tfswitch install_tflint install_kind install_kustomize)
        else
            # Split input by spaces and append selected choices to the array
            for choice in $choices_input; do
                case $choice in
                1) choices+=(install_gh_cli) ;;
                2) choices+=(install_aws_cli) ;;
                3) choices+=(install_azure_cli) ;;
                4) choices+=(install_gcloud_cli) ;;
                5) choices+=(install_minikube) ;;
                6) choices+=(install_kubectl) ;;
                7) choices+=(install_helm) ;;
                8) choices+=(install_kind) ;;
                9) choices+=(install_kustomize) ;;
                10) choices+=(install_opa) ;;
                11) choices+=(install_terraform) ;;
                12) choices+=(install_packer) ;;
                13) choices+=(install_ansible) ;;
                14) choices+=(install_podman) ;;
                15) choices+=(install_colima) ;;
                16) choices+=(install_terrascan) ;;
                17) choices+=(install_terrahub) ;;
                18) choices+=(install_terraform_docs) ;;
                19) choices+=(install_tfsec) ;;
                20) choices+=(install_infracost) ;;
                21) choices+=(install_tfswitch) ;;
                22) choices+=(install_tflint) ;;
                23) break 2 ;;
                *) echo "Invalid choice: $choice. Please enter valid numbers from the menu." ;;
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
