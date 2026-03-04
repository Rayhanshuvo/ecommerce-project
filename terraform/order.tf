resource "kubernetes_deployment" "order" {
  metadata {
    name      = "order"
    namespace = kubernetes_namespace.ecommerce.metadata[0].name
  }
  spec {
    replicas = 1
    selector {
      match_labels = { app = "order" }
    }
    template {
      metadata {
        labels = { app = "order" }
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
        }
      }
    }
  }
}

resource "kubernetes_service" "order" {
  metadata {
    name      = "order"
    namespace = kubernetes_namespace.ecommerce.metadata[0].name
  }
  spec {
    selector = { app = "order" }
    type     = "LoadBalancer"
    port {
      port        = 8083
      target_port = 8083
    }
  }
}