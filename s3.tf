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