# SideProjectsInfra

Infrastructure as Code (IaC) for side projects using Terraform and GitHub Actions.

## Overview

This repository manages AWS infrastructure using Terraform with automated deployments via GitHub Actions. The infrastructure includes:

- VPC with configurable CIDR block
- Public and Private Subnets across multiple Availability Zones
- Internet Gateway for public subnet connectivity
- Route Tables and associations
- Support for both dev and prod environments (sharing the same VPC)

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

- **VPC**: Main virtual private cloud with DNS support enabled
- **Internet Gateway**: Provides internet access for public subnets
- **Public Subnets**: Subnets with auto-assigned public IPs and internet access
- **Private Subnets**: Isolated subnets for internal resources
- **Route Tables**: Separate routing for public and private subnets

The module simplifies VPC management and follows AWS best practices.

### Terraform Backend

The pipeline automatically creates and manages:
- S3 bucket for Terraform state storage (with versioning and encryption)

State locking is not implemented to simplify the setup.

## GitHub Actions Workflow

The workflow consists of three main jobs:

1. **setup-backend**: Creates S3 bucket if it doesn't exist
2. **terraform-plan**: Runs terraform plan for both dev and prod environments
3. **terraform-apply**: Applies changes to infrastructure (only on main branch)

### Workflow Triggers

- Push to `main` or `develop` branches
- Pull requests to `main` or `develop` branches
- Manual workflow dispatch

## Usage

### Automatic Deployment

Push changes to the `main` branch to automatically deploy infrastructure to both dev and prod environments.

### Manual Deployment

Use the GitHub Actions "Workflow Dispatch" feature to manually trigger deployments for a specific environment.

### Local Development

1. Initialize Terraform:
   ```bash
   cd terraform
   terraform init \
     -backend-config="bucket=sideprojects-terraform-state" \
     -backend-config="key=dev/vpc/terraform.tfstate" \
     -backend-config="region=sa-east-1" \
     -backend-config="encrypt=true"
   ```

2. Plan changes:
   ```bash
   terraform plan -var="environment=dev"
   ```

3. Apply changes:
   ```bash
   terraform apply -var="environment=dev"
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
