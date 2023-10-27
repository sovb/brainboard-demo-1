terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.13.1"
    }
  }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Environment = var.env
      Owner       = "valentin.monnier"
      Project     = var.project_name
      Deployment  = "TerraForm"
    }
  }
}
