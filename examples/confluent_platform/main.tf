module "confluent_platform" {
  source    = "aidanmelen/confluent-platform/kubernetes"
  version   = ">= 0.3.0"
  namespace = "confluent"

  /*
  zookeeper      = { ... }
  kafka          = { ... }
  connect        = { ... }
  ksqldb         = { ... }
  controlcenter  = { ... }
  schemaregistry = { ... }
  kafkarestproxy = { ... }
  */
}
