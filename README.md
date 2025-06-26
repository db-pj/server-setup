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

## Create sites directory
```
$ sudo mkdir /home/sites/
$ sudo chown db-admin:db-admin /home/sites/
$ sudo chmod 2775 /home/sites/
$ sudo usermod -a -G db-admin [username]
```

Logout and log back in

## Clone site
```
$ cd /home/sites
$ git clone https://github.com/digital-brands/datingnews
$ sudo docker-compose build
```

## Env Vars
```
$ sudo vim /etc/environment

DN_HOME_DIR=/home/datingnews
IS_PRODUCTION=true
DOMAIN_DEV="www.datingnews.com"
```

## Auto Load aliases
```
$ sudo cd /etc/profile.d && ln -s /home/sites/datingnews/site-aliases.sh site-aliases.sh
```
