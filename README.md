# SideProjectsInfra

Infrastructure as Code (IaC) for side projects using Terraform and GitHub Actions.

## Overview

This repository manages AWS infrastructure using Terraform with automated deployments via GitHub Actions. The infrastructure includes:

- VPC with configurable CIDR block (10.0.0.0/16)
- Public and Private Subnets across Availability Zones in sa-east-1
- Internet Gateway for public subnet connectivity
- Route Tables and associations
- Deployed to sa-east-1 (São Paulo) region

## Prerequisites

- AWS Account with appropriate permissions
- GitHub repository secrets configured:
  - `AWS_ACCESS_KEY_ID`
  - `AWS_SECRET_ACCESS_KEY`

## Configuration

The infrastructure is configured via `.pipeline.yaml` in the root directory. This file defines:

- Terraform version and backend configuration (S3 bucket, region, state key)

## Infrastructure Components

### VPC Resources

The infrastructure uses the official [terraform-aws-modules/vpc](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest) module, which provides:

- **VPC**: Main virtual private cloud with DNS support enabled (10.0.0.0/16)
- **Internet Gateway**: Provides internet access for public subnets
- **Public Subnets**: 2 subnets with auto-assigned public IPs and internet access (10.0.1.0/24, 10.0.2.0/24)
- **Private Subnets**: 2 isolated subnets for internal resources (10.0.101.0/24, 10.0.102.0/24)
- **Route Tables**: Separate routing for public and private subnets
- **Region**: Deployed to sa-east-1 (São Paulo)
- **Availability Zone**: sa-east-1a

The module simplifies VPC management and follows AWS best practices.

### Terraform Backend

The pipeline automatically creates and manages:
- S3 bucket for Terraform state storage (with versioning and encryption)

State locking is not implemented to simplify the setup.

## GitHub Actions Workflow

The workflow consists of three main jobs:

1. **setup-backend**: Creates S3 bucket if it doesn't exist
2. **terraform-plan**: Runs terraform plan
3. **terraform-apply**: Applies changes to infrastructure (only on main branch)

### Workflow Triggers

- Push to `main` branch
- Pull requests to `main` branch

## Usage

### Automatic Deployment

Push changes to the `main` branch to automatically deploy infrastructure.

### Local Development

1. Initialize Terraform:
   ```bash
   cd terraform
   terraform init \
     -backend-config="bucket=pepires58-sideprojects-terraform-state" \
     -backend-config="key=prod/terraform.tfstate" \
     -backend-config="region=sa-east-1" \
     -backend-config="encrypt=true"
   ```

2. Plan changes:
   ```bash
   terraform plan
   ```

3. Apply changes:
   ```bash
   terraform apply
   ```

## Outputs

The Terraform configuration outputs the following values:

- VPC ID
- VPC CIDR block
- Internet Gateway ID
- Public subnet IDs
- Private subnet IDs
- Route table IDs
- Availability zones

## Module Structure

```
.
├── .github/
│   └── workflows/
│       └── terraform-deploy.yml
├── terraform/
│   ├── main.tf          # VPC module configuration
│   ├── variables.tf     # Input variables
│   ├── outputs.tf       # Output values
│   └── provider.tf      # Provider and backend configuration
├── .pipeline.yaml       # Pipeline configuration
└── README.md
```

## Terraform Modules

This infrastructure uses the official [terraform-aws-modules/vpc/aws](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest) module (version ~> 5.0) for VPC management. This module:

- Follows AWS best practices
- Provides comprehensive VPC configuration
- Simplifies infrastructure management
- Is actively maintained by the community

## Security

- Terraform state is stored in an encrypted S3 bucket with versioning enabled
- AWS credentials are stored as GitHub secrets and never committed to the repository
- State locking is not implemented for simplicity

## Contributing

1. Create a feature branch
2. Make your changes
3. Submit a pull request
4. The workflow will run terraform plan on your PR
5. After approval and merge to main, changes will be automatically applied

## License

See LICENSE file for details.
