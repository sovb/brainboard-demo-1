output "kms_key_arn" {
  value = aws_kms_key.cmk_key.arn
}

output "artifacts_bucket" {
  value = aws_s3_bucket.artifacts_bucket.bucket
}