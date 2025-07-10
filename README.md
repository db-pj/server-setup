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
$ sudo usermod -a -G docker [username]
$ sudo usermod -a -G www-data [username]
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

DN_HOME_DIR=/home/sites/datingnews
IS_PRODUCTION=true
DOMAIN_DEV="www.datingnews.com"
```

## Auto Load aliases
```
$ cd /etc/profile.d && sudo ln -s /home/sites/datingnews/site-aliases.sh site-aliases.sh
```

## Run Permissions Script
```
$ tasks && ./permissions-set.sh
```

## node_modules
```
$ cd volumes/phpfpm/gulp && npm install
```

## Build Containers
```
$ docker-compose build
```

## Certs (unproxy on Cloudflare first)
```
$ sudo certbot certonly
(choose option 2)

$ tasks && ./cert-combine.sh
```

## Import DB
```
$ tasks && ./site-start.sh --nodebug
$ tasks && ./database-monsoon.sh

Example monsson.cfg:
username='root'
siteurl='https://pj.passprotect.me'
database='datingnews'
bucketname='datingnews-01'
```

## Restart the site
```
$ tasks && ./site-start.sh --nodebug
```

## Install Warmer
```
$ home && git clone https://github.com/digital-brands/warmer
$ cd warmer/ && npm install
```
## Enable UFW
```
$ sudo ufw enable
$ sudo ufw allow 22 && sudo ufw allow 80 && sudo ufw allow 443 && sudo ufw allow 443 && sudo ufw allow mosh && sudo ufw status
```

## DNS (ONLY FOR TURNING SERVER INTO PRODUCTION)
Steps:
### 1. Pre-DNS Switch: Use Cloudflare DNS challenge to obtain cert
	1. Go to https://dash.cloudflare.com/profile/api-tokens
  	2. Click "Create Token"
  	3. Use "Custom token" template
  	4. Set these permissions:
    	- Zone : Zone:Read
    	- Zone : DNS:Edit
  	5. Zone Resources: Include - Specific zone - hostingadvice.com
  	6. Click "Continue to summary" → "Create Token"
  	7. Save the token - you'll only see it once
    8. `sudo vim /root/cloudflare.ini`
    9. `dns_cloudflare_api_token = YOUR_API_TOKEN_HERE`
    10. `sudo chmod 600 /root/cloudflare.ini && sudo chown root:root /root/cloudflare.ini`
    11. `sudo apt update && sudo apt install python3-certbot-dns-cloudflare`

### 2. Dry Run 
   `sudo certbot certonly --dns-cloudflare --dns-cloudflare-credentials /root/cloudflare.ini --dns-cloudflare-propagation-seconds 60 -d hostingadvice.com -d www.hostingadvice.com --dry-run`
   
### 3. Certificate Generation:
	If dry-run succeeds, run the actual certificate generation:
	
 	`sudo certbot certonly --dns-cloudflare --dns-cloudflare-credentials /root/cloudflare.ini --dns-cloudflare-propagation-seconds 60 -d hostingadvice.com -d www.hostingadvice.com`

   Verify: `sudo ls -la /etc/letsencrypt/live`

### 4. Set Environment Variables
     `sudo vim /etc/environment`
   
     `DOMAIN_PRODUCTION=hostingadvice.com`
   
     `IS_PRODUCTION=true`

### 5. Log out. Log back in.

### 6. Certificate Combination: 
   Run `tasks/cert-combine.sh` to create HAProxy-compatible cert

   Verify: `ls -la volumes/haproxy/certs`

### 7. You can switch back to dev mode until ready to do the DNS switch 

`IS_PRODUCTION=false`

### 8.  When you're ready to switch DNS:

  - Set production environment:
  
  `export IS_PRODUCTION=true`

  `export DOMAIN_PRODUCTION=hostingadvice.com`
  
- Start production services:
  `./tasks/site-start.sh`
  
- Build assets:
  `./tasks/site-build.sh`
  
- Warm cache:
  `./tasks/warmer-run.sh`
  
Update DNS in Cloudflare to point to new server
  
Monitor - The certificate will be ready and working immediately

