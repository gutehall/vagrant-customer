$script = <<-'SCRIPT'

	USER="sudo -u vagrant"

	# Ultimate vimrc
	${USER} git clone --depth=1 https://github.com/amix/vimrc.git /home/vagrant/.vim_runtime
	${USER} sh /home/vagrant/.vim_runtime/install_awesome_vimrc.sh

	# Oh-my-zsh
	${USER} sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

	# Plugins
	${USER} git clone https://github.com/zsh-users/zsh-autosuggestions /home/vagrant/.oh-my-zsh/custom/plugins/zsh-autosuggestions
	${USER} git clone https://github.com/zsh-users/zsh-syntax-highlighting.git /home/vagrant/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
	${USER} git clone https://github.com/MohamedElashri/exa-zsh /home/vagrant/.oh-my-zsh/custom/plugins/exa-zsh

	# Themes
	${USER} mkdir -p /home/vagrant/.vim/colors/
	${USER} curl -sSL https://github.com/jnurmine/Zenburn/blob/master/colors/zenburn.vim >/home/vagrant/.vim/colors/zenburn.vim

SCRIPT

Vagrant.configure(2) do |config|
	if Vagrant.has_plugin?("vagrant-timezone")
    	config.timezone.value = "Europe/Stockholm"
  	end
	config.vm.box = "gutehall/debian-12"
	config.vm.box_check_update = false
	config.vm.provision "shell", inline: "mkdir -p /home/vagrant/code"
	config.vm.provision "shell", inline: $script
	config.vm.provision "shell", inline: "sudo chsh -s /bin/zsh vagrant"
	config.vm.provision "shell", path: "install.sh"
	config.vm.provision "file", source: "../../source/.zshrc", destination: "/home/vagrant/.zshrc"
	config.vm.provision "file", source: "../../source/.vimrc", destination: "/home/vagrant/.vimrc"
	config.vm.provision "file", source: "../../source/bullet-train.zsh-theme", destination: "/home/vagrant/.oh-my-zsh/themes/bullet-train.zsh-theme"
	config.vm.provision "shell", path: "../../scripts/cleanup.sh"

	config.vm.provider "parallels" do |prl|
		prl.memory = 2048
		prl.cpus = 2
		prl.update_guest_tools = true
	end
end