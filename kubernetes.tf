resource "aws_ecr_repository" "this" {
  name                 = "wiz-demo-web-app"
  image_tag_mutability = "MUTABLE"
}
