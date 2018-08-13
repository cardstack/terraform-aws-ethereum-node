You can invoke this module like this:

``` sh
module "geth" {
  network = "rinkeby"
  source = "cardstack/terraform-aws-ethereum-node/aws"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQ ..."
  availability_zone = "us-east-1b"
}
```

You can specify the Ethereum network to connect your node to e.g. `rinkeby`, `mainnet`, etc
