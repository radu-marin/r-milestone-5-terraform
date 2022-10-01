# # !!!!!!!!! WIP !!!!!!!!!!!!! 
# # this file will be used just to practice with dynamic blocks, fors and conditionals

# <=========================   SUBNETS   =========================>
# dynamic blocks for subnets

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

# <=====================   SECURITY GROUPS   =====================>
# # <----------------------  PUBLIC
# # Create VPC Security Group for public instances
# locals {
#     pub_in_rules = [
#         { port = 22, protocol = "tcp", type = "ingress", 
#         cidr_block = var.company, description = "ingress (ssh) company vpn to public subnet" }

#         { port = 80, protocol = "tcp", type = "ingress", 
#         cidr_block = var.company, description = "ingress (http) company vpn to public subnet" }
#     ]

#     pub_out_rules = [
#         { port = 0, protocol = "-1", type = "egress",
#         cidr_block = ["0.0.0.0/0"], description = "egress (all) public subnet to wide web" }
#     ]
# }

# resource "aws_security_group" "main_vpc_pub_sg" {
#     description = "Security group for public subnet on ${var.environment} vpc"
#     name = "r-milestone-5-${var.environment}-pub-sg"
#     vpc_id = aws_vpc.main_vpc.id

#     dynamic "ingress" {
#         for_each = local.pub_in_rules
#         content {
#             from_port = ingress.value.port
#             to_port = ingress.value.port
#             protocol = ingress.value.protocol
#             cidr_blocks = ingress.value.cidr_block
#         }
#     }

#     dynamic "egress" {
#         for_each = local.pub_out_rules
#         content {
#             from_port = egress.value.port
#             to_port = egress.value.port
#             protocol = egress.value.protocol
#             cidr_blocks = egress.value.cidr_block
#         }
#     }

#     tags = {
#         Name = "r-milestone-5-${var.environment}-pub-sg"
#         Owner = "${var.owner}"
#     }
# }


# # <----------------------  BASTION
# # Create VPC security group for bastion instance
# resource "aws_security_group" "bastion" {
#     description = "Security group for bastion on ${var.environment} vpc"
#     name = "r-milestone-5-${var.environment}-bastion-sg"
#     vpc_id = aws_vpc.main_vpc.id
#     tags = {
#         Name = "r-milestone-5-${var.environment}-bastion-sg"
#         Owner = "${var.owner}"
#     }
# } # OBS: Bastion is also in the public security group


# # <----------------------  PRIVATE
# # Create VPC security group for private subnets
# resource "aws_security_group" "main_vpc_prv_sg" {
#     description = "Security group for private subnets on ${var.environment} vpc"
#     name = "r-milestone-5-${var.environment}-prv-sg"
#     vpc_id = aws_vpc.main_vpc.id
#     tags = {
#         Name = "r-milestone-5-${var.environment}-prv-sg"
#         Owner = "${var.owner}"
#     }
# }

# # Create security group rule to allow ssh ingress from bastion to private subnets
# resource "aws_security_group_rule" "ingress_bastion_ssh_prv" {
#     description = "Ingress from bastion, ssh protocol, to private subnets"
#     type = "ingress"
#     from_port = 22
#     to_port = 22
#     protocol = "tcp"
#     source_security_group_id = aws_security_group.bastion.id
#     security_group_id = aws_security_group.main_vpc_prv_sg.id
# } 

# # Create security group rule to allow 8080 ingress from within vpc to private subnets
# # for bastion port forwarding (webapp check) or Load Balancer check
# resource "aws_security_group_rule" "ingress_vpc_8080_prv" {
#     description = "Ingress from bastion, ssh protocol, to private subnets"
#     type = "ingress"
#     from_port = 8080
#     to_port = 8080
#     protocol = "tcp"
#     cidr_blocks = [var.main_vpc_cidr]
#     security_group_id = aws_security_group.main_vpc_prv_sg.id
# } # OBS: after Bastion check removed use: self = true ; instead of cidr_blocks
# # or from 10.0.1.0/24 and 10.0.2.0/24

# # Create security group rule to mysql port ingress from vpc
# resource "aws_security_group_rule" "ingress_vpc_mysql_prv" {
#     description = "Ingress from vpc, mysql protocol, to private subnets"
#     type = "ingress"
#     from_port = 3306
#     to_port = 3306
#     protocol = "tcp"
#     cidr_blocks = [var.main_vpc_cidr]
#     security_group_id = aws_security_group.main_vpc_prv_sg.id
# } # to change ingress just from 10.0.1.0/24 and 10.0.2.0/24 after bastion test

# # Create security group rule to allow all egress from private subnets
# resource "aws_security_group_rule" "egress_all_prv" {
#     description = "Egrees, all protocols, from private subnets to wide web"
#     type = "egress"
#     from_port = 0
#     to_port = 0
#     protocol = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#     security_group_id = aws_security_group.main_vpc_prv_sg.id
# }