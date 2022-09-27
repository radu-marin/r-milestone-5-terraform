# Create (DEV) MySQL RDS for webapp:
module "mysql_data" {
    source = "../../../modules/data-storage"
    #to try and check if it works with github:
    #source = "git::git@github.com:radu-marin/terraform-up-and-running-modules.git?ref=v0.0.1"
    environment ="PROD"
    owner = "radul-terraform"
    region = "eu-central-1"

    network_remote_state_bucket = "r-milestone-5-tf-state"
    network_remote_state_key = "PROD/network/terraform.tfstate"

    db_name = "prod"
    db_username = "admin"
}