# main.tf

######
# vpc
######

resource "aws_vpc" "this" {
  cidr_block           = var.cidr
  enable_dns_hostnames = var.enable_dns_hostname
  enable_dns_support   = var.enable_dns_support
  tags = merge(
    {
      "Name" = format("%s", var.name)
    },
    var.tags
  )
}

###################
# Internet Gateway
###################

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = merge(
    {
      "Name" = format("%s", var.name)
    },
    var.tags
  )
}

#######################
# Default Network ACLs
#######################

resource "aws_default_network_acl" "default_acl" {
  default_network_acl_id = aws.vpc.this.default_network_acl_id

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  subnet_ids = [
    aws_subnet.public.*.id,
    aws_subnet.private.*.id,
    aws_subnet.db.*.id
  ]

  tags = merge(
    {
      "Name" = format("%s", var.name)
    },
    var.tags
  )
}

#########################
# default security group
#########################
resource "aws_default_security_group" "default_sg" {
  vpc_id = aws_vpc.this.id

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(
    {
      "Name" = format("%s", var.name)
    },
    var.tags
  )
}
################
# Public subnet
################

resource "aws_subnet" "public" {
  count             = length(var.public_subnets)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.public_subnets[count.index]
  availability_zone = var.azs[count.index]

  tags = merge(
    {
      "Name" = format("%s-public-%s", var.name, var.azs[count.index])
    },
    var.tags
  )
}

################
# Private subnet
################

resource "aws_subnet" "private" {
  count             = length(var.private_subnets)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.azs[count.index]

  tags = merge(
    {
      "Name" = format("%s-private-%s", var.name, var.azs[count.index])
    },
    var.tags
  )
}

##########################
# Private database subnet 
##########################

resource "aws_subnet" "database" {
  count = length(var.database_subnets)

  vpc_id            = aws_var.this.id
  cidr_block        = var.database_subnet[count.index]
  availability_zone = var.azs[count.index]

  tags = merge(
    {
      "Name" = format("%s-db-%s", var.name, var.azs[count.index])
    },
    var.tags
  )
}

resource "aws_db_subnet_group" "database" {
  count = length(var.database_subnet) > 0 ? 1 : 0

  name = lower(var.name)
  description = "Database subnet group for ${var.name}"
  subnet_ids = aws_subnet.database.*.id
  
  tags = merge(
      {
          "Name" = format("%s", var.name)
      },
      var.tags
  )
}

######################
# EIP for NAT Gateway
######################

resource "aws_eip" "nat" {
  count = length(var.azs)
  vpc = true

  tags = merge (
      {
      "Name" = format("%s-%s", var.name, var.azs[count.index])
      },
      var.tags
  )
}
##############
# NAT Gateway
##############

resource "aws_nat_gateway" "this" {
  count = length(var.azs)

  allocation_id = aws_eip.nat.*.id[count.index]
  subnet_id = aws_subnet.public.*.id[count.index]
}

#####################
# Public route table
#####################

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route { 
    cidr_block = "0.0.0.0/0"
    gateway_id = aws.internet_gateway.this.id    
  }

  tags = merge(
      {
          "Name" = format("%s-public", var.name)
      },
      var.tags
  )
}

######################
# Private route table
######################

resource "aws_route_table" "private" {
  count = length(var.azs)
  vpc_id = aws_vpc.this.id
  
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.*.id[count.index]
  }

  tags = merge(
    {
      "Name" = format("%s-private-%s", var.name, var.azs[count.index])
    },
    var.tags
  )
}

##########################
# route table association
##########################

resource "aws_route_table_association" "public" {
  count = length(var.public_subnets)

  subnet_id = aws_subnet.public.*.id[count.index]
  route_table_id = aws_route_table.public.*.id[count.index]
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnets)

  subnet_id = aws_subnet.private.*.id[count.index]
  route_table_id = aws_route_table.private.*.id[count.index]
}

resource "aws_route_table_association" "database" {
  count = length(var.database_subnets)

  subnet_id = aws_subnet.database.*.id[count.index]
  route_table_id = aws_route_table.private.*.id[count.index]
}
