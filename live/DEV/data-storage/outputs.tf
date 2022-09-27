# provide db address and port to web server
output "address" {
  value       = module.mysql_data.address
  description = "Connect to the database at this endpoint"
}

output "user" {
  value = module.mysql_data.user
  description = "The master username for the database."
}

output "port" {
  value       = module.mysql_data.port
  description = "The port the database is listening on"
}

output "db_name" {
    value = module.mysql_data.db_name
    description = "The database name"
}

output "dbpass_secret_arn" {
    value = module.mysql_data.dbpass_secret_arn
    description = "The arn of the aws_secretsmanager_secret that stores the db pass"
}