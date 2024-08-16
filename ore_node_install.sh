#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "This script must be run as root. Please use sudo or switch to the root user."
  exit 1
fi

UBUNTU_VERSION=$(lsb_release -rs)

# Check if it is Ubuntu 22.04
if [ "$UBUNTU_VERSION" == "22.04" ]; then
    echo "Detected Ubuntu 22.04. Proceeding with download and installation of libssl1.1."

    # download libssl1.1 
    wget http://nz2.archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2.23_amd64.deb -O /tmp/libssl1.1_1.1.1f-1ubuntu2.23_amd64.deb

    # install .deb 
    sudo dpkg -i /tmp/libssl1.1_1.1.1f-1ubuntu2.23_amd64.deb
    sudo apt-get install -f -y

    echo "libssl1.1 has been successfully installed."
else
    echo "Ubuntu version: $UBUNTU_VERSION"
fi

app="ore-node"
github_api="https://api.github.com/repos/apool-io/ore-node/releases/latest"
latest_package_url=$(curl -s $github_api| grep "browser_download_url"| grep "$app*.tar.gz"| cut -d '"' -f 4)
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
    

source /root/.profile
source /root/.bashrc
mkdir -p /root/.config/solana/ 
keypair="/root/.config/solana/oremine.json"

if [ ! -f $keypair ];then
    solana-keygen new --word-count 12 -o $keypair
    echo -e "\033[32;5m ↑↑↑ Important !\033[0m  -->  Remember to copy the $keypair and copy the mnemonic phrase !"
else
    echo -e "\033[31m solana wallet already exists --> $keypair \033[0m"
fi


mkdir -p /opt/ore
if [ -f $package_name ];then
    tar xf $package_name -C /opt/ore
else
    echo "$package_name latest package Download Failed"
    exit 1
fi

cat > /opt/ore/.env << EOF
# Log level
LOG_VERBOSITY=3

# Log file
LOG_FILE=/var/log/ore-node.log

# RPC URL
JSON_RPC_URL=https://api.mainnet-beta.solana.com

# REST service port number
REST_PORT=3080

# Priority fee
PRIORITY_FEE=20000

# Filepath to keypair to use for mining.
MINING_KEYPAIR_FILEPATH=/root/.config/solana/oremine.json

# Filepath to keypair to use for fee payer.
PAYER_KEYPAIR_FILEPATH=/root/.config/solana/oremine.json
EOF

cat > /opt/ore/ore-node.service  << EOF
[Unit]
Description=ore-node
After=network.target
Wants=update-resolv-conf.service

[Service]
Type=simple
WorkingDirectory=/opt/ore/
ExecStart=/opt/ore/ore-node
ExecStop=/usr/bin/killall -9 ore-node
Restart=always

[Install]
WantedBy=multi-user.target
EOF


ln -sf /opt/ore/ore-node.service /etc/systemd/system/ore-node.service
systemctl daemon-reload
systemctl enable ore-node.service
systemctl start ore-node.service
