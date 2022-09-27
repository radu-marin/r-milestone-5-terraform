# Create (DEV) MySQL RDS for webapp:
module "mysql_data" {
    source = "../../../modules/data-storage"
    #to try and check if it works with github, an example:
    #source = "git::git@github.com:radu-marin/terraform-up-and-running-modules.git?ref=v0.0.1"
    environment ="DEV"
    owner = "radul-terraform"
    region = "eu-central-1"

    network_remote_state_bucket = "r-milestone-5-tf-state-personal"
    network_remote_state_key = "DEV/network/terraform.tfstate"

    db_name = "dev"
    db_username = "admin"
}