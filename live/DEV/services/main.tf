# OBS: IF Amazon Linux AMI not selected for web_server_ami 
# Please install and configure SSM agent in services module (user data)

module "services" {
    source = "../../../modules/services"
    environment = "DEV"
    owner = "radul-terraform" 
    region = "eu-central-1"       
    network_remote_state_bucket = "r-milestone-5-tf-state-personal"
    network_remote_state_key = "DEV/network/terraform.tfstate"
    web_server_ami = "ami-0e2031728ef69a466"
    web_server_instance_type = "t2.micro"
    min_size = 2
    max_size = 3

    webapp_repo_link = "https://github.com/RevianLabs/devops-webapp-sample"

    db_remote_state_bucket = "r-milestone-5-tf-state-personal"
    db_remote_state_key = "DEV/data-storage/terraform.tfstate"
}