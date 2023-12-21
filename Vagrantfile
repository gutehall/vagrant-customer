Vagrant.configure(2) do |config|
	config.vm.box = "mathiasgutehall/devbox"
  	config.vm.box_version = "0.2"
	config.vm.synced_folder "~/Development/", "/home/vagrant/code", :owner => "vagrant"
	config.vm.box_check_update = false
  	config.vm.provision "shell", inline: "dpkg-reconfigure --frontend noninteractive tzdata"
	config.vm.provision "shell", path: "../master.sh"
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
	
end
