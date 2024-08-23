#!/bin/bash

# Run as root
if [ "$EUID" -ne 0 ]; then
  echo "This script must be run as root. Please use sudo or switch to the root user."
  exit 1
fi

# docker run ore-node
image="registry-intl.cn-hongkong.aliyuncs.com/apool-ore-node/solana-ore-node"

docker run --rm -d  --name ore-node \
           -v /opt/ore:/app/ore \
	   -v /var/log/ore-node:/var/log/ore-node \
	   -v /root/.config/solana/oremine.json:/root/.config/solana/oremine.json \
	   -p 3080:3080 \
           $image:latest ./ore-node
