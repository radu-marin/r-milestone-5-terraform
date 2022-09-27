# Create MySQL RDS for webapp:
resource "aws_db_instance" "mysql" {
    identifier = "r-milestone-5-${var.db_name}-mysql-db"
    engine = "mysql"
    allocated_storage = 10
    instance_class = "db.t2.micro"
    db_name = var.db_name
    username = var.db_username
    password = data.aws_secretsmanager_secret_version.db_pass.secret_string //.password

    # storage_encrypted = true # good practice but doesn't work on t2.micro

    # location (has to be at least across 2 subnets in 2 AZ-s):
    db_subnet_group_name =  data.terraform_remote_state.network.outputs.db_subnet_group
    # security group:
    vpc_security_group_ids = [data.terraform_remote_state.network.outputs.prv_sg_id]

    # next 3 argruments just for testing env (to destroy easily if needed):
    skip_final_snapshot = true
    backup_retention_period = 0
    apply_immediately = true 

    tags = {
        Name = "r-milestone-5-${var.environment}-mysql-db"
        Owner = var.owner
    }   
}

# Fetch VPC sercurity group id for database
data "terraform_remote_state" "network" {
    backend = "s3"
    config = {
        bucket = var.network_remote_state_bucket
        key = var.network_remote_state_key
        region = var.region
    }
}