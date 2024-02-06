#!/bin/bash

# Prompt the user for the folder name
echo "Enter the name for the new customer: "
read folder_name

# Create the customer folder locally
echo "Enter the path where you want to create the customer folder: "
read local_path

# Validate local path - check if it exists
if [ ! -d "$local_path" ]; then
    echo "Error: The specified path does not exist."
    exit 1
fi

# Create the new folder
if mkdir "customer/$folder_name" && mkdir "$local_path/$folder_name"; then
    echo "Folders 'customer/$folder_name' and '$local_path/$folder_name' created successfully."
else
    echo "Error: Failed to create folders."
    exit 1
fi

# Copy files into the new folder
echo "Copying files into '$folder_name'..."
cp Vagrantfile "customer/$folder_name/Vagrantfile"
cp scripts/install.sh "customer/$folder_name/install.sh"

echo "Files copied successfully. Moving into customer folder"

# Move to the new folder
cd "customer/$folder_name"

# Add customer folder into the Vagrantfile
new_line="config.vm.synced_folder \"~/Development/Nordcloud/Clients/$folder_name\", \"/home/vagrant/\", :owner => \"vagrant\""
pattern='config.vm.box_version = "2024.01.21"'
sed "\|$pattern|a\\
$new_line
" Vagrantfile >temp_Vagrantfile
mv temp_Vagrantfile Vagrantfile

# Add customer name into the Vagrantfile
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
        echo "1. GitHub CLI"
        echo "2. AWS CLI v2"
        echo "3. Azure CLI"
        echo "4. Gcloud CLI"
        echo "5. Minikube"
        echo "6. Kubectl"
        echo "7. Open Policy Agent"
        echo "8. Terraform"
        echo "9. Packer"
        echo "10. Ansible"
        echo "11. Podman"
        echo "12. Terrascan"
        echo "13. Terrahub"
        echo "14. Terraform Docs"
        echo "15. Tfsec"
        echo "16. Infracost"
        echo "17. Exit"

        read -p "Enter your choices (space-separated): " choices_input

        # Split input by spaces and append selected choices to the array
        for choice in $choices_input; do
            case $choice in
            1) choices+=(install_gh_cli) ;;
            2) choices+=(install_aws_cli) ;;
            3) choices+=(install_azure_cli) ;;
            4) choices+=(install_gcloud_cli) ;;
            5) choices+=(install_minikube) ;;
            6) choices+=(install_kubectl) ;;
            7) choices+=(install_opa) ;;
            8) choices+=(install_terraform) ;;
            9) choices+=(install_packer) ;;
            10) choices+=(install_ansible) ;;
            11) choices+=(install_podman) ;;
            12) choices+=(install_terrascan) ;;
            13) choices+=(install_terrahub) ;;
            14) choices+=(install_terraform_docs) ;;
            15) choices+=(install_tfsec) ;;
            16) choices+=(install_infracost) ;;
            17) break 2 ;;
            *) echo "Invalid choice: $choice. Please enter valid numbers from the menu." ;;
            esac
        done

        read -p "Are you done selecting applications? (yes/no): " done_input
        if [[ $done_input == "yes" ]]; then
            break
        fi
    done

    # Define the path to the install.sh file in the customer folder
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