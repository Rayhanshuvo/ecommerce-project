resource "kubernetes_namespace" "ecommerce" {
  metadata {
    name = "ecommerce"
  }
}