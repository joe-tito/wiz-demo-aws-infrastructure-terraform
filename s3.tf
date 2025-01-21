########################
# S3 Bucket
########################

resource "aws_s3_bucket" "this" {
  bucket        = "wiz-demo-mongo-snapshots-bucket"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_policy = false
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
