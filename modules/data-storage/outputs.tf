# provide db address and port to web server
output "address" {
  value       = aws_db_instance.mysql.address
  description = "Connect to the database at this endpoint"
}

output "user" {
    value = aws_db_instance.mysql.username
    description = "The master username for the database."
}

output "port" {
  value       = aws_db_instance.mysql.port
  description = "The port the database is listening on"
}

output "db_name" {
    value = aws_db_instance.mysql.db_name
    description = "The database name"
}

output "dbpass_secret_arn" {
    value = data.aws_secretsmanager_secret.secret.arn
    description = "The arn of the aws_secretsmanager_secret that stores the db pass"
}