# <==============   PASSWD GENERATION   =================>
# Create a randomly generated password for MySQL DB
# resource "random_password" "password" {
#   length           = 16
#   special          = true
#   override_special = "_%@\"/"
# }

data "aws_secretsmanager_random_password" "password" {
  password_length = 16
  #exclude_characters = "/@\" "
  exclude_punctuation = true
}

# Create an AWS secret to store master user MySQL DB pass
resource "aws_secretsmanager_secret" "secret" {
   name = "r-ms5-${var.db_name}-${var.db_username}-passwd"
   # to bypass scheduled deteion and overwrite secret with same name
   force_overwrite_replica_secret = true
   recovery_window_in_days = 0
}

# Store random generated pass in AWS secret versions 
resource "aws_secretsmanager_secret_version" "db_pass" {
  secret_id = aws_secretsmanager_secret.secret.id
  secret_string = data.aws_secretsmanager_random_password.password.random_password
# #in case you need more variables to map
#   secret_string = <<EOF
#    {
#     "password": "${random_password.password.result}"
#    }
#   EOF
}

# Import the AWS secret created previously using arn
data "aws_secretsmanager_secret" "secret" {
  arn = aws_secretsmanager_secret.secret.arn
}

# Import the AWS secret version created previously using arn for passwd creation
data "aws_secretsmanager_secret_version" "db_pass" {
  secret_id = data.aws_secretsmanager_secret.secret.arn
} # with data.aws_secretsmanager_secret_version.db_pass.secret_string.password attribute - can decrypt and retrieve pass