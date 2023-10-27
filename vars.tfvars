region             = "us-east-1"
env                = "staging"
macro_project_name = "yp-ci-demo"

ci_secrets_name = [
  "sonar_host",
  "sonar_login",
  "sonar_password"
]

codeartifact_domain_name = "yp-domain"
codeartifact_repo_name   = "npm-ypcloud"
codeartifact_repositories = [
  "yp-logger",
  "yp-swagger",
  "ypcloud"
]

