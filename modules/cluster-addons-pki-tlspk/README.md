<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.approver-policy-enterprise](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.cert-manager](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.venafi-agent](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.venafi-connection](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.venafi-enhanced-issuer](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_chart_versions"></a> [chart\_versions](#input\_chart\_versions) | description | `map(string)` | <pre>{<br/>  "approver-policy-enterprise": "v0.20.0",<br/>  "cert-manager": "v1.18.0",<br/>  "venafi-connection": "v0.4.0",<br/>  "venafi-enhanced-issuer": "v0.15.0",<br/>  "venafi-kubernetes-agent": "v1.5.0"<br/>}</pre> | no |
| <a name="input_vcp_api_url"></a> [vcp\_api\_url](#input\_vcp\_api\_url) | API Endpoint for the agent to send data to | `string` | `""` | no |
| <a name="input_vcp_cluster_name"></a> [vcp\_cluster\_name](#input\_vcp\_cluster\_name) | Name of the cluster in Venafi Control Plane | `string` | n/a | yes |
| <a name="input_vcp_namespace"></a> [vcp\_namespace](#input\_vcp\_namespace) | Namespace where TLSPK addons are installed | `string` | `"venafi"` | no |
| <a name="input_vcp_oci_url"></a> [vcp\_oci\_url](#input\_vcp\_oci\_url) | OCI chart URL for helm charts | `string` | `""` | no |
| <a name="input_vcp_private_registry"></a> [vcp\_private\_registry](#input\_vcp\_private\_registry) | Private registry URL for container images | `string` | `""` | no |
| <a name="input_vcp_public_registry"></a> [vcp\_public\_registry](#input\_vcp\_public\_registry) | Public registry URL for helm charts and public container images | `string` | `""` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->