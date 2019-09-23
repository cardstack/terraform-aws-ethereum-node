variable "public_key" {
  description = "The public key to use to ssh into the EC2 instance in which geth runs."
}

variable "network" {
  description = "The Ethereum network to use, e.g. 'rinkeby', 'mainnet', etc."
  default     = "rinkeby"
}

variable "availability_zone" {
  description = "The availablity zone in which the EC2 instance will run."
}

variable "instance_type" {
  description = "The EC2 instance type to use for running geth."
  default     = "i3.2xlarge"
}

variable "label" {
  description = "A label to use when naming this instance and associated resources in AWS"
}
