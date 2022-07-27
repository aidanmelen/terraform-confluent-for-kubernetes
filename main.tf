#####################################################################################################################
# Confluent for Kubernetes Manifests Defaults
# https://github.com/confluentinc/confluent-kubernetes-examples/blob/master/quickstart-deploy/confluent-platform.yaml
#####################################################################################################################
locals {
  namespace = var.create_namespace ? kubernetes_namespace_v1.namespace[0].metadata[0].name : var.namespace

  default_zookeeper = yamldecode(
    <<EOF
apiVersion: platform.confluent.io/v1beta1
kind: Zookeeper
metadata:
  name: zookeeper
  namespace: ${local.namespace}
spec:
  replicas: 3
  image:
    application: confluentinc/cp-zookeeper:${local.latest_confluent_platform_version_compatibility}
    init: confluentinc/confluent-init-container:${local.cfk_app_version}
  dataVolumeCapacity: 10Gi
  logVolumeCapacity: 10Gi
  EOF
  )

  default_kafka = yamldecode(
    <<EOF
apiVersion: platform.confluent.io/v1beta1
kind: Kafka
metadata:
  name: kafka
  namespace: ${local.namespace}
spec:
  replicas: 3
  image:
    application: confluentinc/cp-server:${local.latest_confluent_platform_version_compatibility}
    init: confluentinc/confluent-init-container:${local.cfk_app_version}
  dataVolumeCapacity: 10Gi
  metricReporter:
    enabled: true
  EOF
  )

  default_connect = yamldecode(
    <<EOF
apiVersion: platform.confluent.io/v1beta1
kind: Connect
metadata:
  name: connect
  namespace: ${local.namespace}
spec:
  replicas: 1
  image:
    application: confluentinc/cp-server-connect:${local.latest_confluent_platform_version_compatibility}
    init: confluentinc/confluent-init-container:${local.cfk_app_version}
  dependencies:
    kafka:
      bootstrapEndpoint: kafka:9071
  EOF
  )

  default_ksqldb = yamldecode(
    <<EOF
apiVersion: platform.confluent.io/v1beta1
kind: KsqlDB
metadata:
  name: ksqldb
  namespace: ${local.namespace}
spec:
  replicas: 1
  image:
    application: confluentinc/cp-ksqldb-server:${local.latest_confluent_platform_version_compatibility}
    init: confluentinc/confluent-init-container:${local.cfk_app_version}
  dataVolumeCapacity: 10Gi
  EOF
  )

  default_controlcenter = yamldecode(
    <<EOF
apiVersion: platform.confluent.io/v1beta1
kind: ControlCenter
metadata:
  name: controlcenter
  namespace: ${local.namespace}
spec:
  replicas: 1
  image:
    application: confluentinc/cp-enterprise-control-center:${local.latest_confluent_platform_version_compatibility}
    init: confluentinc/confluent-init-container:${local.cfk_app_version}
  dataVolumeCapacity: 10Gi
  dependencies:
    schemaRegistry:
      url: http://schemaregistry.confluent.svc.cluster.local:8081
    ksqldb:
    - name: ksqldb
      url: http://ksqldb.confluent.svc.cluster.local:8088
    connect:
    - name: connect
      url: http://connect.confluent.svc.cluster.local:8083
  EOF
  )

  default_schemaregistry = yamldecode(
    <<EOF
apiVersion: platform.confluent.io/v1beta1
kind: SchemaRegistry
metadata:
  name: schemaregistry
  namespace: ${local.namespace}
spec:
  replicas: 3
  image:
    application: confluentinc/cp-schema-registry:${local.latest_confluent_platform_version_compatibility}
    init: confluentinc/confluent-init-container:${local.cfk_app_version}
  EOF
  )

  default_kafkarestproxy = yamldecode(
    <<EOF
apiVersion: platform.confluent.io/v1beta1
kind: KafkaRestProxy
metadata:
  name: kafkarestproxy
  namespace: ${local.namespace}
spec:
  replicas: 1
  image:
    application: confluentinc/cp-kafka-rest:${local.latest_confluent_platform_version_compatibility}
    init: confluentinc/confluent-init-container:${local.cfk_app_version}
  dependencies:
    schemaRegistry:
      url: http://schemaregistry.confluent.svc.cluster.local:8081
  EOF
  )
}

##############################################
# Confluent for Kubernetes Manifests Overrides
##############################################
module "zookeeper" {
  source = "Invicton-Labs/deepmerge/null"
  count  = var.create_zookeeper ? 1 : 0
  maps = [
    local.default_zookeeper,
    var.zookeeper != null ? var.zookeeper : {}
  ]
}

module "kafka" {
  source = "Invicton-Labs/deepmerge/null"
  count  = var.create_kafka ? 1 : 0
  maps = [
    local.default_kafka,
    var.kafka != null ? var.kafka : {}
  ]
}

module "connect" {
  source = "Invicton-Labs/deepmerge/null"
  count  = var.create_connect ? 1 : 0
  maps = [
    local.default_connect,
    var.connect != null ? var.connect : {}
  ]
}

module "ksqldb" {
  source = "Invicton-Labs/deepmerge/null"
  count  = var.create_ksqldb ? 1 : 0
  maps = [
    local.default_ksqldb,
    var.ksqldb != null ? var.ksqldb : {}
  ]
}

module "controlcenter" {
  source = "Invicton-Labs/deepmerge/null"
  count  = var.create_controlcenter ? 1 : 0
  maps = [
    local.default_controlcenter,
    var.controlcenter != null ? var.controlcenter : {}
  ]
}

module "schemaregistry" {
  source = "Invicton-Labs/deepmerge/null"
  count  = var.create_schemaregistry ? 1 : 0
  maps = [
    local.default_schemaregistry,
    var.schemaregistry != null ? var.schemaregistry : {}
  ]
}

module "kafkarestproxy" {
  count  = var.create_kafkarestproxy ? 1 : 0
  source = "Invicton-Labs/deepmerge/null"
  maps = [
    local.default_kafkarestproxy,
    var.kafkarestproxy != null ? var.kafkarestproxy : {}
  ]
}

######################
# Kubernetes Manifests
######################
resource "kubernetes_manifest" "zookeeper" {
  count           = var.create_zookeeper ? 1 : 0
  computed_fields = ["metadata.finalizers"]
  manifest        = module.zookeeper[0].merged

  wait {
    fields = {
      "status.phase" = "RUNNING"
    }
  }

  timeouts {
    create = "1h"
    update = "1h"
    delete = "5m"
  }
}

resource "kubernetes_manifest" "kafka" {
  count           = var.create_kafka ? 1 : 0
  computed_fields = ["metadata.finalizers"]
  manifest        = module.kafka[0].merged

  wait {
    fields = {
      "status.phase" = "RUNNING"
    }
  }

  timeouts {
    create = "1h"
    update = "1h"
    delete = "5m"
  }
}

resource "kubernetes_manifest" "connect" {
  count           = var.create_connect ? 1 : 0
  computed_fields = ["metadata.finalizers"]
  manifest        = module.connect[0].merged

  wait {
    fields = {
      "status.phase" = "RUNNING"
    }
  }

  timeouts {
    create = "1h"
    update = "1h"
    delete = "5m"
  }
}

resource "kubernetes_manifest" "ksqldb" {
  count           = var.create_ksqldb ? 1 : 0
  computed_fields = ["metadata.finalizers"]
  manifest        = module.ksqldb[0].merged

  wait {
    fields = {
      "status.phase" = "RUNNING"
    }
  }

  timeouts {
    create = "1h"
    update = "1h"
    delete = "5m"
  }
}

resource "kubernetes_manifest" "controlcenter" {
  count           = var.create_controlcenter ? 1 : 0
  computed_fields = ["metadata.finalizers"]
  manifest        = module.controlcenter[0].merged

  wait {
    fields = {
      "status.phase" = "RUNNING"
    }
  }

  timeouts {
    create = "1h"
    update = "1h"
    delete = "5m"
  }
}

resource "kubernetes_manifest" "schemaregistry" {
  count           = var.create_schemaregistry ? 1 : 0
  computed_fields = ["metadata.finalizers"]
  manifest        = module.schemaregistry[0].merged

  wait {
    fields = {
      "status.phase" = "RUNNING"
    }
  }

  timeouts {
    create = "1h"
    update = "1h"
    delete = "5m"
  }
}

resource "kubernetes_manifest" "kafkarestproxy" {
  count           = var.create_kafkarestproxy ? 1 : 0
  computed_fields = ["metadata.finalizers"]
  manifest        = module.kafkarestproxy[0].merged

  wait {
    fields = {
      "status.phase" = "RUNNING"
    }
  }

  timeouts {
    create = "1h"
    update = "1h"
    delete = "5m"
  }
}
