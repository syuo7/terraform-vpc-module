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

variable "private_subnets" {
    description = "A list of private subnets inside the VPC"
    type = list(string)
    default = []
}

variable "database_subnets" {
    description = "A list of database subnets"
    type = list(string)
    default = []
}

variable "azs" {
    description = "A list of availability zones names or ids in the region"
    type = list(string)
    default = []
}

variable "enable_dns_hostnames" {
    description = "Should be true to enable DNS hostnames in the VPC"
    type = bool
    default = true
}

variable "enable_dns_support" {
    description = "Should be true to enable DNS support in the VPC"
    type = bool
    default = true
}


variable "tags" {
    description = "A map of tags to add to all resources"
    type = map
    default = {}
}

  


