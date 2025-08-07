<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | 2.14.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | 2.32.0 |
| <a name="requirement_tlspc"></a> [tlspc](#requirement\_tlspc) | 0.4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.32.0 |
| <a name="provider_tlspc"></a> [tlspc](#provider\_tlspc) | 0.4.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [kubernetes_namespace.tlspk](https://registry.terraform.io/providers/hashicorp/kubernetes/2.32.0/docs/resources/namespace) | resource |
| [kubernetes_secret.pull-credentials](https://registry.terraform.io/providers/hashicorp/kubernetes/2.32.0/docs/resources/secret) | resource |
| [tlspc_application.app](https://registry.terraform.io/providers/jetstack/tlspc/0.4.0/docs/resources/application) | resource |
| [tlspc_registry_account.oci](https://registry.terraform.io/providers/jetstack/tlspc/0.4.0/docs/resources/registry_account) | resource |
| [tlspc_service_account.agent](https://registry.terraform.io/providers/jetstack/tlspc/0.4.0/docs/resources/service_account) | resource |
| [tlspc_service_account.issuer](https://registry.terraform.io/providers/jetstack/tlspc/0.4.0/docs/resources/service_account) | resource |
| [tlspc_team.team](https://registry.terraform.io/providers/jetstack/tlspc/0.4.0/docs/resources/team) | resource |
| [tlspc_user.team_owner](https://registry.terraform.io/providers/jetstack/tlspc/0.4.0/docs/data-sources/user) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_issuer_uri"></a> [cluster\_issuer\_uri](#input\_cluster\_issuer\_uri) | The cluster's issuer URI for token issuance | `string` | n/a | yes |
| <a name="input_cluster_jwks_uri"></a> [cluster\_jwks\_uri](#input\_cluster\_jwks\_uri) | The JWKS URI for the cluster to used to validate tokens | `string` | n/a | yes |
| <a name="input_helm_chart_venafi_config"></a> [helm\_chart\_venafi\_config](#input\_helm\_chart\_venafi\_config) | Local path to the configuration chart | `string` | `"/Users/peter.fiddes/projects/jetstack/venafi-config"` | no |
| <a name="input_vcp_api_endpoint"></a> [vcp\_api\_endpoint](#input\_vcp\_api\_endpoint) | Override for TLS Protect Cloud API Endpoint. If not set it is inferred by vcp\_region from vcp\_endpoints. | `string` | `""` | no |
| <a name="input_vcp_api_key"></a> [vcp\_api\_key](#input\_vcp\_api\_key) | Venafi Cloud API Key | `string` | n/a | yes |
| <a name="input_vcp_cluster_name"></a> [vcp\_cluster\_name](#input\_vcp\_cluster\_name) | Name of the cluster and service account for Venafi Control Planes | `string` | `"tiger-east-1"` | no |
| <a name="input_vcp_endpoints"></a> [vcp\_endpoints](#input\_vcp\_endpoints) | n/a | `map` | <pre>{<br/>  "au": {<br/>    "api": "api.au.venafi.cloud",<br/>    "private_registry": "private-registry.venafi.au",<br/>    "public_registry": "registry.venafi.cloud"<br/>  },<br/>  "ca": {<br/>    "api": "api.ca.venafi.cloud",<br/>    "private_registry": "private-registry.venafi.ca",<br/>    "public_registry": "registry.venafi.cloud"<br/>  },<br/>  "eu": {<br/>    "api": "api.venafi.eu",<br/>    "private_registry": "private-registry.venafi.eu",<br/>    "public_registry": "registry.venafi.cloud"<br/>  },<br/>  "si": {<br/>    "api": "api.si.venafi.cloud",<br/>    "private_registry": "private-registry.venafi.si",<br/>    "public_registry": "registry.venafi.cloud"<br/>  },<br/>  "uk": {<br/>    "api": "api.uk.venafi.cloud",<br/>    "private_registry": "private-registry.venafi.uk",<br/>    "public_registry": "registry.venafi.cloud"<br/>  },<br/>  "us": {<br/>    "api": "api.venafi.cloud",<br/>    "private_registry": "private-registry.venafi.cloud",<br/>    "public_registry": "registry.venafi.cloud"<br/>  }<br/>}</pre> | no |
| <a name="input_vcp_issuing_policies"></a> [vcp\_issuing\_policies](#input\_vcp\_issuing\_policies) | A map of CA aliases and associate IDs | `map(string)` | <pre>{<br/>  "alias": "UUID"<br/>}</pre> | no |
| <a name="input_vcp_namespace"></a> [vcp\_namespace](#input\_vcp\_namespace) | Namespace to install the Venafi Kubernetes Agent in cluster | `string` | `"venafi"` | no |
| <a name="input_vcp_private_registry_url"></a> [vcp\_private\_registry\_url](#input\_vcp\_private\_registry\_url) | Override for private registry images. If not set it is inferred by vcp\_region from vcp\_endpoints. | `string` | `""` | no |
| <a name="input_vcp_public_registry_url"></a> [vcp\_public\_registry\_url](#input\_vcp\_public\_registry\_url) | Override for public registry images. If not set it is inferred by vcp\_region from vcp\_endpoints. | `string` | `""` | no |
| <a name="input_vcp_region"></a> [vcp\_region](#input\_vcp\_region) | Sets the product region. Used to determine URLS | `string` | `"eu"` | no |
| <a name="input_vcp_team_name"></a> [vcp\_team\_name](#input\_vcp\_team\_name) | Input a VCP identity you would like to own the VCP Team | `string` | n/a | yes |
| <a name="input_vcp_team_owner_email"></a> [vcp\_team\_owner\_email](#input\_vcp\_team\_owner\_email) | Input an email for the VCP identity you would like to own the VCP Team created | `string` | n/a | yes |
| <a name="input_vcp_tenant_id"></a> [vcp\_tenant\_id](#input\_vcp\_tenant\_id) | UUID Unique to your VCP Tenant | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->