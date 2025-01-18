########################
### Container registry
########################

resource "aws_ecr_repository" "this" {
  name                 = "wiz-demo-web-app"
  image_tag_mutability = "MUTABLE"
}
########################
# ECS cluster
########################

resource "aws_ecs_cluster" "this" {
  name = "wiz-demo-cluster"
}
