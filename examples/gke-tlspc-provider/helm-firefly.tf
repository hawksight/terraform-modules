resource "helm_release" "firefly" {
  name       = "firefly"
  namespace  = var.vcp_namespace
  repository = "oci://${local.private_registry_url}/charts/"
  chart      = "firefly"
  version    = "v1.7.0"

  values = [templatefile("firefly-values.yaml", {
    CLIENT_ID   = module.firefly.firefly_id,
    API_URL     = local.api_url,
    NAMESPACE   = var.vcp_namespace,
    SECRET_NAME = "${var.vcp_team_name}-firefly-issuance"
  })]

  depends_on = [
    kubernetes_secret.pull-credentials,
    helm_release.approver-policy-enterprise,
    helm_release.cert-manager,
    helm_release.venafi-connection,
    module.firefly
  ]

  # upgrade_install = true
  timeout = 100
}