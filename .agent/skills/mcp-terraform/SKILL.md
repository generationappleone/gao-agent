---
name: MCP Server — Terraform
description: MCP Server for Terraform — enables AI assistants to manage Infrastructure as Code including plan/apply operations, state inspection, module management, and HCL generation.
---

# MCP Server — Terraform

## Overview
Terraform MCP Server provides AI assistants with access to Terraform operations including HCL code generation, plan execution, state management, and infrastructure provisioning through a standardized MCP interface.

## Tools Provided

| Tool | Description |
|------|-------------|
| `terraform_init` | Initialize a Terraform working directory |
| `terraform_plan` | Generate and show an execution plan |
| `terraform_apply` | Apply Terraform changes |
| `terraform_destroy` | Destroy managed infrastructure |
| `terraform_show` | Show current state or plan details |
| `terraform_state_list` | List resources in the state |
| `terraform_state_show` | Show details of a specific resource |
| `terraform_validate` | Validate HCL configuration |
| `terraform_fmt` | Format HCL files |
| `terraform_output` | Show output values |
| `list_modules` | List available Terraform modules |
| `search_providers` | Search Terraform Registry for providers |

## Configuration

```json
{
  "mcpServers": {
    "terraform": {
      "command": "npx",
      "args": ["-y", "@hashicorp/terraform-mcp-server"],
      "env": {
        "TERRAFORM_WORKING_DIR": "/path/to/terraform/project"
      }
    }
  }
}
```

## Use Cases
- AI-assisted infrastructure provisioning
- HCL code generation from natural language requirements
- Infrastructure drift detection and remediation
- State management and resource tracking
- Module discovery and integration
- Cost estimation before applying changes
