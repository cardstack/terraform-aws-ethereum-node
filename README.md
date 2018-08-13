# terraform-aws-ethereum-node

A terraform module for running an Ethereum geth read-only node on AWS.

This terraform module will allow you to run an Ethereum geth read-only node in AWS so that you can introspect the Ethereum blockchain from your geth node. You can specify the Ethereum network to connect your node to e.g. `rinkeby`, `mainnet`, etc. The HTTP and Web Socket interfaces for geth will be enabled.

## Usage
This module's basic usage requires that you provide the Ethereum network to connect to, a public key to use for ssh'ing into the EC2 instance, and an availability zone to run the EC2 instance from. Note that the geth node does require inbound traffic from the internet, as it relies upon a peer-to-peer network for downloading blocks (the security group will be setup in the default VPC for the EC2 instance).

```
module "geth" {
  source  = "cardstack/ethereum-node/aws"
  version = "0.1.2"
  network = "rinkeby"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQ ..."
  availability_zone = "us-east-1b"
}
```

If you want to monitor the geth log file, you can ssh into the EC2 instance and execute:
```sh
  sudo docker logs -f ethereum-node
```
