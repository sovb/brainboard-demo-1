resource "aws_s3_bucket" "artifacts_bucket" {
  bucket = lower("yp-codepipeline-artifacts-bucket")
}

resource "aws_s3_bucket_ownership_controls" "artifacts_bucket" {
  bucket = aws_s3_bucket.artifacts_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "artifacts_bucket" {
  depends_on = [aws_s3_bucket_ownership_controls.artifacts_bucket]

  bucket = aws_s3_bucket.artifacts_bucket.id
  acl    = "private"
}

resource "aws_ecr_repository" "destination_ecr_repository" {
  for_each = toset(var.ecr_repositories)
  name     = each.value

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = aws_kms_key.cmk_key.arn
  }
}

resource "aws_secretsmanager_secret" "project_secrets" {

  for_each = toset(var.ci_secrets_name)

  name        = "${var.macro_project_name}-${each.value}-secrets"
  description = "This resource stores ${each.value} secret used for CI by CodeBuild for ${var.macro_project_name} project"
}

