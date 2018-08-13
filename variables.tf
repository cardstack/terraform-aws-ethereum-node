variable "public_key" {
  description = "The public key to use to ssh into the EC2 instance in which geth runs."
}

variable "network" {
  description = "The Ethereum network to use, e.g. 'rinkeby', 'mainnet', etc."
  default = "rinkeby"
}

variable "availability_zone" {
  description = "The availablity zone in which the EC2 instance will run."
}

variable "volume_device_name" {
  description = "The volume device name for the EBS storage that is used by EC2."
  default = "/dev/xvdh"
}

variable "volume_size" {
  description = "The volume size for the EBS storage that is used by EC2 which holds the Ethereum blocks. At minimum this should be at least 1 GB, perferably larger."
  default = "2047"
}

variable "instance_type" {
  description = "The EC2 instance type to use for running geth. This instance type need to be compatible with iops EBS storage."
  default = "m4.xlarge"
}

