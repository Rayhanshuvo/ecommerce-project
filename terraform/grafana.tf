resource "kubernetes_deployment" "grafana" {
  metadata {
    name      = "grafana"
    namespace = kubernetes_namespace.ecommerce.metadata[0].name
  }
  spec {
    replicas = 1
    selector {
      match_labels = { app = "grafana" }
    }
    template {
      metadata {
        labels = { app = "grafana" }
      }
      spec {
        container {
          name  = "grafana"
          image = "grafana/grafana:latest"
          env {
            name  = "GF_SECURITY_ADMIN_USER"
            value = "admin"
          }
          env {
            name  = "GF_SECURITY_ADMIN_PASSWORD"
            value = "admin123"
          }
          port {
            container_port = 3000
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "grafana" {
  metadata {
    name      = "grafana"
    namespace = kubernetes_namespace.ecommerce.metadata[0].name
  }
  spec {
    selector = { app = "grafana" }
    type     = "LoadBalancer"
    port {
      port        = 3000
      target_port = 3000
    }
  }
}