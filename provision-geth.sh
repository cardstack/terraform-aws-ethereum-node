set -e

mkfs -t ext4 /dev/nvme0n1
mkdir /data
mount /dev/nvme0n1 /data

# setup to ephermeral storage mount restart
cat >> /etc/fstab <<EOF
/dev/nvme0n1 /data ext4 defaults,nofail 0 2
EOF

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

# setup monitoring
apt-get update
apt-get install -y unzip
apt-get install -y libwww-perl libdatetime-perl
cd /home/ubuntu
curl https://aws-cloudwatch.s3.amazonaws.com/downloads/CloudWatchMonitoringScripts-1.2.2.zip -O
unzip CloudWatchMonitoringScripts-1.2.2.zip
rm CloudWatchMonitoringScripts-1.2.2.zip
cat > /etc/cron.d/aws-monitor <<EOF
* * * * * root /home/ubuntu/aws-scripts-mon/mon-put-instance-data.pl --mem-used-incl-cache-buff --mem-util --disk-space-util --disk-path=/data --from-cron
EOF

# run geth from docker hub
GETH_DIR=/data/ethereum
mkdir -p $GETH_DIR

docker run -d --name ethereum-node --restart always -v ${GETH_DIR}:/root \
     -p 8545:8545 -p 8546:8546 -p 30303:30303 \
     ethereum/client-go:stable $NETWORK_FLAG \
     --rpc --rpcapi personal,eth,net,web3 --rpcaddr 0.0.0.0 \
     --ws --wsaddr 0.0.0.0 --wsorigins '*' --wsapi personal,eth,net,web3 \
     --cache 4096 --allow-insecure-unlock

mkdir -p /data/ethereum/.ethereum/rinkeby/keystore/
echo $KEY_FILE > /data/ethereum/.ethereum/rinkeby/keystore/geth_key.json

