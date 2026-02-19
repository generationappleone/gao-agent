---
name: Terraform / IaC
description: Skill for Infrastructure as Code with Terraform — covering HCL syntax, providers, resources, modules, state management, variables, outputs, workspaces, and cloud provisioning (AWS, GCP, Azure).
---

# Terraform / IaC Skill

## Overview
Terraform is an Infrastructure as Code tool by HashiCorp for provisioning cloud resources declaratively using HCL (HashiCorp Configuration Language).

**Reference**: [Terraform Documentation](https://developer.hashicorp.com/terraform/docs)

## Project Structure
```
infrastructure/
├── main.tf              # Main resources
├── variables.tf         # Input variables
├── outputs.tf           # Output values
├── providers.tf         # Provider configuration
├── terraform.tfvars     # Variable values (gitignored)
├── backend.tf           # State backend config
├── versions.tf          # Version constraints
└── modules/
    ├── vpc/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── ecs/
```

## Provider Configuration
```hcl
# providers.tf
terraform {
  required_version = ">= 1.7.0"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
  backend "s3" {
    bucket = "my-terraform-state"
    key    = "prod/terraform.tfstate"
    region = "ap-southeast-1"
    encrypt = true
    dynamodb_table = "terraform-locks"
  }
}

provider "aws" {
  region = var.aws_region
  default_tags { tags = { Environment = var.environment, ManagedBy = "terraform" } }
}
```

## Resources
```hcl
# VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = { Name = "${var.project}-vpc" }
}

resource "aws_subnet" "public" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  availability_zone = var.availability_zones[count.index]
  tags = { Name = "${var.project}-public-${count.index}" }
}

# Security Group
resource "aws_security_group" "web" {
  name_prefix = "${var.project}-web-"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

## Variables & Outputs
```hcl
# variables.tf
variable "project" { type = string, default = "myapp" }
variable "environment" { type = string, validation { condition = contains(["dev","staging","prod"], var.environment) } }
variable "aws_region" { type = string, default = "ap-southeast-1" }

# outputs.tf
output "vpc_id" { value = aws_vpc.main.id }
output "public_subnets" { value = aws_subnet.public[*].id }
```

## Commands
```bash
terraform init          # Initialize providers
terraform plan          # Preview changes
terraform apply         # Apply changes
terraform destroy       # Destroy all resources
terraform fmt           # Format files
terraform validate      # Validate config
terraform state list    # List managed resources
```

## Best Practices

| Practice | Description |
|----------|-------------|
| **Remote state** | Use S3/GCS backend with locking |
| **Modules** | Reusable components for common patterns |
| **Variables** | Never hardcode values — use variables |
| **Workspaces** | Separate environments (dev/staging/prod) |
| **`terraform fmt`** | Always format before committing |
| **State locking** | Use DynamoDB/GCS for concurrent access |
| **Plan before apply** | Always review `terraform plan` output |
| **Version pins** | Pin provider and Terraform versions |
| **Tagging** | Tag all resources with `default_tags` |
| **Secrets** | Use vault or environment variables, never `.tfvars` in git |
