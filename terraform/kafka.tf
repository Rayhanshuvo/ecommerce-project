resource "kubernetes_persistent_volume_claim" "kafka_data" {
  metadata {
    name      = "kafka-data-pvc"
    namespace = kubernetes_namespace.ecommerce.metadata[0].name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "2Gi"
      }
    }
  }
}

resource "kubernetes_deployment" "kafka" {
  metadata {
    name      = "kafka"
    namespace = kubernetes_namespace.ecommerce.metadata[0].name
  }
  spec {
    replicas = 1
    selector {
      match_labels = { app = "kafka" }
    }
    template {
      metadata {
        labels = { app = "kafka" }
      }
      spec {
        security_context {
          fs_group = 1000
        }

        init_container {
          name    = "wipe-kafka-data"
          image   = "busybox:1.36"
          command = ["sh", "-c", "rm -rf /var/lib/kafka/data/* || true; chown -R 1000:1000 /var/lib/kafka/data || true"]
          volume_mount {
            name       = "kafka-data"
            mount_path = "/var/lib/kafka/data"
          }
        }

        container {
          name              = "kafka"
          image             = "apache/kafka:3.8.1"
          image_pull_policy = "IfNotPresent"

          port {
            name           = "broker"
            container_port = 9092
          }
          port {
            name           = "controller"
            container_port = 9093
          }

          env {
            name  = "KAFKA_NODE_ID"
            value = "1"
          }
          env {
            name  = "KAFKA_PROCESS_ROLES"
            value = "broker,controller"
          }
          env {
            name  = "KAFKA_LISTENERS"
            value = "PLAINTEXT://0.0.0.0:9092,CONTROLLER://0.0.0.0:9093"
          }
          env {
            name  = "KAFKA_ADVERTISED_LISTENERS"
            value = "PLAINTEXT://kafka:9092"
          }
          env {
            name  = "KAFKA_LISTENER_SECURITY_PROTOCOL_MAP"
            value = "CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT"
          }
          env {
            name  = "KAFKA_CONTROLLER_LISTENER_NAMES"
            value = "CONTROLLER"
          }
          env {
            name  = "KAFKA_INTER_BROKER_LISTENER_NAME"
            value = "PLAINTEXT"
          }
          env {
            name  = "KAFKA_CONTROLLER_QUORUM_VOTERS"
            value = "1@localhost:9093"
          }
          env {
            name  = "KAFKA_LOG_DIRS"
            value = "/var/lib/kafka/data"
          }
          env {
            name  = "KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR"
            value = "1"
          }
          env {
            name  = "KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR"
            value = "1"
          }
          env {
            name  = "KAFKA_TRANSACTION_STATE_LOG_MIN_ISR"
            value = "1"
          }
          env {
            name  = "KAFKA_MIN_INSYNC_REPLICAS"
            value = "1"
          }
          env {
            name  = "KAFKA_AUTO_CREATE_TOPICS_ENABLE"
            value = "true"
          }
          env {
            name  = "KAFKA_NUM_PARTITIONS"
            value = "1"
          }
          env {
            name  = "CLUSTER_ID"
            value = "5L6g3nShT-eMCtK--X86sw"
          }

          readiness_probe {
            tcp_socket {
              port = "9092"
            }
            initial_delay_seconds = 20
            period_seconds        = 10
            timeout_seconds       = 2
            failure_threshold     = 6
          }

          liveness_probe {
            tcp_socket {
              port = "9092"
            }
            initial_delay_seconds = 60
            period_seconds        = 20
            timeout_seconds       = 2
            failure_threshold     = 6
          }

          resources {
            requests = {
              cpu    = "250m"
              memory = "512Mi"
            }
            limits = {
              cpu    = "1"
              memory = "1Gi"
            }
          }

          volume_mount {
            name       = "kafka-data"
            mount_path = "/var/lib/kafka/data"
          }
        }

        volume {
          name = "kafka-data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.kafka_data.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "kafka" {
  metadata {
    name      = "kafka"
    namespace = kubernetes_namespace.ecommerce.metadata[0].name
  }
  spec {
    selector = { app = "kafka" }
    type     = "ClusterIP"
    port {
      name        = "broker"
      port        = 9092
      target_port = 9092
    }
  }
}