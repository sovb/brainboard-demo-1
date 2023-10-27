module "network" {
  source = "./modules/network"

  project_name         = var.macro_project_name
  vpc_cidr             = var.vpc_cidr
  private_subnet_cidrs = var.private_subnet_cidrs
  public_subnet_cidrs  = var.public_subnet_cidrs
  azs                  = var.azs
}

module "repository" {
  source = "./modules/stack"

  for_each = toset(var.repository_names)

  region             = var.region
  env                = var.env
  macro_project_name = var.macro_project_name

  repository_name = each.key
  project_name    = var.project_name

  artifacts_bucket = module.protected_resources.artifacts_bucket
  kms_key_arn      = module.protected_resources.kms_key_arn

  vpc_id             = module.network.vpc_id
  private_subnet_ids = module.network.private_subnet_ids
  security_group_ids = module.network.security_group_ids

  codeartifact_domain_name     = var.codeartifact_domain_name
  codeartifact_repository_name = var.codeartifact_repo_name
  lifecycle_image_count        = var.lifecycle_image_count

}


module "protected_resources" {
  source             = "./modules/protected-resources"
  macro_project_name = var.macro_project_name

  ci_secrets_name          = var.ci_secrets_name
  codeartifact_domain_name = var.codeartifact_domain_name
  codeartifact_repo_name   = var.codeartifact_repo_name

  ecr_repositories = var.ecr_repositories


}