resource "aws_secretsmanager_secret" "project_secrets" {

  for_each = toset(var.ci_secrets_name)

  name        = "${var.macro_project_name}-${each.value}-secrets"
  description = "This resource stores ${each.value} secret used for CI by CodeBuild for ${var.macro_project_name} project"
}

