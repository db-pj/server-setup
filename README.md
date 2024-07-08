## Digital Brands Server Setup Script Ubuntu 20.04

`# ssh root@[your_server_ip_address]`

### [Add User](https://www.digitalocean.com/community/tutorials/how-to-create-a-new-sudo-enabled-user-on-ubuntu)
```
# adduser [username]
# usermod -aG sudo [username]
```

Logout and log back in as `[username]`

Install any personal dotfiles, tools, etc.

### Install git
`$ apt install git`

### Clone & run setup script
```
$ git clone https://github.com/db-pj/server-setup
$ cd server-setup
$ ./server-setup-20-04.sh
```
