# Tech Challenge FIAP - Infraestrutura do Banco de Dados

## Propósito

Este repositório provisiona, via Terraform, a infraestrutura de banco de dados (**AWS RDS PostgreSQL**) utilizada pelo sistema de gestão da oficina mecânica (Tech Challenge FIAP). Ele foi separado do repositório principal (`f1rsters-tech-challenge-mecanica`) para isolar a responsabilidade de dados do restante da infraestrutura (aplicação, Lambda, Kubernetes).

Este repositório **não contém código de aplicação** — apenas Infraestrutura como Código (IaC).

## Tecnologias utilizadas

| Tecnologia | Uso |
|---|---|
| Terraform >= 1.0 | Infraestrutura como Código |
| AWS RDS (PostgreSQL 15) | Banco de dados gerenciado |
| AWS S3 + DynamoDB | Backend remoto do state (compartilhado com os demais repos do projeto) |
| GitHub Actions | Pipeline de CI/CD (`terraform plan` / `terraform apply`) |

## Diagrama de arquitetura

```
                       ┌──────────────────────────────┐
                       │      VPC (compartilhada)     │
                       │                               │
   allowed_cidr_blocks │  ┌─────────────────────────┐ │
   ───────────────────►│  │  Security Group (rds)   │ │
     (porta 5432)      │  └───────────┬─────────────┘ │
                       │              │                │
                       │  ┌───────────▼─────────────┐ │
                       │  │   DB Subnet Group       │ │
                       │  └───────────┬─────────────┘ │
                       │              │                │
                       │  ┌───────────▼─────────────┐ │
                       │  │  RDS PostgreSQL 15      │ │
                       │  │  (db.t3.micro, gp3)     │ │
                       │  └─────────────────────────┘ │
                       └──────────────────────────────┘
                                      ▲
                                      │ lê o endpoint via
                                      │ terraform_remote_state
                       ┌──────────────┴───────────────┐
                       │   repo: mecanica-lambda       │
                       │   (Lambda de autenticação)    │
                       └───────────────────────────────┘
```

## Recursos provisionados

- `aws_db_subnet_group` — grupo de subnets privadas para o RDS
- `aws_security_group` — libera a porta 5432 apenas para os CIDRs autorizados
- `aws_db_instance` — instância PostgreSQL 15, `db.t3.micro`, armazenamento `gp3` criptografado, com backup automático

## Pré-requisitos

- Conta AWS com credenciais configuradas (`aws configure` ou secrets no GitHub Actions)
- Terraform >= 1.0
- VPC e subnets privadas já existentes (não são criadas por este repositório — ver nota abaixo)
- Bucket S3 `f1rsters-tech-challenge-terraform-state` e tabela DynamoDB `terraform-locks` já criados (compartilhados entre os 4 repositórios do projeto)

> **Nota:** este repositório reutiliza a mesma VPC do repositório `terraform-kubernets` (não cria uma VPC própria), simplificando o setup do desafio. O `vpc_id` e as subnets são passados como variáveis.

## Passos para execução e deploy

### Local

```bash
cp terraform.tfvars.example terraform.tfvars
# edite terraform.tfvars com os valores da sua conta AWS

terraform init \
  -backend-config="bucket=f1rsters-tech-challenge-terraform-state" \
  -backend-config="key=tech-challenge-mecanica/terraform-bd.tfstate" \
  -backend-config="region=sa-east-1" \
  -backend-config="encrypt=true"

terraform plan
terraform apply
```

### Via CI/CD (GitHub Actions)

O pipeline (`.github/workflows/ci-cd.yml`) roda automaticamente:

- **Pull Request / push em qualquer branch:** `terraform plan` (comenta o plano no PR)
- **Push em `main` (prod) ou `homologacao` (homolog):** `terraform apply` automático

**Secrets necessários no repositório (Settings → Secrets and variables → Actions):**

| Secret | Descrição |
|---|---|
| `AWS_ACCESS_KEY_ID` | Credencial AWS |
| `AWS_SECRET_ACCESS_KEY` | Credencial AWS |
| `DB_PASSWORD` | Senha do banco de dados |

### Destruir a infraestrutura

```bash
terraform destroy
```

## Outputs

| Output | Descrição |
|---|---|
| `rds_endpoint` | Endpoint completo (host:porta) do RDS — consumido pelo repo `mecanica-lambda` |
| `rds_address` | Host do RDS, sem porta |
| `db_instance_id` | ID da instância RDS |
| `db_security_group_id` | Security Group do RDS |

## Repositórios relacionados

- [f1rsters-tech-challenge-mecanica](https://github.com/diogocarpio/f1rsters-tech-challenge-mecanica) — aplicação principal (app base)
- [f1rsters-tech-challenge-mecanica-lambda](https://github.com/diogocarpio/f1rsters-tech-challenge-mecanica-lambda) — Lambda de autenticação (consome este banco)
- [f1rsters-tech-challenge-mecanica-terraform-kubernets](https://github.com/diogocarpio/f1rsters-tech-challenge-mecanica-terraform-kubernets) — cluster Kubernetes e observabilidade

## Grupo

**Turma:** F1RSTERS FIAP - Diogo, Alexandra, Rodrigo e Livea
