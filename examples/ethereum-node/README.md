You can invoke this module like this:

``` sh
module "ethereum-node" {
  source  = "cardstack/ethereum-node/aws"
  version = "0.1.3"
  network = "rinkeby"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQ ..."
  availability_zone = "us-east-1b"
}
```

You can specify the Ethereum network to connect your node to e.g. `rinkeby`, `mainnet`, etc
