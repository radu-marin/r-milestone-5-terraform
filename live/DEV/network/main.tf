# Import network module and fill in necessary arguments
module "network" {
    source = "../../../modules/network"
    environment = "DEV"
    owner = "radul-terraform"
    region = "eu-central-1"
    main_vpc_cidr = "10.0.0.0/16"
    public_subnets = ["10.0.0.0/24", "10.0.1.0/24"]
    private_subnets = ["10.0.2.0/24", "10.0.3.0/24"]
    availability_zones = ["eu-central-1a", "eu-central-1b"]
    db_subnet_group_name = "r-dev-db-subnet_group"
    company_vpn = ["0.0.0.0/0"]
    # nagarro = ["194.117.242.0/26", "195.93.136.0/26"]
}