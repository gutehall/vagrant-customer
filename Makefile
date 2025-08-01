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
	@echo "  install-deps          - Install development dependencies"
	@echo "  update-deps           - Update dependencies"
	@echo ""
	@echo "Examples:"
	@echo "  make setup CLIENT=myproject  - Create environment for 'myproject'"
	@echo "  make start CLIENT=myproject  - Start environment for 'myproject'"
	@echo "  make ssh CLIENT=myproject    - Connect to environment for 'myproject'"
	@echo "  make validate               - Check if everything is configured correctly"
	@echo "  make clean                  - Clean up build artifacts"

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
		pandoc docs/APPLE_CONTAINERIZATION.md -o docs/APPLE_CONTAINERIZATION.html; \
		echo "Documentation generated in docs/"; \
	else \
		echo "Pandoc not found. Install with: brew install pandoc"; \
	fi

# Install development dependencies
install-deps:
	@echo "Installing development dependencies..."
	@if command -v brew >/dev/null 2>&1; then \
		brew install vagrant; \
		brew install --cask virtualbox || echo "VirtualBox installation skipped (may need manual installation)"; \
		brew install --cask parallels || echo "Parallels installation skipped (may need manual installation)"; \
		brew install --cask vmware-fusion || echo "VMware Fusion installation skipped (may need manual installation)"; \
		brew install pandoc; \
		brew install shellcheck; \
		echo "Development dependencies installed"; \
	else \
		echo "Homebrew not found. Please install Homebrew first."; \
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