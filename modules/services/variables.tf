variable "environment" {
    description = "Environment used (DEV/PROD)"
}

variable "owner" {
    description = "Owner of deployment (Default: radul-terraform)"
    default = "radul-terraform"
}

variable "region" {
    description = "Region to be used (Default: eu-central-1)"
    default = "eu-central-1"
}

variable "network_remote_state_bucket" {
    description = "Id of network remote state bucket"
}

variable "network_remote_state_key" {
    description = "Key of network remote state bucket (path in remote state s3 bucket)"
}

variable "web_server_ami" {
    # OBS: IF Amazon Linux not selected one must install and configure SSM agent in user data
    description = "AMI (image) of web server (Default: ami-0e2031728ef69a466)"
    default = "ami-0e2031728ef69a466"
}

variable "web_server_instance_type" {
    description = "Web server instance type (Default: t2.micro)"
    default = "t2.micro"
}

variable "min_size" {
    description = "Min size of ASG (num of instances as webapp hosts)"
    default = 2
}

variable "max_size" {
    description = "Min size of ASG (num of instances as webapp hosts)"
    default = 3
}

variable "bastion_ami" {
    description = "AMI (image) of bastion (Default: ami-0e2031728ef69a466)"
    default = "ami-0e2031728ef69a466"
}

variable "bastion_instance_type" {
    description = "Bastion instance type (Default: t2.micro)"
    default = "t2.micro"
}

variable "ws_iam_policy_arn" {
    description = "List of IAM policies for EC2 Web Server (default: S3 Access and SSM)"
    type = list
    default = ["arn:aws:iam::aws:policy/AmazonS3FullAccess", 
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]
}

variable "webapp_repo_link" {
    description = "Link to webapp git repo (default: https://github.com/RevianLabs/devops-webapp-sample)"
    default = "https://github.com/RevianLabs/devops-webapp-sample"
}

variable "db_remote_state_bucket" {
    description = "The name of the S3 bucket for the database's remote state"
    type        = string
}

variable "db_remote_state_key" {
    description = "The path for the database's remote state in S3 (e.g. stage/data-storage/mysql/terraform.tfstate)"
    type        = string
}

# variable "db_password" {
#     description = "Password for the master username for the database."
#     type = string
# }