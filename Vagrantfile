$script = <<-'SCRIPT'

	# exa - temporary fix. change to normal when exa is updated to support 23.04
	wget -c http://old-releases.ubuntu.com/ubuntu/pool/universe/r/rust-exa/exa_0.10.1-2_arm64.deb
	sudo apt-get -y install ./exa_0.10.1-2_arm64.deb
	rm -rf exa_0.10.1-2_arm64.deb

	# lazygit
	LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
	curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
	tar xf lazygit.tar.gz lazygit
	sudo install lazygit /usr/local/bin
	rm -rf lazygit*

	# ultimate vimrc
	sudo -u vagrant git clone --depth=1 https://github.com/amix/vimrc.git /home/vagrant/.vim_runtime
	sudo -u vagrant sh /home/vagrant/.vim_runtime/install_awesome_vimrc.sh

	# oh-my-zsh
	sudo -u vagrant sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

	# zsh plugin
	sudo -u vagrant git clone https://github.com/zsh-users/zsh-autosuggestions /home/vagrant/.oh-my-zsh/custom/plugins/zsh-autosuggestions
	sudo -u vagrant git clone https://github.com/zsh-users/zsh-syntax-highlighting.git /home/vagrant/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
	sudo -u vagrant git clone https://github.com/MohamedElashri/exa-zsh /home/vagrant/.oh-my-zsh/custom/plugins/exa-zsh

	# clean up
	apt-get clean && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*

SCRIPT

Vagrant.configure(2) do |config|
	config.vm.box = "mathiasgutehall/ubuntubase"
  	config.vm.box_version = "0.2"
	config.vm.synced_folder "~/Development/Nordcloud/Clients/", "/home/vagrant/code", :owner => "vagrant" # Add client folder
	config.vm.box_check_update = false
  	config.vm.provision "shell", inline: "dpkg-reconfigure --frontend noninteractive tzdata"
	config.vm.provision "shell", inline: $script
	#config.vm.provision "shell", inline: "mkdir /home/vagrant/.vim/colors/"
	config.vm.provision "shell", inline: "sudo chsh -s /bin/zsh vagrant"
	config.vm.provision "shell", path: "install.sh"
	config.vm.provision "file", source: "../files/.zshrc", destination: "/home/vagrant/.zshrc"
	config.vm.provision "file", source: "../files/bullet-train.zsh-theme", destination: "/home/vagrant/.oh-my-zsh/themes/bullet-train.zsh-theme"
	config.vm.provision "file", source: "../files/.vimrc", destination: "/home/vagrant/.vimrc"
	config.vm.provision "file", source: "../files/zenburn.vim", destination: "/home/vagrant/.vim/colors/zenburn.vim"

	config.vm.provider "parallels" do |prl|
		prl.memory = 2048
	 	prl.cpus = 2
		prl.name = "devbox"
		prl.update_guest_tools = true
	end
end
