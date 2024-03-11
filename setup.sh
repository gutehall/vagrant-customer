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
pattern='config.vm.box_check_update = false'
sed "/$pattern/a\\
config.vm.synced_folder \"$local_path/$folder_name\", \"/home/vagrant/code/\", :owner => \"vagrant\"
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
        echo "4. Bicep"
        echo "5. Gcloud CLI"
        echo "6. Minikube"
        echo "7. Kubectl"
        echo "8. Helm"
        echo "9. Kind"
        echo "10. Kustomize"
        echo "11. Open Policy Agent"
        echo "12. Terraform"
        echo "13. Packer"
        echo "14. Ansible"
        echo "15. Podman & Podman Compose"
        echo "16. Colima"
        echo "17. Terrascan"
        echo "18. Terrahub"
        echo "19. Terraform Docs"
        echo "20. Trivy"
        echo "21. Infracost"
        echo "22. Tfswitch"
        echo "23. Tflint"
        echo "24. Terratag"
        echo "25. Exit"

        read -p "Enter your choices (space-separated): " choices_input

        # If "Select All" is chosen, set choices to all available options
        if [[ $choices_input == "0" ]]; then
            choices=(install_gh_cli install_aws_cli install_azure_cli install_gcloud_cli install_minikube install_kubectl install_helm install_opa install_terraform install_packer install_ansible install_podman install_colima install_terrascan install_terrahub install_terraform_docs install_trivy install_infracost install_tfswitch install_tflint install_terratag install_kind install_kustomize)
        else
            # Split input by spaces and append selected choices to the array
            for choice in $choices_input; do
                case $choice in
                1) choices+=(install_gh_cli) ;;
                2) choices+=(install_aws_cli) ;;
                3) choices+=(install_azure_cli) ;;
                4) choices+=(install_bicep) ;;
                5) choices+=(install_gcloud_cli) ;;
                6) choices+=(install_minikube) ;;
                7) choices+=(install_kubectl) ;;
                8) choices+=(install_helm) ;;
                9) choices+=(install_kind) ;;
                10) choices+=(install_kustomize) ;;
                11) choices+=(install_opa) ;;
                12) choices+=(install_terraform) ;;
                13) choices+=(install_packer) ;;
                14) choices+=(install_ansible) ;;
                15) choices+=(install_podman) ;;
                16) choices+=(install_colima) ;;
                17) choices+=(install_terrascan) ;;
                18) choices+=(install_terrahub) ;;
                19) choices+=(install_terraform_docs) ;;
                20) choices+=(install_trivy) ;;
                21) choices+=(install_infracost) ;;
                22) choices+=(install_tfswitch) ;;
                23) choices+=(install_terratag) ;;
                24) choices+=(install_tflint) ;;
                25) break 2 ;;
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