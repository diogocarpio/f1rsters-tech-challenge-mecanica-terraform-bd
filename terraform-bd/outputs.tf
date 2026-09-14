output "rds_endpoint" {
  description = "Endpoint do RDS PostgreSQL (host:porta). Consumido pelo repo da Lambda via terraform_remote_state."
  value       = aws_db_instance.postgres.endpoint
  sensitive   = true
}

output "rds_address" {
  description = "Endereco (host) do RDS PostgreSQL, sem a porta."
  value       = aws_db_instance.postgres.address
  sensitive   = true
}

output "db_instance_id" {
  description = "ID da instancia RDS"
  value       = aws_db_instance.postgres.id
}

output "db_security_group_id" {
  description = "Security Group do RDS, caso outro repo precise autorizar acesso (ex: Lambda em VPC)"
  value       = aws_security_group.rds.id
}
