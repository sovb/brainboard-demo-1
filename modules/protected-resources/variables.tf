data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

variable "macro_project_name" {
  type = string
}

variable "codeartifact_domain_name" {
  type = string
}

variable "codeartifact_repo_name" {
  type = string
}

variable "ecr_repositories" {
  type = list(string)
}

variable "ci_secrets_name" {
  type = list(string)
}
