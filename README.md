## Vagrant DevOps Setup

This repository facilitates setting up a development environment for new clients using Vagrant. It avoids cluttering the local machine by provisioning a new box specifically tailored for the client's needs. The base box used is [Debian 12 arm64](https://app.vagrantup.com/gutehall/boxes/debian-12), featuring essential DevOps tools commonly utilized in such scenarios.

Tested on macOS Sonoma 14.3, Vagrant 2.4.1, and Parallels Desktop 19.

Before executing the script, ensure that `setup.sh` has executable permissions:

```bash
chmod +x setup.sh
```
And then just run

```bash
./setup.sh
```


### Installed Tools
The script installs the following tools, depending on your selection:

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

### Feedback and Contributions
Your feedback and contributions to enhance this setup are greatly appreciated. Feel free to suggest improvements or additions.
