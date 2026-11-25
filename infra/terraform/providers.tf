terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # Al principio el estado queda local (terraform.tfstate). Cuando ya domines el flujo,
  # muévelo a S3 (actividad del README) descomentando esto:
  # backend "s3" {
  #   bucket       = "tu-bucket-de-estado-terraform"
  #   key          = "setupcol/terraform.tfstate"
  #   region       = "us-east-1"
  #   use_lockfile = true
  # }
}

# Usamos us-east-1 para todo: CloudFront solo acepta certificados ACM creados en esa región,
# y así evitamos manejar dos providers mientras aprendes.
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = var.project
      ManagedBy = "terraform"
    }
  }
}

data "aws_caller_identity" "current" {}
