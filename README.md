## Vagrant DevOps Setup

This repository facilitates setting up a development environment for new clients using Vagrant. It avoids cluttering the local machine by provisioning a new box specifically tailored for the client's needs. The base box used is [Debian 12 arm64 or amd64](https://app.vagrantup.com/gutehall/boxes/debian-12), featuring essential DevOps tools commonly utilized in such scenarios. If you prefer to use Ubuntu then just change it in the [Vagrantfile](https://github.com/gutehall/vagrant-customer/blob/main/Vagrantfile). More boxes are available at [Vagrant Cloud](https://app.vagrantup.com/gutehall.)

Tested on macOS Sonoma using Parallels Desktop 19 and Vmware Fusion 13.5 and on Ubuntu 23.10 using Virtualbox 7 with Vagrant 2.4.1.

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
* Bicep
* Google Cloud CLI
* Minikube
* Kubectl
* Helm
* Kind
* Kustomize
* Open Policy Agent
* Terraform
* Packer
* Ansible
* Podman
* Podman Compose
* Colima
* Terrascan
* Terrahub
* Terraform Docs
* Tfsec
* Tfswitch
* Tflint
* Infracost

### Feedback and Contributions
Your feedback and contributions to enhance this setup are greatly appreciated. Feel free to suggest improvements or additions.
