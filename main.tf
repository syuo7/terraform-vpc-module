# main.tf

######
# vpc
######

resource "aws_vpc" "this" {
    cidr_block = var.cidr
    enable_dns_hostnames = var.enable_dns_hostname
    enable_dns_support = var.enable_dns_support
    tags = merge(
        {
            "Name" = format("%s",var.name)
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
            "Name" = format("%s",var.name)
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
        protocol = -1
        rule_no = 100
        action = "allow"
        cidr_block = "0.0.0.0/0"
        from_port = 0
        to_port = 0
    }

    egress {
        protocol = -1
        rule_no = 100
        action = "allow"
        cidr_block = "0.0.0.0/0"
        from_port = 0
        to_port = 0
    }

    subnet_ids = [
        aws_subnet.public.*.id,
        aws_subnet.private.*.id,
        aws_subnet.db.*.id
    ]

    tags = merge(
        {
        "Name" = format("%s",var.name)
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
        protocol = -1
        self = true
        from_port = 0
        to_port = 0
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = merge(
        {
            "Name" = format("%s",var.name)
        },
        var.tags
    )
}
################
# Public subnet
################

resource "aws_subnet" "public" { 
    count = length(var.public_subnets)
    
  
}