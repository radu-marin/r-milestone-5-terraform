variable "environment" {
    description = "Environment name (DEV/PROD)"
    type = string
}

variable "owner" {
    description = "Project owner (default = radul-terraform)"
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

variable "db_name" {
    description = "The name of the database"
    type = string
}

variable "db_username" {
    description = "The username of the database"
    type = string
}

# variable "db_password" {
#     description = "Create master username password"
#     type = string
#     default = "${data.aws_secretsmanager_secret_version.db_pass.secret_string.password}"
# }