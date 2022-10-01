output "main_vpc_id" {
    description = "Main VPC id"
    value = aws_vpc.main_vpc.id
}

output "pub1_subnet_id" {
    description = "Public subnet id"
    value = aws_subnet.public_subnets[0].id
}

output "pub2_subnet_id" {
    description = "Public subnet id"
    value = aws_subnet.public_subnets[1].id
}

output "prv1_subnet_id" {
    description = "Private subnet 1 id"
    value = aws_subnet.private_subnets[0].id  
}

output "prv2_subnet_id" {
    description = "Private subnet 2 id"
    value = aws_subnet.private_subnets[1].id  
}

output "pub_sg_id" {
    description = "main vpc security group for public subnet"
    value = aws_security_group.main_vpc_pub_sg.id
}

output "prv_sg_id" {
    description = "main vpc security group for private subnets"
    value = aws_security_group.main_vpc_prv_sg.id
}

output "bastion_sg_id" {
    description = "bastion vpc security group (in pub subnet)"
    value = aws_security_group.bastion.id
}

output "db_subnet_group" {
    description = "MySQL DB Subnet Group id"
    value = aws_db_subnet_group.default.id
}