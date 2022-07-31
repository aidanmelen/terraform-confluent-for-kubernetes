module "confluent_platform" {
  source = "../../"

  namespace = var.namespace

  confluent_operator = {
    create_namespace = true
    name             = "confluent-operator"
    chart_version    = "0.517.12"
  }

  zookeeper = {
    "spec" = {
      "replicas" = "3"
    }
  }

  kafka = {
    "spec" = {
      "replicas" = "3"
    }
  }

  create_connect        = false
  create_ksqldb         = false
  create_controlcenter  = false
  create_schemaregistry = false
  create_kafkarestproxy = false

  kafka_topics = {
    "my-topic"       = {}
    "my-other-topic" = { "spec" = { "configs" = { "cleanup.policy" = "compact" } } }
  }
}
