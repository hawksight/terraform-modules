# CyberArk Certificate Manager Cloud Firefly Issuance

**STATUS:** WIP

Creates a CyberArk Certificate Manager Cloud Firefly installation and deploys it to a Kubernetes cluster.

## To Do

- [ ] Lookup existing team, depends on https://github.com/jetstack/terraform-provider-tlspc/issues/87
- [ ] Test

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
| <a name="provider_tls"></a> [tls](#provider\_tls) | n/a |
| <a name="provider_tlspc"></a> [tlspc](#provider\_tlspc) | 0.4.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [kubernetes_secret.firefly-credentials](https://registry.terraform.io/providers/hashicorp/kubernetes/2.32.0/docs/resources/secret) | resource |
| [tls_private_key.rsa-key](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [tlspc_firefly_config.config](https://registry.terraform.io/providers/jetstack/tlspc/0.4.0/docs/resources/firefly_config) | resource |
| [tlspc_firefly_policy.policy](https://registry.terraform.io/providers/jetstack/tlspc/0.4.0/docs/resources/firefly_policy) | resource |
| [tlspc_firefly_subca.subca](https://registry.terraform.io/providers/jetstack/tlspc/0.4.0/docs/resources/firefly_subca) | resource |
| [tlspc_service_account.firefly](https://registry.terraform.io/providers/jetstack/tlspc/0.4.0/docs/resources/service_account) | resource |
| [tlspc_team.firefly_team](https://registry.terraform.io/providers/jetstack/tlspc/0.4.0/docs/resources/team) | resource |
| [tlspc_ca_product.built_in_ca](https://registry.terraform.io/providers/jetstack/tlspc/0.4.0/docs/data-sources/ca_product) | data source |
| [tlspc_user.firefly_team_owner](https://registry.terraform.io/providers/jetstack/tlspc/0.4.0/docs/data-sources/user) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_vcp_certificate_authority"></a> [vcp\_certificate\_authority](#input\_vcp\_certificate\_authority) | Set the Certifiate Authority properties from wich the subca will issue | `map(string)` | <pre>{<br/>  "ca_name": "Built-In CA",<br/>  "product_option": "Default Product",<br/>  "type": "BUILTIN"<br/>}</pre> | no |
| <a name="input_vcp_existing_team"></a> [vcp\_existing\_team](#input\_vcp\_existing\_team) | Set to true if the team name already exists to prevent an additional team being created | `bool` | `false` | no |
| <a name="input_vcp_firefly_name"></a> [vcp\_firefly\_name](#input\_vcp\_firefly\_name) | String name for the firefly installation | `string` | `"firefly"` | no |
| <a name="input_vcp_namespace"></a> [vcp\_namespace](#input\_vcp\_namespace) | Set the installation namespace of the firefly in cluster resource dependencies | `string` | `"venafi"` | no |
| <a name="input_vcp_sa_private_key"></a> [vcp\_sa\_private\_key](#input\_vcp\_sa\_private\_key) | Optionally provide a pubprivate key for the service account, else one is generated on your behalf. See here for more details: https://docs.venafi.cloud/firefly/service-accounts/ | `string` | `""` | no |
| <a name="input_vcp_sa_public_key"></a> [vcp\_sa\_public\_key](#input\_vcp\_sa\_public\_key) | Optionally provide a public key for the service account, else one is generated on your behalf. See here for more details: https://docs.venafi.cloud/firefly/service-accounts/ | `string` | `""` | no |
| <a name="input_vcp_team_name"></a> [vcp\_team\_name](#input\_vcp\_team\_name) | Provide a name to the team owning this firefly installation | `string` | n/a | yes |
| <a name="input_vcp_team_owner_email"></a> [vcp\_team\_owner\_email](#input\_vcp\_team\_owner\_email) | Input an email for the VCP identity you would like to own the VCP Team created | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_firefly_id"></a> [firefly\_id](#output\_firefly\_id) | The ID of the Firefly service account to use in helm |
<!-- END_TF_DOCS -->