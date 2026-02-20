---
name: Terraform / IaC
description: Skill for Infrastructure as Code with Terraform — covering HCL syntax, providers, resources, modules, state management, variables, outputs, workspaces, and cloud provisioning (AWS, GCP, Azure).
---

# Terraform / IaC Skill

## Overview
Terraform is the leading Infrastructure as Code (IaC) tool by HashiCorp. It uses HCL (HashiCorp Configuration Language) to define infrastructure across AWS, Azure, GCP, and 3000+ providers. Terraform manages state, plans changes, and applies them declaratively.

**References**:
- [Terraform Documentation](https://developer.hashicorp.com/terraform/docs)
- [Terraform Registry](https://registry.terraform.io/)

---

## Project Structure

```
infra/
├── main.tf
├── variables.tf
├── outputs.tf
├── providers.tf
├── terraform.tfvars
├── modules/
│   ├── vpc/
│   ├── rds/
│   └── ecs/
└── environments/
    ├── dev/
    ├── staging/
    └── prod/
```

---

## AWS Example

```hcl
# providers.tf
terraform {
  required_version = ">= 1.7"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
  backend "s3" {
    bucket = "myapp-terraform-state"
    key    = "prod/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
    dynamodb_table = "terraform-locks"
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = { Project = var.project_name, Environment = var.environment, ManagedBy = "terraform" }
  }
}

# variables.tf
variable "aws_region" { default = "us-east-1" }
variable "project_name" { default = "myapp" }
variable "environment" { default = "prod" }
variable "db_password" { type = string, sensitive = true }

# main.tf
module "vpc" {
  source = "./modules/vpc"
  project_name = var.project_name
  environment  = var.environment
}

resource "aws_db_instance" "main" {
  identifier          = "${var.project_name}-${var.environment}"
  engine              = "postgres"
  engine_version      = "16.1"
  instance_class      = "db.t3.micro"
  allocated_storage   = 20
  db_name             = var.project_name
  username            = "admin"
  password            = var.db_password
  publicly_accessible = false
  skip_final_snapshot = var.environment != "prod"
  vpc_security_group_ids = [module.vpc.db_sg_id]
  db_subnet_group_name   = module.vpc.db_subnet_group
}

resource "aws_s3_bucket" "uploads" {
  bucket = "${var.project_name}-${var.environment}-uploads"
}

resource "aws_s3_bucket_public_access_block" "uploads" {
  bucket = aws_s3_bucket.uploads.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# outputs.tf
output "db_endpoint" { value = aws_db_instance.main.endpoint }
output "s3_bucket" { value = aws_s3_bucket.uploads.bucket }
```

---

## Commands

```bash
terraform init          # Initialize providers
terraform plan          # Preview changes
terraform apply         # Apply changes
terraform destroy       # Tear down infrastructure
terraform fmt           # Format HCL files
terraform validate      # Validate configuration
terraform state list    # List managed resources
terraform output        # Show outputs
terraform workspace list  # List workspaces
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **Remote state** | S3/GCS backend with locking |
| **Modules** | Reusable modules for VPC, DB, compute |
| **Variables** | Use variables.tf with types and defaults |
| **Sensitive** | Mark passwords/keys as `sensitive = true` |
| **Workspaces** | Environment separation (dev/staging/prod) |
| **Tagging** | Default tags on all resources |
| **Locking** | DynamoDB/Cloud Storage for state locking |
| **Plan before Apply** | Always review `terraform plan` |
| **Version constraints** | Pin provider versions |
| **Outputs** | Export endpoints, IDs for other systems |

---

## Rules Integration
- **HCL**: Declarative resource definitions
- **Modules**: Reusable infrastructure components
- **State**: Remote backend with locking
- **Security**: Sensitive variables, private subnets
- **Workflow**: init → plan → apply → destroy
