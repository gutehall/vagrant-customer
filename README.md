## Vagrant DevOps
This repo is for when I have a new customer and since I don't want to install too much on my laptop I use Vagrant and create a new box for the client. and this is based on a Debian 12 arm64 box with the most common DevOps tools installed. I'm running this om macos with Parallels so that's what it's been tested on. Before you run the script, make sure that setup.sh has got the right permissions:

```
chmod +x setup.sh
```

### Tools that you can install
The script installs the following tools depending on what you chose:

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

