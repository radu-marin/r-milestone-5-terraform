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

variable "public_subnets" {
    description = "Public subnets list, diff AZs (default = 10.0.0.0/24, 10.0.1.0/24)"
    default = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "private_subnets" {
    description = "Private subnets list, diff AZs (default = 10.0.2.0/24, 10.0.2.0/24)"
    default = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "availability_zones" {
    description = "Availability zones to be used (default: eu-central-1a, eu-central-1b)"
    default = ["eu-central-1a", "eu-central-1b"]
}

variable "db_subnet_group_name" {
    description = "MySQL db subnet group name"
}

variable "company_vpn" {
    description = "Inbound from company vpn"
    type = list(string)
}

