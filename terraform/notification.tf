resource "kubernetes_deployment" "notification" {
  metadata {
    name      = "notification"
    namespace = kubernetes_namespace.ecommerce.metadata[0].name
  }
  spec {
    replicas = 1
    selector {
      match_labels = { app = "notification" }
    }
    template {
      metadata {
        labels = { app = "notification" }
      }
      spec {
        container {
          name              = "notification"
          image             = "rayhan1994/notification:latest"
          image_pull_policy = "Always"
          env {
            name  = "SPRING_DATASOURCE_URL"
            value = "jdbc:mysql://mysql-container:3306/notification?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC"
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
            container_port = 8082
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "notification" {
  metadata {
    name      = "notification"
    namespace = kubernetes_namespace.ecommerce.metadata[0].name
  }
  spec {
    selector = { app = "notification" }
    type     = "LoadBalancer"
    port {
      port        = 8082
      target_port = 8082
    }
  }
}