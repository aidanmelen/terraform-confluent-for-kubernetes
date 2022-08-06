# production_secure_deploy_auto_gen_certs

Confluent recommends these security mechanisms for a production deployment:

- Enable Kafka client authentication. Choose one of:

  - SASL/Plain or mTLS

  - For SASL/Plain, the identity can come from LDAP server

- Enable Confluent Role Based Access Control for authorization, with user/group identity coming from LDAP server

- Enable TLS for network encryption - both internal (between CP components) and external (Clients to CP components)

In this deployment scenario, we'll choose SASL/Plain for authentication and configure TLS encryption using CFK auto-generated component certificates.
You'll need to provide a certificate authority certificate for CFK to auto-generate the component certificates.

This Terraforms [confluent-for-kubernetes-examples/security/production-secure-deploy-auto-gen-certs](https://github.com/confluentinc/confluent-kubernetes-examples/tree/master/security/production-secure-deploy-auto-gen-certs).

## Assumptions

This example assumes you have a Kubernetes cluster running locally on Docker Desktop. Please see [Docker's official documentation](https://docs.docker.com/desktop/kubernetes/) for more information.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Example

```hcl
module "confluent_platform" {
  source  = "aidanmelen/confluent-platform/kubernetes"
  version = ">= 0.9.0"

  namespace = var.namespace

  zookeeper = yamldecode(<<-EOF
    spec:
      authentication:
        type: digest
        jaasConfig:
          secretRef: credential
      tls:
        autoGeneratedCerts: true
    EOF
  )

  kafka = yamldecode(<<-EOF
    spec:
      configOverrides:
        server:
          - "log.file.size=${100 * 1024 * 1024}"
      tls:
        autoGeneratedCerts: true
      listeners:
        internal:
          authentication:
            type: plain
            jaasConfig:
              secretRef: credential
          tls:
            enabled: true
        external:
          authentication:
            type: plain
            jaasConfig:
              secretRef: credential
          externalAccess:
            type: loadBalancer
            loadBalancer:
              domain: my.domain
              brokerPrefix: rb
              bootstrapPrefix: rb
          tls:
            enabled: true
      authorization:
        type: rbac
        superUsers:
        - User:kafka
      services:
        mds:
          tls:
            enabled: true
          tokenKeyPair:
            secretRef: mds-token
          externalAccess:
            type: loadBalancer
            loadBalancer:
              domain: my.domain
              prefix: rb-mds
          provider:
            type: ldap
            ldap:
              address: ldap://ldap.${var.namespace}.svc.cluster.local:389
              authentication:
                type: simple
                simple:
                  secretRef: credential
              configurations:
                groupNameAttribute: cn
                groupObjectClass: group
                groupMemberAttribute: member
                groupMemberAttributePattern: CN=(.*),DC=test,DC=com
                groupSearchBase: dc=test,dc=com
                userNameAttribute: cn
                userMemberOfAttributePattern: CN=(.*),DC=test,DC=com
                userObjectClass: organizationalRole
                userSearchBase: dc=test,dc=com
      dependencies:
        kafkaRest:
          authentication:
            type: bearer
            bearer:
              secretRef: mds-client
        zookeeper:
          endpoint: zookeeper.${var.namespace}.svc.cluster.local:2182
          authentication:
            type: digest
            jaasConfig:
              secretRef: credential
          tls:
            enabled: true
    EOF
  )

  connect = yamldecode(<<-EOF
    spec:
      tls:
        autoGeneratedCerts: true
      externalAccess:
        type: loadBalancer
        loadBalancer:
          domain: my.domain
          prefix: rb-connect
      authorization:
        type: rbac
      dependencies:
        kafka:
          bootstrapEndpoint: kafka.${var.namespace}.svc.cluster.local:9071
          authentication:
            type: plain
            jaasConfig:
              secretRef: credential
          tls:
            enabled: true
        mds:
          endpoint: https://kafka.${var.namespace}.svc.cluster.local:8090
          tokenKeyPair:
            secretRef: mds-token
          authentication:
            type: bearer
            bearer:
              secretRef: connect-mds-client
          tls:
            enabled: true
    EOF
  )

  ksqldb = yamldecode(<<-EOF
    spec:
      tls:
        autoGeneratedCerts: true
      externalAccess:
        type: loadBalancer
        loadBalancer:
          domain: my.domain
          prefix: rb-sr
      authorization:
        type: rbac
      dependencies:
        kafka:
          bootstrapEndpoint: kafka.${var.namespace}.svc.cluster.local:9071
          authentication:
            type: plain
            jaasConfig:
              secretRef: credential
          tls:
            enabled: true
        mds:
          endpoint: https://kafka.${var.namespace}.svc.cluster.local:8090
          tokenKeyPair:
            secretRef: mds-token
          authentication:
            type: bearer
            bearer:
              secretRef: sr-mds-client
          tls:
            enabled: true
    EOF
  )

  controlcenter = yamldecode(<<-EOF
    spec:
      podTemplate:
        probe:
          liveness:
            periodSeconds: 10
            failureThreshold: 1
            timeoutSeconds: 5
      authorization:
        type: rbac
      tls:
        autoGeneratedCerts: true
      dependencies:
        kafka:
          bootstrapEndpoint: kafka.${var.namespace}.svc.cluster.local:9071
          authentication:
            type: plain
            jaasConfig:
              secretRef: credential
          tls:
            enabled: true
        mds:
          endpoint: https://kafka.${var.namespace}.svc.cluster.local:8090
          tokenKeyPair:
            secretRef: mds-token
          authentication:
            type: bearer
            bearer:
              secretRef: c3-mds-client
          tls:
            enabled: true
        connect:
          - name: connect
            url:  https://connect.${var.namespace}.svc.cluster.local:8083
            tls:
              enabled: true
        ksqldb:
          - name: ksqldb
            url:  https://ksqldb.${var.namespace}.svc.cluster.local:8088
            tls:
              enabled: true
        schemaRegistry:
          url: https://schemaregistry.${var.namespace}.svc.cluster.local:8081
          tls:
            enabled: true
    EOF
  )

  schemaregistry = yamldecode(<<-EOF
    spec:
    tls:
      autoGeneratedCerts: true
    externalAccess:
      type: loadBalancer
      loadBalancer:
        domain: my.domain
        prefix: rb-sr
    authorization:
      type: rbac
    dependencies:
      kafka:
        bootstrapEndpoint: kafka.${var.namespace}.svc.cluster.local:9071
        authentication:
          type: plain
          jaasConfig:
            secretRef: credential
        tls:
          enabled: true
      mds:
        endpoint: https://kafka.${var.namespace}.svc.cluster.local:8090
        tokenKeyPair:
          secretRef: mds-token
        authentication:
          type: bearer
          bearer:
            secretRef: sr-mds-client
        tls:
          enabled: true
    EOF
  )

  kafkarestproxy = yamldecode(<<-EOF
    spec:
      tls:
        autoGeneratedCerts: true
      externalAccess:
        type: loadBalancer
        loadBalancer:
          domain: my.domain
          prefix: rb-krp
      authorization:
        type: rbac
      dependencies:
        kafka:
          bootstrapEndpoint: kafka.${var.namespace}.svc.cluster.local:9071
          authentication:
            type: plain
            jaasConfig:
              secretRef: credential
          tls:
            enabled: true
        mds:
          endpoint: https://kafka.${var.namespace}.svc.cluster.local:8090
          tokenKeyPair:
            secretRef: mds-token
          authentication:
            type: bearer
            bearer:
              secretRef: krp-mds-client
          tls:
            enabled: true
        schemaRegistry:
          url: https://schemaregistry.${var.namespace}.svc.cluster.local:8081
          tls:
            enabled: true
    EOF
  )

  create_zookeeper      = false
  create_kafka          = false
  create_connect        = false
  create_ksqldb         = false
  create_controlcenter  = false
  create_schemaregistry = false
  create_kafkarestproxy = false

  # kafka_rest_classes = {
  #   "default" = {
  #     values = yamldecode(<<-EOF
  #       spec:
  #         kafkaRest:
  #           authentication:
  #             type: bearer
  #             bearer:
  #               secretRef: rest-credential
  #       EOF
  #     )
  #   }
  # }

  # kafka_topics = {
  #   "my-topic" = {
  #     values = yamldecode(<<-EOF
  #       spec:
  #         replicas: 1
  #         partitionCount: 1
  #         kafkaRest:
  #           authentication:
  #             type: bearer
  #             bearer:
  #               secretRef: rest-credential
  #         configs:
  #           cleanup.policy: "delete"
  #       EOF
  #     )
  #   }
  # }
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14.8 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.0.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.12.1 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | >= 4.0.1 |
## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_confluent_platform"></a> [confluent\_platform](#module\_confluent\_platform) | ../../ | n/a |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_namespace"></a> [namespace](#input\_namespace) | The namespace to release the Confluent Operator and Confluent Platform into. | `string` | `"confluent"` | no |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_connect"></a> [connect](#output\_connect) | The Connect object spec. |
| <a name="output_controlcenter"></a> [controlcenter](#output\_controlcenter) | The ControlCenter object spec. |
| <a name="output_kafka"></a> [kafka](#output\_kafka) | The Kafka object spec. |
| <a name="output_kafkarestproxy"></a> [kafkarestproxy](#output\_kafkarestproxy) | The KafkaRestProxy object spec. |
| <a name="output_ksqldb"></a> [ksqldb](#output\_ksqldb) | The KsqlDB object spec. |
| <a name="output_namespace"></a> [namespace](#output\_namespace) | The namespace for the Confluent Platform. |
| <a name="output_schemaregistry"></a> [schemaregistry](#output\_schemaregistry) | The SchemaRegistry object spec. |
| <a name="output_zookeeper"></a> [zookeeper](#output\_zookeeper) | The Zookeeper object spec. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->