#!/bin/bash

# Run as root
if [ "$EUID" -ne 0 ]; then
  echo "This script must be run as root. Please use sudo or switch to the root user."
  exit 1
fi


# run solana_ore container
image="registry-intl.cn-hongkong.aliyuncs.com/apool-ore-node/solana-ore-node"

if ! docker network ls|grep ore-network > /dev/null;then
    docker network create ore-network
fi

if ! docker ps|grep solana-ore > /dev/null;then
    docker run --rm -d --name solana-ore --network ore-network \
	   -v /root/.config/solana/:/root/.config/solana/ \
	   $image:latest
else
    echo "docker container solana-ore is running"
fi

# Create new solana wallet
mkdir -p /root/.config/solana/ 
keypair="/root/.config/solana/oremine.json"

if [ ! -f $keypair ];then
    echo -e "\033[32;5m ↓↓↓ Important !\033[0m"
    docker exec -t -uroot solana-ore solana-keygen new --derivation-path m/44'/501'/0'/0' --force --word-count 12 -o $keypair --no-bip39-passphrase
    echo -e "\033[32;5m ↑↑↑ Important !\033[0m  -->  Remember to copy the $keypair and copy the mnemonic phrase !"
    echo -e "\033[32m Generating Solana wallet Successfully. \033[0m"
    echo "Please top up with at least 0.005 SOL ore-node to Run"
else
    echo -e "\033[31m solana wallet already exists --> $keypair \033[0m"
fi

# stop solana-ore container
docker stop solana-ore
