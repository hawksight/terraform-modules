resource "kubernetes_namespace" "firefly" {
  count = var.create_namespace ? 1 : 0
  metadata {
    name = var.vcp_namespace
  }
}

resource "helm_release" "firefly" {
  name       = "firefly"
  namespace  = var.vcp_namespace
  repository = "oci://${var.vcp_public_registry}/charts/"
  chart      = "firefly"
  version    = var.chart_version

  values = [templatefile("${path.module}/firefly-values.yaml", {
    CLIENT_ID   = var.vcp_client_id,
    API_URL     = var.vcp_api_url,
    NAMESPACE   = var.vcp_namespace,
    SECRET_NAME = var.vcp_auth_secret,
  })]

  # upgrade_install = true
  timeout = 100
}