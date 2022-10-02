output "main_vpc_id" {
    description = "Main VPC id"
    value = module.network.main_vpc_id
}

output "pub_subnets_id" {
    description = "List of public subnets ids"
    value = module.network.pub_subnets_id
}

output "prv_subnets_id" {
    description = "List of private subnets ids"
    value = module.network.prv_subnets_id
}

output "pub_sg_id" {
    description = "main vpc security group for public subnet"
    value = module.network.pub_sg_id
}

output "prv_sg_id" {
    description = "main vpc security group for private subnets"
    value = module.network.prv_sg_id
}

output "bastion_sg_id" {
    description = "bastion vpc security group (in pub subnet)"
    value = module.network.bastion_sg_id
}

output "alb_sg_id" {
    description = "ALB vpc security group (located in pub subnets)"
    value = module.network.alb_sg_id
}

output "db_subnet_group" {
    description = "MySQL DB Subnet Group id"
    value = module.network.db_subnet_group
}