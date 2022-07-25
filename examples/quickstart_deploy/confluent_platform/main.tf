module "confluent_operator" {
  source                  = "../../../modules/confuent_operator"
  namespace               = var.namespace
  should_create_namespace = true
}

module "zookeeper" {
  source    = "../../../modules/zookeeper"
  namespace = module.confluent_operator.helm_release.namespace
}

module "kafka" {
  source    = "../../../modules/kafka"
  namespace = module.confluent_operator.helm_release.namespace
}

module "connect" {
  source    = "../../../modules/connect"
  namespace = module.confluent_operator.helm_release.namespace
}

module "ksqldb" {
  source    = "../../../modules/ksqldb"
  namespace = module.confluent_operator.helm_release.namespace
}

module "control_center" {
  source    = "../../../modules/control_center"
  namespace = module.confluent_operator.helm_release.namespace
}

module "schema_registry" {
  source    = "../../../modules/schema_registry"
  namespace = module.confluent_operator.helm_release.namespace
}

module "kafka_rest_proxy" {
  source    = "../../../modules/kafka_rest_proxy"
  namespace = module.confluent_operator.helm_release.namespace
}
