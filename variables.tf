data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

variable "region" {
  type = string
}

variable "env" {
  type = string
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "azs" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "macro_project_name" {
  type = string
}

variable "repository_names" {
  type = list(string)
}

variable "project_name" {
  type = string
}

variable "ci_secrets_name" {
  type = list(string)
}

variable "codeartifact_domain_name" {
  type = string
}

variable "codeartifact_repo_name" {
  type = string
}


variable "codeartifact_repositories" {
  type = list(string)
}

variable "lifecycle_image_count" {
  type = number
}
