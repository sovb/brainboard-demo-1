### This vars file is global across all repositories ###
region             = "us-east-1"
env                = "staging"
macro_project_name = "yp-ci-demo"

# Secrets to deploy and to be used by codepipeline/codebuild 
# Those must be populated by hand
ci_secrets_name = [
  "sonar_host_secret"
]

# Settings regarding npm packages
# Refer to README to migrate npm packages
codeartifact_domain_name = "yp-domain"
codeartifact_repo_name   = "npm-ypcloud"

ecr_repositories = [
  "fermium"
]