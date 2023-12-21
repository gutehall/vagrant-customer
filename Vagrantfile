$script = <<-'SCRIPT'

	# install needed software
	sudo apt update && sudo apt upgrade -y && sudo apt -y install --no-install-recommends unzip python3-pip npm zsh git curl wget vim locales sudo gnupg software-properties-common ca-certificates curl apt-transport-https lsb-release gnupg python3-pip python3-setuptools nodejs powerline

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

	# ultimate vimrc
	sudo -u vagrant git clone --depth=1 https://github.com/amix/vimrc.git /home/vagrant/.vim_runtime
	sudo -u vagrant sh /home/vagrant/.vim_runtime/install_awesome_vimrc.sh

	# oh my zsh
	sudo -u vagrant sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

	# zsh plugin
	sudo -u vagrant git clone https://github.com/zsh-users/zsh-autosuggestions /home/vagrant/.oh-my-zsh/custom/plugins/zsh-autosuggestions
	sudo -u vagrant git clone https://github.com/zsh-users/zsh-syntax-highlighting.git /home/vagrant/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
	sudo -u vagrant git clone https://github.com/MohamedElashri/exa-zsh /home/vagrant/.oh-my-zsh/custom/plugins/exa-zsh

	# clean up
	apt-get clean && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*

SCRIPT

Vagrant.configure(2) do |config|
	config.vm.box = "mathiasgutehall/devbox"
  	config.vm.box_version = "0.2"
	config.vm.synced_folder "~/Development/Nordcloud/Clients/", "/home/vagrant/code", :owner => "vagrant"
	config.vm.box_check_update = false
  	config.vm.provision "shell", inline: "dpkg-reconfigure --frontend noninteractive tzdata"
	#config.vm.provision "shell", path: "../master.sh"
	config.vm.provision "shell", inline: $script
	config.vm.provision "shell", path: "install.sh"
	config.vm.provision "file", source: "../files/.zshrc", destination: "/home/vagrant/.zshrc"
	config.vm.provision "file", source: "../files/bullet-train.zsh-theme", destination: "/home/vagrant/.oh-my-zsh/themes/bullet-train.zsh-theme"
	config.vm.provision :shell, inline: "sudo chsh -s /bin/zsh vagrant"
	config.vm.provision "file", source: "../files/.vimrc", destination: "/home/vagrant/.vimrc"
	config.vm.provision "file", source: "../files/.vim/colors/", destination: "/home/vagrant/.vim/colors"

	# Remove comments if you need to override default settings for the box.
	
	# config.vm.provider "virtualbox" do |vb|
	# 	vb.memory = 2048
	#  	vb.cpus = 2
	# 	vb.name = "devbox"
	# 	vb.check_guest_additions = true
	# end
			
	# config.vm.provider "parallels" do |prl|
	# 	prl.memory = 2048
	# 	prl.cpus = 2
	# 	prl.name = "devbox"
	# 	prl.update_guest_tools = true
	# end

	# config.vm.provider "vmware_desktop" do |v|
	# 	v.memory = 2048
	#  	v.cpus = 2
	# 	v.name = "devbox"
	# 	v.check_guest_additions = true
	# end

	# config.vm.provider "qemu" do |qe|
	# 	qe.machine = "virt,accel=hvf,highmem=off"
	# 	qe.cpu = "cortex-a72"
	# 	qe.memory = 2048
	#   	qe.cpus = 2
	#  	qe.name = "devbox"
	# end
	
end
