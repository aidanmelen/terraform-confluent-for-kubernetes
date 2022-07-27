# Confluent for Kuberentes CRDs

NOT IMPLEMENTED as of 07/26/2022
Please see this [feature request](https://github.com/hashicorp/terraform-provider-helm/pull/795) for more information.

Install only the CRDs from the Confluent Helm chart.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14.8 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.0.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.12.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | >= 2.0.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.12.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [kubernetes_manifest.crds](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_namespace_v1.namespace](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace_v1) | resource |
| [helm_template.confluent_for_kubernetes](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/data-sources/template) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_chart"></a> [chart](#input\_chart) | Chart name to be installed. The chart name can be local path, a URL to a chart, or the name of the chart if `repository` is specified. It is also possible to use the `<repository>/<chart>` format here if you are running Terraform on a system that the repository has been added to with `helm repo add` but this is not recommended. | `string` | `"confluent-for-kubernetes"` | no |
| <a name="input_chart_version"></a> [chart\_version](#input\_chart\_version) | Specify the exact chart version to install. If this is not specified, the latest version is installed. | `string` | `null` | no |
| <a name="input_create_namespace"></a> [create\_namespace](#input\_create\_namespace) | Create the namespace if it does not yet exist. | `bool` | `false` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | The namespace to release the Confluent Operator and Confluent Platform into. | `string` | `"confluent"` | no |
| <a name="input_namespace_annotations"></a> [namespace\_annotations](#input\_namespace\_annotations) | The namespace annotations. | `any` | `null` | no |
| <a name="input_namespace_labels"></a> [namespace\_labels](#input\_namespace\_labels) | The namespace labels. | `any` | `null` | no |
| <a name="input_repository"></a> [repository](#input\_repository) | Repository URL where to locate the requested chart. | `string` | `"https://packages.confluent.io/helm"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_confluent_for_kubernetes_crds"></a> [confluent\_for\_kubernetes\_crds](#output\_confluent\_for\_kubernetes\_crds) | The Confluent for Kubernetes CRDs (YAML). |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->