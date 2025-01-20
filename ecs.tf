locals {
  container_name = "wiz-demo-web-app"
  container_port = 3000
}

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

# ########################
# # ECS Cluster
# ########################

# module "ecs" {
#   source = "terraform-aws-modules/ecs/aws"

#   cluster_name = "wiz-demo-cluster"

#   cluster_configuration = {
#     execute_command_configuration = {
#       logging = "OVERRIDE"
#       log_configuration = {
#         cloud_watch_log_group_name = "/aws/ecs/aws-ec2"
#       }
#     }
#   }

#   fargate_capacity_providers = {
#     FARGATE = {
#       default_capacity_provider_strategy = {
#         weight = 50
#       }
#     }
#     FARGATE_SPOT = {
#       default_capacity_provider_strategy = {
#         weight = 50
#       }
#     }
#   }

#   services = {

#     wiz-demo-web-app = {
#       cpu    = 1024
#       memory = 4096

#       container_definitions = {

#         (local.container_name) = {
#           cpu       = 512
#           memory    = 1024
#           essential = true
#           image     = aws_ecr_repository.this.repository_url
#           port_mappings = [
#             {
#               name          = local.container_name
#               containerPort = local.container_port
#               hostPort      = local.container_port
#               protocol      = "tcp"
#             }
#           ]

#           readonly_root_filesystem = false

#           memory_reservation = 100
#         }
#       }

#       service_connect_configuration = {
#         namespace = aws_service_discovery_http_namespace.this.arn
#         service = {
#           client_alias = {
#             port     = local.container_port
#             dns_name = local.container_name
#           }
#           port_name      = local.container_name
#           discovery_name = local.container_name
#         }
#       }

#       load_balancer = {
#         service = {
#           target_group_arn = module.alb.target_groups["ex_ecs"].arn
#           container_name   = local.container_name
#           container_port   = local.container_port
#         }
#       }

#       subnet_ids = module.vpc.private_subnets

#       security_group_rules = {
#         alb_ingress_3000 = {
#           type                     = "ingress"
#           from_port                = local.container_port
#           to_port                  = local.container_port
#           protocol                 = "tcp"
#           description              = "Service port"
#           source_security_group_id = module.alb.security_group_id
#         }
#         egress_all = {
#           type        = "egress"
#           from_port   = 0
#           to_port     = 0
#           protocol    = "-1"
#           cidr_blocks = ["0.0.0.0/0"]
#         }
#       }
#     }
#   }
# }

########################
# Load Balancer
########################

module "alb" {
  source = "terraform-aws-modules/alb/aws"

  name = "wiz-demo-load-balancer"

  load_balancer_type = "application"

  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.public_subnets

  # Security Group
  security_group_ingress_rules = {
    all_http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = module.vpc.vpc_cidr_block
    }
  }

  listeners = {
    ex_http = {
      port     = 80
      protocol = "HTTP"

      forward = {
        target_group_key = "ex_ecs"
      }
    }
  }

  target_groups = {
    ex_ecs = {
      backend_protocol                  = "HTTP"
      backend_port                      = local.container_port
      target_type                       = "ip"
      deregistration_delay              = 5
      load_balancing_cross_zone_enabled = true

      health_check = {
        enabled             = true
        healthy_threshold   = 5
        interval            = 30
        matcher             = "200"
        path                = "/"
        port                = "traffic-port"
        protocol            = "HTTP"
        timeout             = 5
        unhealthy_threshold = 2
      }

      # Theres nothing to attach here in this definition. Instead,
      # ECS will attach the IPs of the tasks to this target group
      create_attachment = false
    }
  }
}

resource "aws_service_discovery_http_namespace" "this" {
  name = "ex_ecs"
}
