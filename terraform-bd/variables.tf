variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "sa-east-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "f1rsters-tech-challenge-mecanica"
}

variable "environment" {
  description = "Environment name (dev, homolog, prod) - usado apenas para tags"
  type        = string
  default     = "dev"
}

variable "vpc_id" {
  description = "VPC ID onde o RDS sera criado"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs para o RDS"
  type        = list(string)
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks permitidos a acessar o RDS"
  type        = list(string)
  default     = ["10.0.0.0/8"]
}

variable "db_name" {
  description = "Nome do banco de dados"
  type        = string
  default     = "oficina"
}

variable "db_username" {
  description = "Usuario do banco de dados"
  type        = string
  default     = "oficinauser"
}

variable "db_password" {
  description = "Senha do banco de dados"
  type        = string
  sensitive   = true
}

variable "db_backup_retention_period" {
  description = "Numero de dias para reter backups automaticos (0-35)"
  type        = number
  default     = 7
}
