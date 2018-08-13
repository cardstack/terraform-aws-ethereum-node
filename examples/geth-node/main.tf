provider "aws" {
  region     = "us-east-1"
  version = "~> 1.8"
}

output "geth HTTP URL" {
  value = "${module.geth.http_url}"
}

output "geth WS URL" {
  value = "${module.geth.ws_url}"
}

module "geth" {
  network = "rinkeby"
  source = "../.."
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCzwehKw3FeO1QSFv03IncDDHVyssl+S/xpcELRy5u86mZEsD5ShmzqoHKLVQTYG+G66DTghkRCqDBUO+TNjmzvtfWbUWFEaNrzyPdj5t86CjvIYa/LKhwPe9bhiGlq6kabqhFSTxrZ+/UDf/LPKyMzJmxanBcPydnERQTpVhgpPGWS7MTU3l0GgmSYKUui1eo0gL05l64OxU04alq7cQffRaqDs6SEfzEXsT/BI2PilmiCTaEvlG1J53DNNDOaP+YiKja0NYTenYSSE8BDDdKHOxLWEX1uF6nGrna2n14HwtLBsnDpvPNdhLbEfQG+iktabTOK4E+DXj2Qw/Wh1dmMX76ldvXMChH5F9H1kvzqJakKaOBKNoJEkhZDgWRN2yikJVBexzxsJgNKNkrm4aaj2WmusE5CJ7/SHd6AwH1JEDTZr1c4TKZllJCo+Ndhfg+rOk/yGHpRSIoqaPE8Ll8W+ooRET1dX0O7Dz7ySXO5zGtBbiTDUM1zyhy2EdUFTYXbn68geY7xUFvXs2O65t10Bdnkn6cMKNt9E3I5djK/vBMswuUn6ok5V1BkEZIXJaGXHue2gyZSiyWrqFq7CS+64ooIZ4t4nIcix9j7gSqYcjqWJxiBgzIi4E7wyhmHjXjH84n52kT0oyKN+J3dlri9/Wz7yBE1D7PxV+xVU3c9/Q== hassan@NY0243JFFT0"
  availability_zone = "us-east-1b"
}
