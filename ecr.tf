########################
### Container Registry
########################

resource "aws_ecr_repository" "this" {
  name                 = "wiz-demo-web-app"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
}

data "aws_iam_policy_document" "ecr_policy_document" {
  statement {
    sid    = "AllowPullImages"
    effect = "Allow"

    principals {
      type = "AWS"
      identifiers = [
        module.eks.cluster_iam_role_arn
      ]
    }

    actions = [
      "ecr:BatchGetImage",
      "ecr:ListImages"
    ]
  }
}

resource "aws_ecr_repository_policy" "this" {
  repository = aws_ecr_repository.this.name
  policy     = data.aws_iam_policy_document.ecr_policy_document.json
}
