
# <===========================   VPC   ===========================>
# Create VPC
resource "aws_vpc" "main_vpc" {
    cidr_block = var.main_vpc_cidr
    tags = {
        Name = "r-milestone-5-${var.environment}-vpc"
        Owner = "${var.owner}"
    }
}


# <=====================   SECURITY GROUPS   =====================>
# <----------------------  PUBLIC
# Create VPC Security Group for public instances
locals {
    # poate schimbat cu var.pub_in_rules apelat din environment.
    pub_in_rules = [
        { port = 22, protocol = "tcp", type = "ingress", 
        cidr_block = var.company_vpn, description = "ingress (ssh) company vpn to public subnet" },

        { port = 80, protocol = "tcp", type = "ingress", 
        cidr_block = var.company_vpn, description = "ingress (http) company vpn to public subnet" }
    ]

    pub_out_rules = [
        { port = 0, protocol = "-1", type = "egress",
        cidr_block = ["0.0.0.0/0"], description = "egress (all) public subnet to wide web" }
    ]
}

resource "aws_security_group" "main_vpc_pub_sg" {
    description = "Security group for public subnet on ${var.environment} vpc"
    name = "r-milestone-5-${var.environment}-pub-sg"
    vpc_id = aws_vpc.main_vpc.id

    dynamic "ingress" {
        for_each = local.pub_in_rules
        content {
            from_port = ingress.value.port
            to_port = ingress.value.port
            protocol = ingress.value.protocol
            cidr_blocks = ingress.value.cidr_block
            description = ingress.value.description
        }
    }

    dynamic "egress" {
        for_each = local.pub_out_rules
        content {
            from_port = egress.value.port
            to_port = egress.value.port
            protocol = egress.value.protocol
            cidr_blocks = egress.value.cidr_block
            description = egress.value.description
        }
    }

    tags = {
        Name = "r-milestone-5-${var.environment}-pub-sg"
        Owner = "${var.owner}"
    }
}

# <----------------------  BASTION
# Create VPC security group for bastion instance
resource "aws_security_group" "bastion" {
    description = "Security group for bastion on ${var.environment} vpc"
    name = "r-milestone-5-${var.environment}-bastion-sg"
    vpc_id = aws_vpc.main_vpc.id
    tags = {
        Name = "r-milestone-5-${var.environment}-bastion-sg"
        Owner = "${var.owner}"
    }
} # OBS: Bastion host belongs to the public security group also

# <----------------------  ALB
# Create VPC security group for ALB nodes
resource "aws_security_group" "alb" {
    description = "Security group for ALB nodes on ${var.environment} vpc"
    name = "r-milestone-5-${var.environment}-alb-sg"
    vpc_id = aws_vpc.main_vpc.id
    tags = {
        Name = "r-milestone-5-${var.environment}-alb-sg"
        Owner = "${var.owner}"
    }
} # OBS: ALB nodes belong to the public security group also

# <----------------------  PRIVATE
# Create VPC Security Group for private instances
locals {
    prv_in_rules = [
        # used for bastion to connect via ssh
        { port = 22, protocol = "tcp", type = "ingress", cidr_blocks = null, self = null, 
        security_groups = [aws_security_group.bastion.id], 
        description = "ingress (ssh) bastion to private subnets" },

        { port = 8080, protocol = "tcp", type = "ingress", cidr_blocks = null, self = null,
        security_groups = [aws_security_group.alb.id, aws_security_group.bastion.id],
        description = "ingress (http, 8080) ALB and Bastion to private subnets" },

        # was as ingress from main_vpc_cidr before
        # in this form might not even be needed? (to be tested)
        { port = 3306, protocol = "tcp", type = "ingress", cidr_blocks = null, self = true,
        security_groups = null,
        description = "ingress (mysql, 3306) within private subnets" }
    ]

    prv_out_rules = [
        # used for access via NAT gateway
        { port = 0, protocol = "-1", type = "egress", cidr_blocks = ["0.0.0.0/0"], 
        self = null, security_groups = null,
        description = "egress (all) private subnets to wide web" }
    ]
}

resource "aws_security_group" "main_vpc_prv_sg" {
    description = "Security group for private subnets on ${var.environment} vpc"
    name = "r-milestone-5-${var.environment}-prv-sg"
    vpc_id = aws_vpc.main_vpc.id

    dynamic "ingress" {
        for_each = local.prv_in_rules
        content {
            from_port = ingress.value.port
            to_port = ingress.value.port
            protocol = ingress.value.protocol
            cidr_blocks = ingress.value.cidr_blocks  
            self = ingress.value.self
            security_groups = ingress.value.security_groups 
            description = ingress.value.description
        }
    }

    dynamic "egress" {
        for_each = local.prv_out_rules
        content {
            from_port = egress.value.port
            to_port = egress.value.port
            protocol = egress.value.protocol
            cidr_blocks = egress.value.cidr_blocks  
            self = egress.value.self
            security_groups = egress.value.security_groups
            description =egress.value.description
        }
    }

    tags = {
        Name = "r-milestone-5-${var.environment}-prv-sg"
        Owner = "${var.owner}"
    }
}


# <==========================   SUBNETS   ==========================>
# Create Public Subnets
resource "aws_subnet" "public_subnets" {
    count = length(toset(var.public_subnets)) #convert to set to avoid duplicates
    vpc_id = aws_vpc.main_vpc.id
    cidr_block = var.public_subnets[count.index]
    availability_zone = var.availability_zones[count.index]
    tags = {
        Name = "r-milestone-5-${var.environment}-pub-subnet-${count.index+1}"
        Owner = "${var.owner}"
    }
}

# Create Private Subnets
resource "aws_subnet" "private_subnets" {
    count = length(toset(var.private_subnets)) #convert to set to avoid duplicates
    vpc_id = aws_vpc.main_vpc.id
    cidr_block = var.private_subnets[count.index]
    availability_zone = var.availability_zones[count.index]
    tags = {
        Name = "r-milestone-5-${var.environment}-prv-subnet-${count.index+1}"
        Owner = "${var.owner}"
    }
}


# <======================   DB SUBNET GROUP   ======================>
# Create a db subnet group, needs at least 2 subnets in 2AZ's
resource "aws_db_subnet_group" "default" {
  name       = var.db_subnet_group_name
  subnet_ids = [for subnet in aws_subnet.private_subnets: subnet.id]

  tags = {
    Name = "r-milestone-5-${var.environment}-db-subnet-group"
  }
}


# <=========================   GATEWAYS   =========================>
# Create Internet Gateway attached to the VPC
resource "aws_internet_gateway" "IGW" {
    vpc_id = aws_vpc.main_vpc.id
    tags = {
        Name = "r-milestone-5-${var.environment}-igw"
        Owner = "${var.owner}"
    }
}

# Create an elastic ip for NAT Gateway
resource "aws_eip" "nat-eip" {
    vpc = true
    depends_on = [aws_internet_gateway.IGW]
    tags = {
        Name = "r-milestone-5-${var.environment}-nat-eip"
        Owner = "${var.owner}"
    }  
}

# Create NAT Gateway and place it in the public subnet
resource "aws_nat_gateway" "NAT" {
    allocation_id = aws_eip.nat-eip.id
    subnet_id = aws_subnet.public_subnets[0].id
    tags = {
        Name = "r-milestone-5-${var.environment}-nat-gw"
        Owner = "${var.owner}"
    }
    depends_on = [aws_internet_gateway.IGW]
}


# <======================   ROUTING TABLES   ======================>
# <----------------------   PUBLIC
# Create route table for public subnet
resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main_vpc.id
    tags = {
        Name = "r-milestone-5-${var.environment}-pub-rt"
        Owner = "${var.owner}"
    }
}

# Create route to internet gateway and associate it with public route table
resource "aws_route" "igw" {
    route_table_id = aws_route_table.public.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
}

# Create route table association of public route table with public subnets
resource "aws_route_table_association" "public" {
    count = length(toset(var.public_subnets))
    subnet_id = aws_subnet.public_subnets[count.index].id
    route_table_id = aws_route_table.public.id
}

# <----------------------  PRIVATE
# Create route table for private subnets
resource "aws_route_table" "private" {
    vpc_id = aws_vpc.main_vpc.id
    tags = {
        Name = "r-milestone-5-${var.environment}-prv-rt"
        Owner = "${var.owner}"
    }
}

# Create route to nat gateway and associate it with private route table
resource "aws_route" "nat" {
    route_table_id = aws_route_table.private.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.NAT.id
}

# Create route table association of private route table with private subnets
resource "aws_route_table_association" "private" {
    count = length(toset(var.private_subnets))
    subnet_id = aws_subnet.private_subnets[count.index].id
    route_table_id = aws_route_table.private.id
}


# OBS: a bastion allows inbound access to known IP addresses and authenticated users,
# a NAT gw allows instances within your VPC to go out to the internet.
# The NAT is located in the public subnet and uses the IGW to connect to the internet