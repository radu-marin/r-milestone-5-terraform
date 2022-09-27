output "main_vpc_id" {
    description = "Main VPC id"
    value = module.network.main_vpc_id
}

output "pub1_subnet_id" {
    description = "Public subnet id"
    value = module.network.pub1_subnet_id
}

output "pub2_subnet_id" {
    description = "Public subnet id"
    value = module.network.pub2_subnet_id
}

output "prv1_subnet_id" {
    description = "Private subnet 1 id"
    value =  module.network.prv1_subnet_id
}

output "prv2_subnet_id" {
    description = "Private subnet 2 id"
    value =   module.network.prv2_subnet_id
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

output "db_subnet_group" {
    description = "MySQL DB Subnet Group id"
    value = module.network.db_subnet_group
}