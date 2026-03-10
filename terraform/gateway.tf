resource "kubernetes_deployment" "gateway" {
  metadata {
    name      = "api-gateway"
    namespace = kubernetes_namespace.ecommerce.metadata[0].name

    labels = {
      app = "api-gateway"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "api-gateway"
      }
    }

    template {
      metadata {
        labels = {
          app = "api-gateway"
        }
      }

      spec {
        container {
          name              = "api-gateway"
          image             = "rayhan1994/api-gateway:latest"
          image_pull_policy = "Always"

          port {
            container_port = 8085
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "256Mi"
            }
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
          }
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [
      spec[0].replicas
    ]
  }
}

resource "kubernetes_service" "gateway" {
  wait_for_load_balancer = false

  metadata {
    name      = "api-gateway"
    namespace = kubernetes_namespace.ecommerce.metadata[0].name

    labels = {
      app = "api-gateway"
    }
  }

  spec {
    selector = {
      app = "api-gateway"
    }

    type = "LoadBalancer"

    port {
      port        = 8085
      target_port = 8085
      protocol    = "TCP"
    }
  }
}

resource "kubernetes_horizontal_pod_autoscaler_v2" "gateway" {
  metadata {
    name      = "api-gateway"
    namespace = kubernetes_namespace.ecommerce.metadata[0].name
  }

  spec {
    min_replicas = 1
    max_replicas = 5

    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = kubernetes_deployment.gateway.metadata[0].name
    }

    metric {
      type = "Resource"

      resource {
        name = "cpu"

        target {
          type                = "Utilization"
          average_utilization = 50
        }
      }
    }
  }
}