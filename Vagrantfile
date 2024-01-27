$script = <<-'SCRIPT'

	# ultimate vimrc
	sudo -u vagrant git clone --depth=1 https://github.com/amix/vimrc.git /home/vagrant/.vim_runtime
	sudo -u vagrant sh /home/vagrant/.vim_runtime/install_awesome_vimrc.sh

	# oh-my-zsh
	sudo -u vagrant sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

	# zsh plugin
	sudo -u vagrant git clone https://github.com/zsh-users/zsh-autosuggestions /home/vagrant/.oh-my-zsh/custom/plugins/zsh-autosuggestions
	sudo -u vagrant git clone https://github.com/zsh-users/zsh-syntax-highlighting.git /home/vagrant/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
	sudo -u vagrant git clone https://github.com/MohamedElashri/exa-zsh /home/vagrant/.oh-my-zsh/custom/plugins/exa-zsh

	# themes
	sudo -u vagrant mkdir -p /home/vagrant/.vim/colors
	sudo -u vagrant curl -sSL https://github.com/jnurmine/Zenburn/blob/master/colors/zenburn.vim >/home/vagrant/.vim/colors/zenburn.vim
	sudo -u vagrant curl -sSL https://github.com/caiogondim/bullet-train.zsh/blob/master/bullet-train.zsh-theme >/home/vagrant/.oh-my-zsh/themes/bullet-train.zsh-theme

SCRIPT

Vagrant.configure(2) do |config|
	if Vagrant.has_plugin?("vagrant-timezone")
    	config.timezone.value = "Europe/Stockholm"
  	end
	# config.vm.box = "gutehall/ubuntu23-04"
	# config.vm.box_version = "2024.01.17"
	config.vm.box = "gutehall/debian-12"
	config.vm.box_version = "2024.01.21"
	config.vm.synced_folder "~/Development/Nordcloud/Clients/", "/home/vagrant/", :owner => "vagrant" # Add client folder
	config.vm.box_check_update = false
	config.vm.provision "shell", inline: $script
	config.vm.provision "shell", inline: "sudo chsh -s /bin/zsh vagrant"
	config.vm.provision "shell", path: "../scripts/install.sh"
	config.vm.provision "file", source: "../files/.zshrc", destination: "/home/vagrant/.zshrc"
	config.vm.provision "file", source: "../files/.vimrc", destination: "/home/vagrant/.vimrc"
	config.vm.provision "shell", path: "../scripts/cleanup.sh"

	config.vm.provider "parallels" do |prl|
		prl.memory = 2048
		prl.cpus = 2
		prl.name = "devbox"
		prl.update_guest_tools = true
	end
end
