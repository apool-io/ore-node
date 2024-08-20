#!/bin/bash

if [ "$EUID" -ne 0 ]; then 
  echo "This script must be run as root. Please use sudo or switch to the root user."
  exit 1
fi

apt-get update

apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

echo "Add Docker GPG prikey..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "Set Docker registe..."
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list

apt-get update -y

echo "Install Docker-ce"
apt-get install -y docker-ce docker-ce-cli containerd.io

echo "Start Docker..."
systemctl start docker
systemctl enable docker

