output "main_vpc_id" {
    description = "Main VPC id"
    value = aws_vpc.main_vpc.id
}

output "pub_subnets_id" {
    description = "List of public subnets ids"
    value = [for subnet in aws_subnet.public_subnets: subnet.id]
}

output "prv_subnets_id" {
    description = "List of private subnets ids"
    value = [for subnet in aws_subnet.private_subnets: subnet.id]
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
    description = "bastion vpc security group (located in pub subnet)"
    value = aws_security_group.bastion.id
}

output "alb_sg_id" {
    description = "ALB vpc security group (located in pub subnets)"
    value = aws_security_group.alb.id
}

output "db_subnet_group" {
    description = "MySQL DB Subnet Group id"
    value = aws_db_subnet_group.default.id
}