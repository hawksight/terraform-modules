# Terraform TLS Protect for Kubernetes Foundation

A Terraform native installation of the Venafi TLS Protect for Kubernetes (TLSPK) in a GKE Autopilot environment.

**PLEASE NOTE:**

- This uses a newly released [jetstack/tlspc](https://registry.terraform.io/providers/jetstack/tlspc/latest) terraform provider.
- This uses a custom helm chart in the final step that is not yet released. This can be replaced with YAML following the Venafi documentation:
  - Agent WIF: https://docs.venafi.cloud/vaas/k8s-components/t-install-tlspk-agent/#connecting-a-cluster-using-workload-identity-federation
  - Or Agent Key Pair: https://docs.venafi.cloud/vaas/k8s-components/t-install-tlspk-agent/#to-connect-a-cluster-using-key-pair-authentication
  - Issuance: https://docs.venafi.cloud/vaas/k8s-components/t-cfg-vc-satoken/
  - Approval: https://docs.venafi.cloud/vaas/k8s-components/c-cfg-ape/

**STATUS:** Demo Only - No Official Support.

> Please speak to yur Venafi representatives for official support using this open source integration with Venafi TLS Protect Cloud.

## Setup

First setup your `inputs.tfvars` using the [inputs.tfvars.tpl](./inputs.tfvars.tpl) as an example.

```sh
export VCP_TENANT_NAME="demons-eu"
cp inputs.tfvars.tpl $VCP_TENANT_NAME-inputs.tfvars
```

Now edit your specific inputs file: `$VCP_TENANT_NAME-inputs.tfvars`.
Only once you are happy that all the inputs now use your project & tenant specific values, continue.
Two files have been provided as examples for EU and US region tenants of Venafi Control Plane:

- US - [jetstack-us-inputs.tfvars](./jetstack-us-inputs.tfvars)
- EU - [demons-eu-inputs](./demons-eu-inputs.tfvars)

Create a symlink from your values to `inputs.tfvars` as shown:

```sh
if [ -h "inputs.tfvars" ] ; then rm ./inputs.tfvars ; else echo "No inputs.tfvars symlink, creating ..."; fi
ln -s $VCP_TENANT_NAME-inputs.tfvars inputs.tfvars
```

Export your Venafi TLS Protect Cloud (TLSPC) API key in order to use the terraform:

```sh
export TF_VAR_vcp_api_key="$(echo -n \"$(cat ~/.keys/venafi/tlspc/$VCP_TENANT_NAME/platform-api-key.txt)\")"
```

**PLEASE NOTE:** Only a [Platform Administrator](https://docs.venafi.cloud/vaas/user-management/about-user-roles/) role should be required to run the provider currently. This may change dependant on the resources created, refer to the provider or Venafi Documentation on permissions.

Now you can execute the plan and apply:

```sh
tofu plan -var-file=inputs.tfvars -refresh -out plan
tofu apply plan
```

Connect to your clusters using the output:

```sh
$(tofu output -raw gcp_cluster_auth_command)
```

## Cleanup

### Full destroy

```sh
tofu plan -var-file=inputs.tfvars -refresh -out plan -destroy
tofu apply plan
```

### Partial cleanup - leave cluster

For speed of not waiting on cluster provisioning (approx 10 -15 mins in my experience) we may wish to only remove the helm & TLS Protect Cloud resources from said cluster.
In terraform this is hard with having to explicitly include all resource in the target plan.

```sh
tofu plan -var-file=inputs.tfvars -refresh -out plan -destroy \
  -target=tlspc_team.team \
  -target=tlspc_registry_account.oci \
  -target=kubernetes_namespace.tlspk \
  -target=kubernetes_secret.pull-credentials \
  -target=tlspc_application.app \
  -target=tlspc_service_account.issuer \
  -target=tlspc_service_account.agent \
  -target=helm_release.tlspk-config \
  -target=helm_release.venafi-agent \
  -target=helm_release.venafi-enhanced-issuer \
  -target=helm_release.cert-manager \
  -target=helm_release.trust-manager \
  -target=helm_release.approver-policy-enterprise \
  -target=helm_release.venafi-connection \
  -target=data.tlspc_user.team_owner
tofu apply plan

# Cleanup cluster CRDs - get
k get crd -l 'app.kubernetes.io/instance in (venafi-enhanced-issuer, venafi-connection, cert-manager, approver-policy-enterprise, trust-manager)'

# Delete
k delete crd -l 'app.kubernetes.io/instance in (venafi-enhanced-issuer, venafi-connection, cert-manager, approver-policy-enterprise, trust-manager)'
```

Finally you must manually delete the cluster from TLSPC under "Installations > Kubernetes Clusters".

### Partial cleanup - leave cluster & helm base installs

For speed of not waiting on cluster provisioning (approx 10 -15 mins in my experience) or helm installations in an autoscaling cluster, we may wish to only remove the actual TLSPK Configuration from the cluster & TLS Protect Cloud resources.
This requires some specific targeting of resources as follows:

```sh
tofu plan -var-file=inputs.tfvars -refresh -out plan -destroy \
  -target=tlspc_team.team \
  -target=tlspc_registry_account.oci \
  -target=kubernetes_secret.pull-credentials \
  -target=tlspc_application.app \
  -target=tlspc_service_account.issuer \
  -target=tlspc_service_account.agent \
  -target=helm_release.tlspk-config \
  -target=data.tlspc_user.team_owner

tofu apply plan
```

Finally you must manually delete the cluster from TLSPC under "Installations > Kubernetes Clusters".
