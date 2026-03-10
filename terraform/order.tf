resource "kubernetes_deployment" "order" {
  metadata {
    name      = "order"
    namespace = kubernetes_namespace.ecommerce.metadata[0].name

    labels = {
      app = "order"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "order"
      }
    }

    template {
      metadata {
        labels = {
          app = "order"
        }
      }

      spec {
        container {
          name              = "order"
          image             = "rayhan1994/order:latest"
          image_pull_policy = "Always"

          env {
            name  = "SPRING_DATASOURCE_URL"
            value = "jdbc:mysql://mysql-container:3306/order_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC"
          }

          env {
            name  = "SPRING_DATASOURCE_USERNAME"
            value = "app"
          }

          env {
            name  = "SPRING_DATASOURCE_PASSWORD"
            value = "app123"
          }

          env {
            name  = "SPRING_KAFKA_BOOTSTRAP_SERVERS"
            value = "kafka:9092"
          }

          port {
            container_port = 8083
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

resource "kubernetes_service" "order" {
  wait_for_load_balancer = false

  metadata {
    name      = "order"
    namespace = kubernetes_namespace.ecommerce.metadata[0].name

    labels = {
      app = "order"
    }
  }

  spec {
    selector = {
      app = "order"
    }

    type = "LoadBalancer"

    port {
      port        = 8083
      target_port = 8083
      protocol    = "TCP"
    }
  }
}

resource "kubernetes_horizontal_pod_autoscaler_v2" "order" {
  metadata {
    name      = "order"
    namespace = kubernetes_namespace.ecommerce.metadata[0].name
  }

  spec {
    min_replicas = 1
    max_replicas = 5

    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = kubernetes_deployment.order.metadata[0].name
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