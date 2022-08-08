# confluent_platform

Deploy the Confluent Platform components connected with an AWS MSK cluster over PLAINTEXT. The Confluent Components are configured with TSL.

## Assumptions

This example assumes you have a Kubernetes cluster running locally on Docker Desktop. Please see [Docker's official documentation](https://docs.docker.com/desktop/kubernetes/) for more information.

## Prerequisites

Release the [Confluent Operator example](https://github.com/aidanmelen/terraform-kubernetes-confluent-platform/tree/main/examples/confluent_operator). This will ensure the CFK CRDs are created and the Confluent Operator pod is running in the `confluent` namespace before releasing the Confluent Platform.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Example

```hcl
module "confluent_platform" {
  source    = "../../../"
  namespace = var.namespace

  # Kafka and Zookeeper are managed by AWS MSK
  create_zookeeper = false
  create_kafka     = false

  create_controlcenter = var.create_controlcenter

  connect = yamldecode(<<-EOF
    spec:
      tls:
        autoGeneratedCerts: true
      dependencies:
        kafka:
          bootstrapEndpoint: ${data.aws_msk_cluster.msk.bootstrap_brokers}
    EOF
  )

  ksqldb = yamldecode(<<-EOF
    spec:
      tls:
        autoGeneratedCerts: true
      dependencies:
        kafka:
          bootstrapEndpoint: ${data.aws_msk_cluster.msk.bootstrap_brokers}
    EOF
  )

  controlcenter = yamldecode(<<-EOF
    spec:
      tls:
        autoGeneratedCerts: true
      dependencies:
        kafka:
          bootstrapEndpoint: ${data.aws_msk_cluster.msk.bootstrap_brokers}
        schemaRegistry:
          url: https://schemaregistry.${var.namespace}.svc.cluster.local:8081
          tls:
            enabled: true
        ksqldb:
        - name: ksql-dev
          url: https://ksqldb.${var.namespace}.svc.cluster.local:8088
          tls:
            enabled: true
        connect:
        - name: connect-dev
          url:  https://connect.${var.namespace}.svc.cluster.local:8083
          tls:
            enabled: true
    EOF
  )

  schemaregistry = yamldecode(<<-EOF
    spec:
      tls:
        autoGeneratedCerts: true
      dependencies:
        kafka:
          bootstrapEndpoint: ${data.aws_msk_cluster.msk.bootstrap_brokers}
    EOF
  )

  kafkarestproxy = yamldecode(<<-EOF
    spec:
      tls:
        autoGeneratedCerts: true
      dependencies:
        kafka:
          bootstrapEndpoint: ${data.aws_msk_cluster.msk.bootstrap_brokers}
        schemaRegistry:
          url: https://schemaregistry.${var.namespace}.svc.cluster.local:8081
          tls:
            enabled: true
    EOF
  )
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