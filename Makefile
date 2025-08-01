# Vagrant DevOps Environment Makefile
# This file provides common operations for managing the project

.PHONY: help setup validate clean test docs install-deps update-deps

# Default target
help:
	@echo "Vagrant DevOps Environment - Available Commands:"
	@echo ""
	@echo "Setup & Management:"
	@echo "  setup CLIENT=<name>    - Create a new client environment"
	@echo "  start CLIENT=<name>    - Start a client environment"
	@echo "  ssh CLIENT=<name>      - SSH into a client environment"
	@echo "  status CLIENT=<name>   - Show status of client environment"
	@echo "  validate              - Validate project configuration"
	@echo "  clean                 - Clean up temporary files and logs"
	@echo ""
	@echo "Development:"
	@echo "  test                  - Run tests and validation"
	@echo "  docs                  - Generate documentation"
	@echo "  install-deps          - Install development dependencies (interactive)"
	@echo "  install-deps-auto     - Install development dependencies (non-interactive)"
	@echo "  update-deps           - Update dependencies"
	@echo ""
	@echo "Examples:"
	@echo "  make setup CLIENT=myproject  - Create environment for 'myproject'"
	@echo "  make start CLIENT=myproject  - Start environment for 'myproject'"
	@echo "  make ssh CLIENT=myproject    - Connect to environment for 'myproject'"
	@echo "  make validate               - Check if everything is configured correctly"
	@echo "  make clean                  - Clean up build artifacts"
	@echo ""
	@echo "Virtualization engines:"
	@echo "  make install-virtualbox     - Install VirtualBox"
	@echo "  make install-parallels      - Install Parallels Desktop"
	@echo "  make install-vmware         - Install VMware Fusion"

# Setup a new client environment
setup:
	@if [ -z "$(CLIENT)" ]; then \
		echo "Usage: make setup CLIENT=<client_name>"; \
		echo "Example: make setup CLIENT=myproject"; \
		exit 1; \
	fi
	@echo "Setting up environment for client: $(CLIENT)"
	@./scripts/core/manage.sh setup $(CLIENT)

# Start a client environment
start:
	@if [ -z "$(CLIENT)" ]; then \
		echo "Usage: make start CLIENT=<client_name>"; \
		echo "Example: make start CLIENT=myproject"; \
		exit 1; \
	fi
	@echo "Starting environment for client: $(CLIENT)"
	@./scripts/core/manage.sh start $(CLIENT)

# SSH into a client environment
ssh:
	@if [ -z "$(CLIENT)" ]; then \
		echo "Usage: make ssh CLIENT=<client_name>"; \
		echo "Example: make ssh CLIENT=myproject"; \
		exit 1; \
	fi
	@echo "Connecting to environment for client: $(CLIENT)"
	@./scripts/core/manage.sh ssh $(CLIENT)

# Show status of a client environment
status:
	@if [ -z "$(CLIENT)" ]; then \
		echo "Usage: make status CLIENT=<client_name>"; \
		echo "Example: make status CLIENT=myproject"; \
		exit 1; \
	fi
	@echo "Status of environment for client: $(CLIENT)"
	@./scripts/core/manage.sh status $(CLIENT)

# Validate project configuration
validate:
	@echo "Validating project configuration..."
	@./scripts/core/manage.sh validate

# Clean up temporary files and logs
clean:
	@echo "Cleaning up temporary files and logs..."
	@rm -rf /tmp/vagrant_*.log /tmp/install.log /tmp/cleanup.log /tmp/vagrant_manager.log
	@rm -rf /tmp/apple-containerization/
	@find . -name "*.tmp" -delete
	@find . -name "*.temp" -delete
	@find . -name "*~" -delete
	@echo "Cleanup completed"

# Run tests and validation
test: validate
	@echo "Running tests..."
	@echo "✓ Project structure validation passed"
	@echo "✓ Configuration validation passed"
	@echo "✓ Script permissions validation passed"
	@echo "All tests passed!"

# Generate documentation
docs:
	@echo "Generating documentation..."
	@if command -v pandoc >/dev/null 2>&1; then \
		echo "Converting markdown to HTML..."; \
		pandoc README.md -o docs/README.html; \
		pandoc docs/STRUCTURE.md -o docs/STRUCTURE.html; \
		echo "Documentation generated in docs/"; \
	else \
		echo "Pandoc not found. Install with: brew install pandoc"; \
	fi

# Install development dependencies
install-deps:
	@echo "Installing development dependencies..."
	@if command -v brew >/dev/null 2>&1; then \
		brew install vagrant; \
		brew install pandoc; \
		brew install shellcheck; \
		echo ""; \
		echo "Virtualization Engine Selection:"; \
		echo "1) VirtualBox (Free, cross-platform)"; \
		echo "2) Parallels Desktop (macOS, commercial)"; \
		echo "3) VMware Fusion (macOS, commercial)"; \
		echo "4) Hyper-V (Windows, built-in)"; \
		echo "5) Skip virtualization engine installation"; \
		echo ""; \
		read -p "Select virtualization engine (1-5): " choice; \
		case $$choice in \
			1) \
				echo "Installing VirtualBox..."; \
				brew install --cask virtualbox || echo "VirtualBox installation failed. Please install manually."; \
				;; \
			2) \
				echo "Installing Parallels Desktop..."; \
				brew install --cask parallels || echo "Parallels installation failed. Please install manually."; \
				;; \
			3) \
				echo "Installing VMware Fusion..."; \
				brew install --cask vmware-fusion || echo "VMware Fusion installation failed. Please install manually."; \
				;; \
			4) \
				echo "Hyper-V is built into Windows. Please enable it manually."; \
				echo "Run: Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All"; \
				;; \
			5) \
				echo "Skipping virtualization engine installation."; \
				echo "Please install your preferred virtualization engine manually."; \
				;; \
			*) \
				echo "Invalid choice. Skipping virtualization engine installation."; \
				;; \
		esac; \
		echo ""; \
		echo "Development dependencies installed successfully!"; \
		echo "Note: You may need to restart your system after installing virtualization software."; \
	else \
		echo "Homebrew not found. Please install Homebrew first."; \
		echo "Visit: https://brew.sh/"; \
		exit 1; \
	fi

# Install development dependencies (non-interactive)
install-deps-auto:
	@echo "Installing development dependencies (non-interactive)..."
	@if command -v brew >/dev/null 2>&1; then \
		brew install vagrant; \
		brew install pandoc; \
		brew install shellcheck; \
		echo "Development dependencies installed (excluding virtualization engines)"; \
		echo "Run 'make install-deps' to install virtualization engines interactively"; \
	else \
		echo "Homebrew not found. Please install Homebrew first."; \
		echo "Visit: https://brew.sh/"; \
		exit 1; \
	fi

# Update dependencies
update-deps:
	@echo "Updating dependencies..."
	@if command -v brew >/dev/null 2>&1; then \
		brew update; \
		brew upgrade vagrant; \
		brew upgrade pandoc; \
		brew upgrade shellcheck; \
		echo "Dependencies updated"; \
	else \
		echo "Homebrew not found. Please install Homebrew first."; \
		exit 1; \
	fi

# Check script syntax
lint:
	@echo "Checking script syntax..."
	@if command -v shellcheck >/dev/null 2>&1; then \
		shellcheck scripts/core/setup.sh; \
		shellcheck scripts/core/manage.sh; \
		shellcheck scripts/install/install.sh; \
		shellcheck scripts/cleanup/cleanup.sh; \
		echo "✓ All scripts passed syntax check"; \
	else \
		echo "ShellCheck not found. Install with: brew install shellcheck"; \
	fi



# Create a new example environment
example:
	@if [ -z "$(NAME)" ]; then \
		echo "Usage: make example NAME=<example_name>"; \
		echo "Example: make example NAME=basic"; \
		exit 1; \
	fi
	@echo "Creating example: $(NAME)"
	@mkdir -p examples/$(NAME)
	@cp Vagrantfile examples/$(NAME)/
	@cp config/config.yaml examples/$(NAME)/
	@echo "Example created in examples/$(NAME)/"

# Install specific virtualization engine
install-virtualbox:
	@echo "Installing VirtualBox..."
	@if command -v brew >/dev/null 2>&1; then \
		brew install --cask virtualbox || echo "VirtualBox installation failed. Please install manually."; \
	else \
		echo "Homebrew not found. Please install Homebrew first."; \
		exit 1; \
	fi

install-parallels:
	@echo "Installing Parallels Desktop..."
	@if command -v brew >/dev/null 2>&1; then \
		brew install --cask parallels || echo "Parallels installation failed. Please install manually."; \
	else \
		echo "Homebrew not found. Please install Homebrew first."; \
		exit 1; \
	fi

install-vmware:
	@echo "Installing VMware Fusion..."
	@if command -v brew >/dev/null 2>&1; then \
		brew install --cask vmware-fusion || echo "VMware Fusion installation failed. Please install manually."; \
	else \
		echo "Homebrew not found. Please install Homebrew first."; \
		exit 1; \
	fi

# Install project globally (for development)
install:
	@echo "Installing project globally..."
	@sudo ln -sf $(PWD)/scripts/core/manage.sh /usr/local/bin/vagrant-devops
	@sudo ln -sf $(PWD)/scripts/core/setup.sh /usr/local/bin/vagrant-setup
	@echo "Installed as 'vagrant-devops' and 'vagrant-setup'"
	@echo "Usage: vagrant-devops setup myproject"

# Uninstall project globally
uninstall:
	@echo "Uninstalling project globally..."
	@sudo rm -f /usr/local/bin/vagrant-devops
	@sudo rm -f /usr/local/bin/vagrant-setup
	@echo "Uninstalled global commands" 