module "eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_name    = "wiz-demo-cluster"
  cluster_version = "1.31"

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.public_subnets
  control_plane_subnet_ids = module.vpc.public_subnets

  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true

  cluster_compute_config = {
    enabled    = true
    node_pools = ["general-purpose"]
  }

}

locals {
  container_name = "web-app"
  container_port = 3000
}

resource "kubernetes_deployment" "example" {
  metadata {
    name = local.container_name
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = local.container_name
      }
    }

    template {
      metadata {
        labels = {
          app = local.container_name
        }
      }

      spec {
        container {
          name  = local.container_name
          image = aws_ecr_repository.this.repository_url

          port {
            container_port = 3000
          }

          # resources {
          #   limits = {
          #     cpu    = "0.5"
          #     memory = "512Mi"
          #   }
          #   requests = {
          #     cpu    = "250m"
          #     memory = "50Mi"
          #   }
          # }

          # liveness_probe {
          #   http_get {
          #     path = "/"
          #     port = 80

          #     http_header {
          #       name  = "X-Custom-Header"
          #       value = "Awesome"
          #     }
          #   }

          #   initial_delay_seconds = 3
          #   period_seconds        = 3
          # }
        }
      }
    }
  }
}

# module "lb_role" {
#  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

#  role_name                              = "${var.env_name}_eks_lb"
#  attach_load_balancer_controller_policy = true

#  oidc_providers = {
#      main = {
#      provider_arn               = var.oidc_provider_arn
#      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
#      }
#  }
#  }

#  resource "kubernetes_service_account" "service-account" {
#  metadata {
#      name      = "aws-load-balancer-controller"
#      namespace = "kube-system"
#      labels = {
#      "app.kubernetes.io/name"      = "aws-load-balancer-controller"
#      "app.kubernetes.io/component" = "controller"
#      }
#      annotations = {
#      "eks.amazonaws.com/role-arn"               = module.lb_role.iam_role_arn
#      "eks.amazonaws.com/sts-regional-endpoints" = "true"
#      }
#  }
#  }
