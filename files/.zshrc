export ZSH=/home/vagrant/.oh-my-zsh
PATH=/bin:/usr/bin:/usr/local/bin:${PATH}
export PATH

ZSH_THEME="bullet-train"

plugins=(
  git
  exa-zsh
  docker
  aws
  minikube
  colored-man-pages
  colorize
  terraform
  zsh-syntax-highlighting
  zsh-autosuggestions
  )

source ~/.oh-my-zsh/oh-my-zsh.sh
source ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

alias ls="exa --no-icons -lh"
alias docker="podman

# Terraform
alias tfi="terraform init"
alias tfp="terraform plan"
alias tff="terraform fmt"
alias tfa="terraform apply"
alias tfd="terraform destroy"
alias tfv="terraform validate"
alias tfc="terraform console"

# Git
alias gi="git init"
alias gs="git status -sbu"
alias gco="git checkout"
alias gcob="git checkout -b"
alias gp="git push"
alias gm="git merge"
alias ga="git add ."
alias gcm="git commit -m"
alias gpl="git pull"
alias gst="git stash"
alias gstl="git stash list"
alias glg='git log --graph --oneline --decorate --all'

BULLETTRAIN_PROMPT_ORDER=(
  time
  git
  dir
  status
)

precmd() {
  echo -ne "\e]1;${PWD##*/}\a"
}

# Create new Terraform
tf-new() {
    mkdir modules
    touch main.tf
    touch variables.tf
    touch output.tf
    touch version.tf
    echo -e "terraform {\nrequired_version = \">= 0.14\"\n}" > version.tf
    touch README.md
    touch .gitignore
    echo -e "*.tfstate\n*.tfstate.backup\n.terraform.tfstate.*\ntfplan\n.DS_Store\n*.hcl\n.terraform/" > .gitignore
}

tf-files() {
    touch main.tf
    touch variables.tf
    touch output.tf
}

autoload -Uz compinit && compinit -i