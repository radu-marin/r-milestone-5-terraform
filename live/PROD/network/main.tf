# Import network module and fill in necessary arguments
module "network" {
    source = "../../../modules/network"
    environment = "PROD"
    owner = "radul"
    region = "eu-central-1"
    main_vpc_cidr = "10.0.0.0/16"
    public_subnet_cidr = "10.0.0.0/24"
    private_subnet_1_cidr = "10.0.1.0/24"
    private_subnet_2_cidr = "10.0.2.0/24"
    db_subnet_group_name = "r-prod-db-subnet_group"
}