
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
# Create VPC Security Group for public subnet
resource "aws_security_group" "main_vpc_pub_sg" {
    description = "Security group for public subnet on ${var.environment} vpc"
    name = "r-milestone-5-${var.environment}-pub-sg"
    vpc_id = aws_vpc.main_vpc.id
    tags = {
        Name = "r-milestone-5-${var.environment}-pub-sg"
        Owner = "${var.owner}"
    }
}

# Create security group rule to allow ingress ssh only from company network to our pub subnet
resource "aws_security_group_rule" "ingress_company_vpn_ssh_pub"{
    description = "Ingress company network, ssh protocol, to public subnet"
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = var.company_vpn
    security_group_id = aws_security_group.main_vpc_pub_sg.id
} # !! OBS: To check if needed if only using SSM !!

# Create security group rule to allow ingress http from company network to our pub subnet
# To be used by App Load Balancer
resource "aws_security_group_rule" "ingress_company_vpn_http_pub"{
    description = "Ingress company network, http protocol, to public subnets"
    type = "ingress"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = var.company_vpn
    security_group_id = aws_security_group.main_vpc_pub_sg.id
}

# Create security group rule to allow ingress http (8080) from company network to our pub subnet
resource "aws_security_group_rule" "ingress_company_vpn_http_2_pub"{
    description = "Ingress company network, http protocol, to public subnets"
    type = "ingress"
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = var.company_vpn
    security_group_id = aws_security_group.main_vpc_pub_sg.id
} 

# Create security group rule to allow all egress from pub subnet
resource "aws_security_group_rule" "egress_all_pub" {
    description = "Egress from public subnet to wide web, all protocols"
    type = "egress"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = aws_security_group.main_vpc_pub_sg.id
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

# <----------------------  PRIVATE
# Create VPC security group for private subnets
resource "aws_security_group" "main_vpc_prv_sg" {
    description = "Security group for private subnets on ${var.environment} vpc"
    name = "r-milestone-5-${var.environment}-prv-sg"
    vpc_id = aws_vpc.main_vpc.id
    tags = {
        Name = "r-milestone-5-${var.environment}-prv-sg"
        Owner = "${var.owner}"
    }
}

# Create security group rule to allow ssh ingress from bastion to private subnets
resource "aws_security_group_rule" "ingress_bastion_ssh_prv" {
    description = "Ingress from bastion, ssh protocol, to private subnets"
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    source_security_group_id = aws_security_group.bastion.id
    security_group_id = aws_security_group.main_vpc_prv_sg.id
} # OBS: must set up keys in order to use!

# Create security group rule to allow 8080 ingress from within vpc to private subnets
# for bastion port forwarding (webapp check) or Load Balancer check
resource "aws_security_group_rule" "ingress_vpc_8080_prv" {
    description = "Ingress from vpc, 8080 http protocol, to private subnets"
    type = "ingress"
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = [var.main_vpc_cidr]
    security_group_id = aws_security_group.main_vpc_prv_sg.id
}

# Create security group rule to mysql port ingress from vpc
resource "aws_security_group_rule" "ingress_vpc_mysql_prv" {
    description = "Ingress from vpc, mysql protocol, to private subnets"
    type = "ingress"
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = [var.main_vpc_cidr]
    security_group_id = aws_security_group.main_vpc_prv_sg.id
} # to change ingress just from 10.0.1.0/24 and 10.0.2.0/24 after bastion test

# Create security group rule to allow all egress from private subnets
resource "aws_security_group_rule" "egress_all_prv" {
    description = "Egrees from private subnets, all protocols, to wide web"
    type = "egress"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = aws_security_group.main_vpc_prv_sg.id
}


# <=========================   SUBNETS   =========================>
# Create Public Subnet 1
resource "aws_subnet" "public_subnet_1" {
    vpc_id = aws_vpc.main_vpc.id
    cidr_block = var.public_subnet_1_cidr
    availability_zone = "${var.region}a"
    tags = {
        Name = "r-milestone-5-${var.environment}-pub-subnet-1"
        Owner = "${var.owner}"
    }
}

# Create Public Subnet 2
resource "aws_subnet" "public_subnet_2" {
    vpc_id = aws_vpc.main_vpc.id
    cidr_block = var.public_subnet_2_cidr
    availability_zone = "${var.region}b"
    tags = {
        Name = "r-milestone-5-${var.environment}-pub-subnet-2"
        Owner = "${var.owner}"
    }
}

# Create Private Subnet 1
resource "aws_subnet" "private_subnet_1" {
    vpc_id = aws_vpc.main_vpc.id
    cidr_block = var.private_subnet_1_cidr
    availability_zone = "${var.region}a"
    tags = {
        Name = "r-milestone-5-${var.environment}-prv1-subnet"
        Owner = "${var.owner}"
    }    
}

# Create Private Subnet 2
resource "aws_subnet" "private_subnet_2" {
    vpc_id = aws_vpc.main_vpc.id
    cidr_block = var.private_subnet_2_cidr
    availability_zone = "${var.region}b"
    tags = {
        Name = "r-milestone-5-${var.environment}-prv2-subnet"
        Owner = "${var.owner}"
    }    
}

# <======================   DB SUBNET GROUP   ======================>
# Create a db subnet group, needs at least 2 subnets in 2AZ's
resource "aws_db_subnet_group" "default" {
  name       = var.db_subnet_group_name
  subnet_ids = [aws_subnet.private_subnet_2.id, aws_subnet.private_subnet_1.id]

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
    subnet_id = aws_subnet.public_subnet_1.id
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

# Create route table association of public route table with public subnet 1
resource "aws_route_table_association" "public_1" {
    subnet_id = aws_subnet.public_subnet_1.id
    route_table_id = aws_route_table.public.id
}

# Create route table association of public route table with public subnet 2
resource "aws_route_table_association" "public_2" {
    subnet_id = aws_subnet.public_subnet_2.id
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

# Create route table association of private route table with private subnet 1
resource "aws_route_table_association" "private_1" {
    subnet_id = aws_subnet.private_subnet_1.id
    route_table_id = aws_route_table.private.id
}

# Create route table association of private route table with private subnet 2
resource "aws_route_table_association" "private_2" {
    subnet_id = aws_subnet.private_subnet_2.id
    route_table_id = aws_route_table.private.id
}


# OBS: a bastion allows inbound access to known IP addresses and authenticated users,
# a NAT gw allows instances within your VPC to go out to the internet.
# The NAT is located in the public subnet and uses the IGW to connect to the internet