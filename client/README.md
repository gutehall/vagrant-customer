## Commands

### Visual Studio Code

```
Host CLIENT_NAME
  HostName XXX.XXX.XXX.XXX
  User vagrant
  Port 22
  UserKnownHostsFile /dev/null
  StrictHostKeyChecking no
  PasswordAuthentication no
  IdentityFile /CHANGE_ME/CLIENT_NAME/.vagrant/machines/default/parallels/private_key
  IdentitiesOnly yes
  LogLevel FATAL
  PubkeyAcceptedKeyTypes +ssh-rsa
  HostKeyAlgorithms +ssh-rsa
```

### .zshrc

```
  vgu() { cd /CHANGE_ME/CLIENT_NAME && vagrant up }
  vgd() { cd /CHANGE_ME/CLIENT_NAME && vagrant halt }
  vgs() { cd /CHANGE_ME/CLIENT_NAME && vagrant ssh }
```