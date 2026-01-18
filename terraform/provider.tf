terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0.0"
    }
  }

  backend "s3" {
    bucket         = "pepires58-sideprojects-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "sa-east-1"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.common_tags
  }
}
