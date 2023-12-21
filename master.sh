#!/bin/bash

USER="vagrant"

# exa - temporary fix. change to normal when exa is updated to support 23.04
ARCHITECTURE=$(dpkg --print-architecture)
wget -c http://old-releases.ubuntu.com/ubuntu/pool/universe/r/rust-exa/exa_0.10.1-2_$ARCHITECTURE.deb
sudo apt-get -y install ./exa_0.10.1-2_$ARCHITECTURE.deb
rm -rf exa_0.10.1-2_$ARCHITECTURE.deb

# lazygit
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit /usr/local/bin
rm -rf lazygit*

# clean up
apt-get clean && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*

# ultimate vimrc
sudo -u ${USER} git clone --depth=1 https://github.com/amix/vimrc.git /home/${USER}/.vim_runtime
sudo -u ${USER} sh /home/${USER}/.vim_runtime/install_awesome_vimrc.sh

# oh my zsh
sudo -u ${USER} sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# zsh plugin
sudo -u ${USER} git clone https://github.com/zsh-users/zsh-autosuggestions /home/${USER}/.oh-my-zsh/custom/plugins/zsh-autosuggestions
sudo -u ${USER} git clone https://github.com/zsh-users/zsh-syntax-highlighting.git /home/${USER}/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
sudo -u ${USER} git clone https://github.com/MohamedElashri/exa-zsh /home/${USER}/.oh-my-zsh/custom/plugins/exa-zsh

