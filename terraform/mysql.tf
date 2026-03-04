resource "kubernetes_config_map" "mysql_init" {
  metadata {
    name      = "mysql-init"
    namespace = kubernetes_namespace.ecommerce.metadata[0].name
  }
  data = {
    "init.sql" = <<-EOT
      CREATE DATABASE IF NOT EXISTS notification;
      CREATE DATABASE IF NOT EXISTS order_db;
      CREATE USER IF NOT EXISTS 'app'@'%' IDENTIFIED BY 'app123';
      GRANT ALL PRIVILEGES ON notification.* TO 'app'@'%';
      GRANT ALL PRIVILEGES ON order_db.* TO 'app'@'%';
      FLUSH PRIVILEGES;
    EOT
  }
}

resource "kubernetes_deployment" "mysql" {
  metadata {
    name      = "mysql"
    namespace = kubernetes_namespace.ecommerce.metadata[0].name
  }
  spec {
    replicas = 1
    selector {
      match_labels = { app = "mysql" }
    }
    template {
      metadata {
        labels = { app = "mysql" }
      }
      spec {
        container {
          name  = "mysql"
          image = "mysql:8.0"
          env {
            name  = "MYSQL_ROOT_PASSWORD"
            value = "rootpassword"
          }
          port {
            container_port = 3306
          }
          volume_mount {
            name       = "mysql-data"
            mount_path = "/var/lib/mysql"
          }
          volume_mount {
            name       = "mysql-init"
            mount_path = "/docker-entrypoint-initdb.d"
          }
        }
        volume {
          name = "mysql-data"
          empty_dir {}
        }
        volume {
          name = "mysql-init"
          config_map {
            name = kubernetes_config_map.mysql_init.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "mysql" {
  metadata {
    name      = "mysql-container"
    namespace = kubernetes_namespace.ecommerce.metadata[0].name
  }
  spec {
    selector = { app = "mysql" }
    type     = "ClusterIP"
    port {
      port        = 3306
      target_port = 3306
    }
  }
}