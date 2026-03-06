resource "kubernetes_ingress_v1" "ecommerce" {
  metadata {
    name        = "ecommerce-ingress"
    namespace   = kubernetes_namespace.ecommerce.metadata[0].name
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
    }
  }
  spec {
    rule {
      host = "notification.local"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.notification.metadata[0].name
              port {
                number = 8082
              }
            }
          }
        }
      }
    }
    rule {
      host = "order.local"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.order.metadata[0].name
              port {
                number = 8083
              }
            }
          }
        }
      }
    }
    rule {
      host = "grafana.local"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.grafana.metadata[0].name
              port {
                number = 3000
              }
            }
          }
        }
      }
    }
    rule {
      host = "prometheus.local"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.prometheus.metadata[0].name
              port {
                number = 9090
              }
            }
          }
        }
      }
    }
    rule {
      host = "kafka.local"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.kafka_ui.metadata[0].name
              port {
                number = 8080
              }
            }
          }
        }
      }
    }

    rule {
      host = "gateway.local"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.gateway.metadata[0].name
              port {
                number = 8085
              }
            }
          }
        }
      }
    }
  }
}