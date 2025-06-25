#!/bin/bash

DOCKER_VERSION='1.29.2'
DEFAULT_PASS='d1g1t@l!'

# USERS
USERS=('db-admin' 'rfrankel' 'pj' 'roberto' 'jared')
GROUPS=('sudo' 'www-data' 'db-admin' 'docker')

# TOOLS
TOOLS=(
    # Required Dev Tools
    'git'
    'mosh'
    'curl'
    'vim'
    'build-essential'
    'npm'
    'certbot'
    'direnv'
    'python3-certbot-dns-cloudflare'

    # Required for Docker
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

REMOVE_TOOLS=(
    'snapd'
    'apache2'
    'mysql-server'
)

# Update system
sudo apt-get update && sudo apt-get upgrade -y

# Install Tools
for TOOL in "${TOOLS[@]}"; do
    sudo apt-get install ${TOOL} -y
done

# Remove undesired tools
for TOOL in "${REMOVE_TOOLS[@]}"; do
    sudo systemctl disable --now ${TOOL}.service 2>/dev/null || true
    sudo apt-get remove --purge -y ${TOOL} || true
done

# Remove snapd if present
sudo apt-get autoremove --purge -y snapd || true

# Install Docker
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
"deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Add Users and assign Groups
for USER in "${USERS[@]}"; do
    if ! id "$USER" &>/dev/null; then
        sudo useradd -m -s /bin/bash "$USER"
        echo "$USER:$DEFAULT_PASS" | sudo chpasswd
    fi

    for GROUP in "${GROUPS[@]}"; do
        sudo usermod -aG "$GROUP" "$USER"
    done
done

# Optional: Print Docker and Compose version to verify install
docker --version
docker-compose --version

