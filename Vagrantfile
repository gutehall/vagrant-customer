Vagrant.configure(2) do |config|
	if Vagrant.has_plugin?("vagrant-timezone")
    	config.timezone.value = "Europe/Stockholm"
  	end
	
	config.vm.box = "gutehall/debian12"
	# config.vm.box = "gutehall/ubuntu24-04"
  	# config.vm.box_version = "2024.04.27"
	config.vm.box_check_update = false

	config.vm.provision "shell", inline: "mkdir -p /home/vagrant/code"
	config.vm.provision "shell", inline: "sudo chsh -s /bin/zsh vagrant"
	config.vm.provision "shell", path: "install.sh"
	config.vm.provision "shell", path: "../../scripts/cleanup.sh"

	config.vm.provision "file", source: "../../source/.zshrc", destination: "/home/vagrant/.zshrc"
	config.vm.provision "file", source: "../../source/.vimrc", destination: "/home/vagrant/.vimrc"
	config.vm.provision "file", source: "../../source/bullet-train.zsh-theme", destination: "/home/vagrant/.oh-my-zsh/themes/bullet-train.zsh-theme"

	config.vm.provider "parallels" do |prl|
		prl.memory = 2048
		prl.cpus = 2
		prl.update_guest_tools = true
	end

    config.vm.provider "virtualbox" do |vb|
        vb.memory = 2048
        vb.cpus = 2
    end

	config.vm.provider "vmware_desktop" do |v|
        v.memory = 2048
        v.cpus = 2
    end
end
