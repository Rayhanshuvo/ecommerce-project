resource "kubernetes_deployment" "kafka_ui" {
  metadata {
    name      = "kafka-ui"
    namespace = kubernetes_namespace.ecommerce.metadata[0].name
  }
  spec {
    replicas = 1
    selector {
      match_labels = { app = "kafka-ui" }
    }
    template {
      metadata {
        labels = { app = "kafka-ui" }
      }
      spec {
        container {
          name  = "kafka-ui"
          image = "ghcr.io/kafbat/kafka-ui:latest"
          env {
            name  = "KAFKA_CLUSTERS_0_NAME"
            value = "local"
          }
          env {
            name  = "KAFKA_CLUSTERS_0_BOOTSTRAPSERVERS"
            value = "kafka:9092"
          }
          env {
            name  = "DYNAMIC_CONFIG_ENABLED"
            value = "true"
          }
          port {
            container_port = 8080
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "kafka_ui" {
  metadata {
    name      = "kafka-ui"
    namespace = kubernetes_namespace.ecommerce.metadata[0].name
  }
  spec {
    selector = { app = "kafka-ui" }
    type     = "LoadBalancer"
    port {
      port        = 8080
      target_port = 8080
    }
  }
}