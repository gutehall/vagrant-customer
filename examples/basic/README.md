# Basic DevOps Environment Example

This is a basic example of how to use the Vagrant DevOps environment setup.

## Quick Start

1. **Setup the environment**:
   ```bash
   make setup CLIENT=myproject
   ```

2. **Start the environment**:
   ```bash
   ./manage.sh start myproject
   ```

3. **Connect to the environment**:
   ```bash
   ./manage.sh ssh myproject
   ```

## What's Included

This basic setup includes:
- **Shell Environment**: Oh-my-zsh with plugins and themes
- **Development Tools**: Git, Vim with Ultimate vimrc
- **DevOps Tools**: Selected during setup (Terraform, Docker, etc.)
- **File Sync**: Local directory synced to `/home/vagrant/code/`

## Customization

You can customize this environment by:
- Modifying the Vagrantfile
- Adding custom scripts to the install process
- Changing the base box or VM resources
- Adding additional tools to the installation

## Next Steps

- Check out the `examples/` directory for more advanced examples
- Read the main README.md for comprehensive documentation
- Explore the `docs/` directory for detailed guides 