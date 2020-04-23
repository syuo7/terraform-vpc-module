# variables.tf

variable "name" {
  description = "prefix for any resource name define on the module"
  type = string
  default = ""
}

variable "cidr" {
  description = "The CIDR block for VPC"
  type = string
}

variable "public_subnets" {
  description = "A list of public subnets inside the VPC"
  type = list(string)
  default = []
}
