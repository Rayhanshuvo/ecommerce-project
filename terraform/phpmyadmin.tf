resource "kubernetes_deployment" "phpmyadmin" {
  metadata {
    name      = "phpmyadmin"
    namespace = kubernetes_namespace.ecommerce.metadata[0].name
  }
  spec {
    replicas = 1
    selector {
      match_labels = { app = "phpmyadmin" }
    }
    template {
      metadata {
        labels = { app = "phpmyadmin" }
      }
      spec {
        container {
          name  = "phpmyadmin"
          image = "phpmyadmin/phpmyadmin:latest"
          env {
            name  = "PMA_HOST"
            value = "mysql-container"
          }
          env {
            name  = "PMA_PORT"
            value = "3306"
          }
          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "phpmyadmin" {
  metadata {
    name      = "phpmyadmin"
    namespace = kubernetes_namespace.ecommerce.metadata[0].name
  }
  spec {
    selector = { app = "phpmyadmin" }
    type     = "LoadBalancer"
    port {
      port        = 8081
      target_port = 80
    }
  }
}