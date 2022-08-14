# confluent_platform_iam_secure

Deploy the Confluent Platform components connected with an AWS MSK cluster over TLS. Authenticate and Authorize with IAM. Please see [aws-msk-iam-auth](https://github.com/aws/aws-msk-iam-auth) for more information.

## Prerequisites

Run Terraform in the `../aws` directory.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Example

```hcl
resource "kubernetes_service_account_v1" "aws_msk_full_access" {
  metadata {
    name      = "aws-msk-full-access"
    namespace = var.namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = data.aws_iam_role.aws_msk_full_access.arn
    }
  }
}

module "confluent_platform" {
  source    = "../../../"
  namespace = var.namespace

  # The Confluent Operator was release in ../aws/confluent_operator.tf
  confluent_operator = {
    create = false
  }

  # Both Kafka and Zookeeper were created with AWS MSK in ../aws/main.tf
  create_zookeeper = false
  create_kafka     = false

  # TODO implement aws msk iam auth for the following components
  create_controlcenter  = false
  create_ksqldb         = false
  create_schemaregistry = false
  kafkarestproxy        = false

  connect = yamldecode(<<-EOF
    spec:
      image:
        application: aidanmelen/cp-server-connect-with-aws-msk-iam-auth:${var.confluent_platform_version}
      tls:
        autoGeneratedCerts: true
      configOverrides:
        server:
          # Sets up TLS for encryption and SASL for authN.
          - "security.protocol = SASL_SSL"

          # Identifies the SASL mechanism to use.
          - "sasl.mechanism = AWS_MSK_IAM"

          # Binds SASL client implementation.
          = "sasl.jaas.config = software.amazon.msk.auth.iam.IAMLoginModule required;"

          # Encapsulates constructing a SigV4 signature based on extracted credentials.
          # The SASL client bound by "sasl.jaas.config" invokes this class.
          - "sasl.client.callback.handler.class = software.amazon.msk.auth.iam.IAMClientCallbackHandler"
      podTemplate:
        envVars:
          - name: CLASSPATH
            value: /usr/share/java/aws-msk-iam-auth-1.1.4-all.jar
        securityContext:
          serviceAccountName: ${kubernetes_service_account_v1.aws_msk_full_access.metadata[0].name}
      dependencies:
        kafka:
          bootstrapEndpoint: ${data.aws_msk_cluster.msk.bootstrap_brokers_tls}
    EOF
  )

  # ksqldb = yamldecode(<<-EOF
  #   spec:
  #     # https://docs.confluent.io/operator/current/co-troubleshooting.html#issue-ksqldb-cannot-use-auto-generated-certificates-for-ccloud
  #     # tls:
  #     #   autoGeneratedCerts: true
  #     configOverrides:
  #       server:
  #         - "security.protocol=SSL"
  #     dependencies:
  #       kafka:
  #         bootstrapEndpoint: ${data.aws_msk_cluster.msk.bootstrap_brokers_tls}
  #   EOF
  # )

  # controlcenter = yamldecode(<<-EOF
  #   spec:
  #     tls:
  #       autoGeneratedCerts: true
  #     configOverrides:
  #       server:
  #         - "security.protocol=SSL"
  #     dependencies:
  #       kafka:
  #         bootstrapEndpoint: ${data.aws_msk_cluster.msk.bootstrap_brokers_tls}
  #       schemaRegistry:
  #         url: https://schemaregistry.${var.namespace}.svc.cluster.local:8081
  #         tls:
  #           enabled: true
  #       ksqldb:
  #       - name: ksql-dev
  #         url: http://ksqldb.${var.namespace}.svc.cluster.local:8088
  #         tls:
  #           enabled: true
  #       connect:
  #       - name: connect-dev
  #         url:  https://connect.${var.namespace}.svc.cluster.local:8083
  #         tls:
  #           enabled: true
  #   EOF
  # )

  # schemaregistry = yamldecode(<<-EOF
  #   spec:
  #     configOverrides:
  #       server:
  #         - "security.protocol=SSL"
  #     tls:
  #       autoGeneratedCerts: true
  #     dependencies:
  #       kafka:
  #         bootstrapEndpoint: ${data.aws_msk_cluster.msk.bootstrap_brokers_tls}
  #   EOF
  # )

  # kafkarestproxy = yamldecode(<<-EOF
  #   spec:
  #     configOverrides:
  #       server:
  #         - "security.protocol=SSL"
  #     tls:
  #       autoGeneratedCerts: true
  #     dependencies:
  #       kafka:
  #         bootstrapEndpoint: ${data.aws_msk_cluster.msk.bootstrap_brokers_tls}
  #       schemaRegistry:
  #         url: https://schemaregistry.${var.namespace}.svc.cluster.local:8081
  #         tls:
  #           enabled: true
  #   EOF
  # )
}

resource "kubernetes_service_account_v1" "aws_msk_full_access" {
  metadata {
    name      = "aws-msk-full-access"
    namespace = module.confluent_platform.namespace
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14.8 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.72 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.0.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.12.1 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | >= 4.0.1 |
## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_confluent_platform"></a> [confluent\_platform](#module\_confluent\_platform) | ../../../ | n/a |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | The AWS region name. | `string` | `"us-west-2"` | no |
| <a name="input_create_controlcenter"></a> [create\_controlcenter](#input\_create\_controlcenter) | Controls if the ControlCenter component of the Confluent Platform should be created. | `bool` | `true` | no |
| <a name="input_name"></a> [name](#input\_name) | The project name. | `string` | `"hybrid-aws-msk"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | The namespace to release the Confluent Operator and Confluent Platform into. | `string` | `"confluent"` | no |
## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->