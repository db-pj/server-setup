#!/bin/bash

DOCKER_VERSION='1.29.2'
DEFAULT_PASS='d1g1t@l!'

# USERS
#*****************************************************************************
USERS=('db-admin' 'rfrankel' 'pj' 'roberto')
GROUPS=('sudo' 'www-data' 'db-admin' 'docker')

# TOOLS
#*****************************************************************************
TOOLS=(
	# Required Dev Tools
	'git'
	'mosh'
	'curl'
	'vim'
	'build-essential'
	'npm'
	'certbot'
	'python3-certbot-dns-cloudflare'

	# Required for Docker
	'apt-transport-https'
	'ca-certificates'
	'gnupg'
	'lsb-release'

	# Helpful Tools but not critical
	'dtrx'
	'ncdu'
	'tig'
	'htop'
	'trash-cli'
	'tmux'
	'zsh'
	'silversearcher-ag'
	'finger'
	'bat'
)

# Tools that may be pre-installed that we'd like to remove
#*****************************************************************************
REMOVE_TOOLS=(
	'snapd'
	'apache'
	'mysql'
)

#*****************************************************************************
#*****************************************************************************

printf "Setup Success!\n"
exit;

# Install Tools
#*****************************************************************************
#sudo apt-get update
for TOOL in "${TOOLS[@]}"; do
	printf "sudo apt install ${TOOL} -y\n"
done

# Remove some tools that may be pre-installed
#*****************************************************************************
for TOOL in "${REMOVE_TOOLS[@]}"; do
	sudo systemctl mask ${TOOL}.service
done


# Install Docker
#*****************************************************************************
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
"deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io


# Install Docker Compose
#*****************************************************************************
sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose


# Add Users and assign Groups
#*****************************************************************************
for USER in "${USERS[@]}"; do
	sudo useradd -m $USER

	# Add users to groups
	for GROUP in "${GROUPS[@]}"; do
		sudo usermod -a -G $GROUP $USER
	done
done
