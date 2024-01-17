$script = <<-'SCRIPT'

	# install needed tools
	sudo apt-get update && sudo apt-get install -y --no-install-recommends tzdata unzip npm zsh git curl wget vim locales sudo gnupg software-properties-common \ 
		ca-certificates curl apt-transport-https lsb-release gnupg python3-pip python3-setuptools nodejs fonts-powerline \ 
		libssl-dev libffi-dev python-dev-is-python3 build-essential exa

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

SCRIPT

Vagrant.configure(2) do |config|
	if Vagrant.has_plugin?("vagrant-timezone")
    	config.timezone.value = "Europe/Stockholm"
  	end
	config.vm.box = "mathiasgutehall/ubuntu23-04"
	config.vm.box_version = "0.1"
	config.vm.synced_folder "~/Development/Nordcloud/Clients/", "/home/vagrant/", :owner => "vagrant" # Add client folder
	config.vm.box_check_update = false
	config.vm.provision "shell", inline: $script
	config.vm.provision "shell", inline: "sudo chsh -s /bin/zsh vagrant"
	config.vm.provision "shell", path: "install.sh"
	config.vm.provision "file", source: "../files/.zshrc", destination: "/home/vagrant/.zshrc"
	config.vm.provision "file", source: "../files/bullet-train.zsh-theme", destination: "/home/vagrant/.oh-my-zsh/themes/bullet-train.zsh-theme"
	config.vm.provision "file", source: "../files/.vimrc", destination: "/home/vagrant/.vimrc"
	config.vm.provision "file", source: "../files/zenburn.vim", destination: "/home/vagrant/.vim/colors/zenburn.vim"

	# Change to what you need below.
	
	# config.vm.provider "virtualbox" do |vb|
	# 	vb.memory = 2048
	#  	vb.cpus = 2
	# 	vb.name = "devbox"
	# 	vb.check_guest_additions = true
	# end
			
	config.vm.provider "parallels" do |prl|
		prl.memory = 2048
		prl.cpus = 2
		prl.name = "devbox"
		prl.update_guest_tools = true
		#prl.gui = true
	end

	# config.vm.provider "vmware_desktop" do |v|
	# 	v.memory = 2048
	#  	v.cpus = 2
	# 	v.name = "devbox"
	# 	v.check_guest_additions = true
	# end
	
	# config.vm.provider "qemu" do |qe|
	# 	qe.memory = 2048
	#  	qe.cpus = 2
	# 	qe.name = "devbox"
	# 	qe.check_guest_additions = true
	# end
end
