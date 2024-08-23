#!/bin/bash

# Run as root
if [ "$EUID" -ne 0 ]; then
  echo "This script must be run as root. Please use sudo or switch to the root user."
  exit 1
fi

# ore-node work dir
app="ore-node"
github_api="https://api.github.com/repos/apool-io/ore-node/releases/latest"
latest_package_url=$(curl -s $github_api| grep "browser_download_url"| grep "$app"| cut -d '"' -f 4|grep $app$)
package_name=$(echo $latest_package_url|awk -F/ '{print $NF}')
if [ -n $package_name ];then
    if [ -f $package_name ];then
       rm $package_name
       echo "Download $app latest package..."
       wget $latest_package_url
    else
      echo "Download $app latest package..."
      wget $latest_package_url
    fi
else
    echo "$app latest package Not Found..."
    exit 1;
fi

mkdir -p /opt/ore
if [ -f $package_name ];then
    mv $app /opt/ore
    chmod +x /opt/ore/$app
else
    echo "$package_name latest package Download Failed"
    exit 1
fi

# ore-node config
cat > /opt/ore/.env << EOF
# Log level
LOG_VERBOSITY=3

# Log file
LOG_FILE=/var/log/ore-node/ore-node.log

# RPC URL
JSON_RPC_URL=https://api.mainnet-beta.solana.com

# REST service port number
REST_PORT=3080

# Pool difficulty
POOL_DIFFICULTY=20

# Network difficulty
NETWORK_DIFFICULTY=20

# Priority fee
PRIORITY_FEE=20000

# Filepath to keypair to use for mining.
MINING_KEYPAIR_FILEPATH=/root/.config/solana/oremine.json

# Filepath to keypair to use for fee payer.
PAYER_KEYPAIR_FILEPATH=/root/.config/solana/oremine.json
EOF
