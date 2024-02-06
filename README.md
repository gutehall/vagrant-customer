## Vagrant DevOps
An Debain 12 arm64 box with the most common DevOps tools installed. Before building the box, make sure to run:

```
chmod +x setup.sh
```

### Tools Installed
The script installs the following tools:

* GitHub CLI
* AWS CLI v2
* Azure CLI
* Google Cloud CLI
* Minikube
* Kubectl
* Open Policy Agent
* Terraform
* Packer
* Ansible
* Podman
* Podman Compose
* Terrascan
* Terrahub
* Terraform Docs
* Tfsec
* Infracost

### Note
If installing Google Cloud CLI, comment out Minikube and Kubectl installation in the main function.

