########################
# S3 Bucket
########################

resource "aws_s3_bucket" "this" {
  bucket        = "wiz-demo-mongo-snapshots"
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls = false
  # block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "this" {

  bucket = aws_s3_bucket.this.id
  acl    = "public-read"

  depends_on = [
    aws_s3_bucket_ownership_controls.this,
    aws_s3_bucket_public_access_block.this
  ]
}

data "aws_iam_policy_document" "this" {
  policy_id = "wiz-demo-public-read"

  statement {
    actions = [
      "s3:GetObject"
    ]
    effect = "Allow"
    resources = [
      "${aws_s3_bucket.this.arn}/*"
    ]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.this.json
}
