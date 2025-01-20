locals {
  container_name = "web-app"
  container_port = 3000
}

module "eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_name    = "wiz-demo-cluster"
  cluster_version = "1.31"

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.private_subnets

  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true

  cluster_compute_config = {
    enabled    = true
    node_pools = ["general-purpose"]
  }

}

resource "kubernetes_service" "web-app-service" {

  metadata {
    name = "${local.container_name}-service"
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-scheme" : "internet-facing"
    }
  }
  spec {
    selector = {
      "app.kubernetes.io/name" = local.container_name
    }
    session_affinity = "ClientIP"
    port {
      port        = 80
      target_port = 3000
    }

    type = "LoadBalancer"
  }
}

resource "kubernetes_deployment" "web-app" {
  metadata {
    name = local.container_name
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        "app.kubernetes.io/name" = local.container_name
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/name" = local.container_name
        }
      }

      spec {
        container {
          name  = local.container_name
          image = "${aws_ecr_repository.this.repository_url}:6ff77586"

          port {
            container_port = 3000
          }
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
