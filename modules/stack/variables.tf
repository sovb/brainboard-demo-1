data "aws_caller_identity" "current" {}
data "aws_region" "current" {}


variable "region" {
  type = string
}

variable "env" {
  type = string
}

variable "macro_project_name" {
  type = string
}

variable "kms_key_arn" {
  type = string
}

variable "repository_name" {
  type = string
}

variable "project_name" {
  type = string
}

variable "artifacts_bucket" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(string)
}

variable "codeartifact_domain_name" {
  type = string
}

variable "codeartifact_repository_name" {
  type = string
}

variable "lifecycle_image_count" {
  type = number
}
