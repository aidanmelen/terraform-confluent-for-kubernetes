module "confluent_operator" {
  source  = "aidanmelen/confluent-platform/kubernetes//modules/confluent_operator"
  version = ">= 0.3.0"

  create_namespace = true
  namespace        = "confluent"
  name             = "confluent-operator"
  chart_version    = "0.517.12"
}
