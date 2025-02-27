# Venafi Service Account

**STATUS:** Deprecated in current form.

> Please refer to [Jetstack/tlspc](https://registry.terraform.io/providers/jetstack/tlspc/latest) for a native solution.

Creates a Venafi Control Plane (VCP) service account via some hacks and prepare a given cluster for the installation of the Venafi Kubernetes Agent.

## To Do

- [ ] Replace the provisioner code with [native service_account](https://registry.terraform.io/providers/jetstack/tlspc/latest/docs/resources/service_account)
- [ ] Remove check scripts once above working.
- [ ] Add ability to switch between key pair and workload identity federation

If all the above can be done, then this module may be reinstated.
For now, see [provider](https://registry.terraform.io/providers/jetstack/tlspc/latest).

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_external"></a> [external](#requirement\_external) | 2.3.4 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | 2.32.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | 4.0.5 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_external"></a> [external](#provider\_external) | 2.3.4 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.32.0 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 4.0.5 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [kubernetes_namespace.agent](https://registry.terraform.io/providers/hashicorp/kubernetes/2.32.0/docs/resources/namespace) | resource |
| [kubernetes_secret.credentials](https://registry.terraform.io/providers/hashicorp/kubernetes/2.32.0/docs/resources/secret) | resource |
| [terraform_data.tlspc](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [tls_private_key.agent](https://registry.terraform.io/providers/hashicorp/tls/4.0.5/docs/resources/private_key) | resource |
| [external_external.uuid_check](https://registry.terraform.io/providers/hashicorp/external/2.3.4/docs/data-sources/external) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_vcp_api_key"></a> [vcp\_api\_key](#input\_vcp\_api\_key) | Venafi API Key | `string` | n/a | yes |
| <a name="input_vcp_cluster_name"></a> [vcp\_cluster\_name](#input\_vcp\_cluster\_name) | Venafi Cluster & Service Account friendly name | `string` | n/a | yes |
| <a name="input_vcp_namespace"></a> [vcp\_namespace](#input\_vcp\_namespace) | The namespace where the agent is deployed | `string` | `"venafi"` | no |
| <a name="input_vcp_team_id"></a> [vcp\_team\_id](#input\_vcp\_team\_id) | Venafi Team UID | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_svc_account_client_id"></a> [svc\_account\_client\_id](#output\_svc\_account\_client\_id) | The clientId field from the service account after creation |
| <a name="output_svc_account_private_key"></a> [svc\_account\_private\_key](#output\_svc\_account\_private\_key) | Private key for the service account |
| <a name="output_svc_account_public_key"></a> [svc\_account\_public\_key](#output\_svc\_account\_public\_key) | Public key for the service account |
