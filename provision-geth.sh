set -e

# add docker's own apt repository
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Basic packages and unattended security upgrades
echo unattended-upgrades unattended-upgrades/enable_auto_updates boolean true | debconf-set-selections
DEBIAN_FRONTEND=noninteractive apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y unattended-upgrades docker-ce unzip socat

# Take any security upgrades immediately
unattended-upgrade

# Latest AWS Tools (the version in apt is old)
curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
unzip awscli-bundle.zip
python3 ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws

# run geth from docker hub
GETH_DIR=/home/ubuntu/ethereum
if [ "$ETH_NETWORK" == "mainnet" ]; then
  ETH_NETWORK=""
fi

docker run -d --name ethereum-node --restart always -v ${GETH_DIR}:/root \
     -p 8545:8545 -p 8546:8546 -p 30303:30303 \
     ethereum/client-go:stable $ETH_NETWORK \
     --rpc --rpcapi eth,net,web3 --rpcaddr 0.0.0.0 \
     --ws --wsaddr 0.0.0.0 --wsorigins '*' --wsapi eth,net,web3 \
     --cache 4096

