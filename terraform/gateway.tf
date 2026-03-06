resource "kubernetes_deployment" "gateway" {
  metadata {
    name      = "api-gateway"
    namespace = kubernetes_namespace.ecommerce.metadata[0].name
  }
  spec {
    replicas = 1
    selector {
      match_labels = { app = "api-gateway" }
    }
    template {
      metadata {
        labels = { app = "api-gateway" }
      }
      spec {
        container {
          name              = "api-gateway"
          image             = "rayhan1994/api-gateway:latest"
          image_pull_policy = "Always"
          port {
            container_port = 8080
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "gateway" {
  wait_for_load_balancer = false
  metadata {
    name      = "api-gateway"
    namespace = kubernetes_namespace.ecommerce.metadata[0].name
  }
  spec {
    selector = { app = "api-gateway" }
    type     = "LoadBalancer"
    port {
      port        = 8085
      target_port = 8085
    }
  }
}