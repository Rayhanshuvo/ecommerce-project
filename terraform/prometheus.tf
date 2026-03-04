resource "kubernetes_config_map" "prometheus" {
  metadata {
    name      = "prometheus-config"
    namespace = kubernetes_namespace.ecommerce.metadata[0].name
  }
  data = {
    "prometheus.yml" = <<-EOT
      global:
        scrape_interval: 15s
      scrape_configs:
        - job_name: 'notification'
          metrics_path: '/actuator/prometheus'
          static_configs:
            - targets: ['notification:8082']
        - job_name: 'order'
          metrics_path: '/actuator/prometheus'
          static_configs:
            - targets: ['order:8083']
    EOT
  }
}

resource "kubernetes_deployment" "prometheus" {
  metadata {
    name      = "prometheus"
    namespace = kubernetes_namespace.ecommerce.metadata[0].name
  }
  spec {
    replicas = 1
    selector {
      match_labels = { app = "prometheus" }
    }
    template {
      metadata {
        labels = { app = "prometheus" }
      }
      spec {
        container {
          name  = "prometheus"
          image = "prom/prometheus:latest"
          args  = ["--config.file=/etc/prometheus/prometheus.yml"]
          port {
            container_port = 9090
          }
          volume_mount {
            name       = "config"
            mount_path = "/etc/prometheus"
          }
        }
        volume {
          name = "config"
          config_map {
            name = kubernetes_config_map.prometheus.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "prometheus" {
  metadata {
    name      = "prometheus"
    namespace = kubernetes_namespace.ecommerce.metadata[0].name
  }
  spec {
    selector = { app = "prometheus" }
    type     = "LoadBalancer"
    port {
      port        = 9090
      target_port = 9090
    }
  }
}