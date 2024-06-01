Vagrant.configure("2") do |config|
	# Set timezone if the plugin is available
	if Vagrant.has_plugin?("vagrant-timezone")
	  config.timezone.value = "Europe/Stockholm"
	end
  
	# Base box configuration
	config.vm.box = "gutehall/debian12"
	# config.vm.box = "gutehall/ubuntu24-04"
  	# config.vm.box_version = "2024.04.27"
	config.vm.box_check_update = false
  
	# Provisions
	provision_scripts = [
	  { inline: "mkdir -p /home/vagrant/code" },
	  { inline: "sudo chsh -s /bin/zsh vagrant" },
	  { path: "install.sh" },
	  { path: "../../scripts/cleanup.sh" }
	]
  
	provision_scripts.each do |script|
	  config.vm.provision "shell", script
	end
  
	# File provisions
	files_to_provision = {
	  "../../source/.zshrc" => "/home/vagrant/.zshrc",
	  "../../source/.vimrc" => "/home/vagrant/.vimrc",
	  "../../source/bullet-train.zsh-theme" => "/home/vagrant/.oh-my-zsh/themes/bullet-train.zsh-theme"
	}
  
	files_to_provision.each do |source, destination|
	  config.vm.provision "file", source: source, destination: destination
	end
  
	# Provider configurations
	[ "parallels", "virtualbox", "vmware_desktop" ].each do |provider|
	  config.vm.provider provider do |p|
		p.memory = 2048
		p.cpus = 2
		p.update_guest_tools = true if provider == "parallels"
	  end
	end
  end
  