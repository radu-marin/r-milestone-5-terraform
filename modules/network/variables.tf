variable "environment" {
    description = "Environment (DEV/PROD)"
}

variable "owner" {
    description = "Project owner (default = radul-terraform)"
    default = "radul-terraform"
}

variable "region" {
    description = "AWS Deployment region (default = eu-central-1)"
    default = "eu-central-1"
}

variable "main_vpc_cidr" {
    description = "VPC CIDR block (default = 10.0.0.0/16)"
    default = "10.0.0.0/16"  
}

variable "public_subnet_1_cidr" {
    description = "Public subnet 1 CIDR block (default = 10.0.0.0/24)"
    default = "10.0.0.0/24"
}

variable "public_subnet_2_cidr" {
    description = "Public subnet 1 CIDR block (default = 10.0.0.0/24)"
    default = "10.0.1.0/24"
}

variable "private_subnet_1_cidr" {
    description = "Private subnet 1 CIDR block (default = 10.0.1.0/24)"
    default = "10.0.2.0/24"
}

variable "private_subnet_2_cidr" {
    description = "Private subnet 2 CIDR block (default = 10.0.2.0/24)"
    default = "10.0.3.0/24"
}

variable "db_subnet_group_name" {
    description = "MySQL db subnet group name"
}

variable "company_vpn" {
    description = "Inbound from company vpn"
    type = list(string)
}

