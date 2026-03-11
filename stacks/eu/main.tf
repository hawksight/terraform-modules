# ------------------------------------------------------------------------- #
# --- 1) Create cluster environment
# ------------------------------------------------------------------------- #
module gke {
  source = "../../modules/gke"

  gcp_project = var.gcp_project
  gcp_region  = var.gcp_region
  gcp_zone    = var.gcp_zone
  gcp_cluster_name =  var.gcp_cluster_name
}

# Lookup here to use details for authentication
data "google_client_config" "default" {}

# ------------------------------------------------------------------------- #
# --- 2) Prepare all TLS Protect Cloud resources for cluster onboarding
# ------------------------------------------------------------------------- #
# Locals to toggle some reusable settings - leaving here but is within module too.
locals {
  private_registry_url = var.vcp_endpoints[lower(var.vcp_region)]["private_registry"]
  public_registry_url  = var.vcp_endpoints[lower(var.vcp_region)]["public_registry"]
  api_url              = "https://${var.vcp_endpoints[lower(var.vcp_region)]["api"]}"
  login_url            = "https://demons-eu.venafi.cloud"
  oci_chart_url        = "oci://${var.vcp_endpoints[lower(var.vcp_region)]["public_registry"]}/charts/"
  issuer_uri           = "https://container.googleapis.com/v1/projects/${var.gcp_project}/locations/${var.gcp_region}/clusters/${var.gcp_cluster_name}"
  jwks_uri             = "https://container.googleapis.com/v1/projects/${var.gcp_project}/locations/${var.gcp_region}/clusters/${var.gcp_cluster_name}/jwks"
}

module "tlspk" {
  source = "../../modules/tlspk"

  vcp_cluster_name     = var.vcp_cluster_name
  vcp_team_name        = var.vcp_team_name
  vcp_team_owner_email = var.vcp_team_owner_email
  vcp_api_key          = var.vcp_api_key
  vcp_tenant_id        = var.vcp_tenant_id
  vcp_region           = var.vcp_region
  vcp_issuing_policies = var.vcp_issuing_policies

  cluster_issuer_uri = local.issuer_uri
  cluster_jwks_uri   = local.jwks_uri
}

# ------------------------------------------------------------------------- #
# --- 3) Use those TLSPC resources by configuring all in cluster components
# ------------------------------------------------------------------------- #

# Configure VenafiClusterIssuer + VenafiConnection for issuance & discovery (agent).
# NOTE: See all component installation helm in helm-component-installs.tf.
# NOTE: This chart "venafi-config" is not currently public
# NOTE: Replace this section with YAML configuration or your own chart as needed
resource "helm_release" "tlspk-config" {
  name      = "tlspc-cluster-issuer"
  namespace = var.vcp_namespace
  chart     = var.helm_chart_venafi_config
  # version    = "0.1.0"
  set {
    name  = "fullnameOverride"
    value = "tlspc-cluster-issuer"
  }
  set {
    name  = "venafi.tenantId"
    value = var.vcp_tenant_id
  }
  set {
    name  = "venafi.controlPlane"
    value = "cloud"
  }
  set {
    name  = "venafi.url"
    value = local.api_url
  }
  # NOTE: Four (4) backslashes (\) are required to get one (1) \ required to divide application & policy
  # Terraform escapes each one resulting in two (2) in the input.
  # Of the two (2), one escapes the other resulting in one (1) in the final configuration.
  # --- Example ---- #
  # Venafi Connection Name:       tlspc-cluster-issuer
  # Zone:                         tiger-response-tlspk\tlspk or tiger-response-tlspk\\Default
  # --- End Example ---- #
  set {
    name  = "issuer.zone"
    # VCP Application \ Issuing Policy
    # TODO: change tlspk to be a variable
    value = "${var.vcp_team_name}-tlspk\\\\Default"
  }
  set {
    name  = "connection.jwt.audiences[0]"
    value = local.api_url
  }
  set {
    name  = "certificateRequestPolicy.create"
    value = "true"
  }
  set {
    name  = "agent.create"
    value = "true"
  }
  set {
    name  = "agent.serviceAccount.name"
    value = "venafi-components"
  }
  set {
    name  = "agent.url"
    value = local.api_url
  }
  # Small test certificate - Assumes using the built in Certificate Authority for VCP.
  set {
    name  = "test.certificate.enabled"
    value = true
  }
  set_list {
    name = "test.certificate.dnsNames"
    value = [
      "tlspc-cluster-issuer.example.test"
    ]
  }
  depends_on = [
    helm_release.venafi-enhanced-issuer,
    helm_release.approver-policy-enterprise,
    helm_release.venafi-agent,
    module.tlspk,
    module.gke
  ]
}

# ------------------------------------------------------------------------- #
# --- 4) Configure FireFly resources
# ------------------------------------------------------------------------- #

# module "firefly" {
#   source = "../../modules/firefly"

#   vcp_existing_team    = false
#   vcp_team_name        = var.vcp_team_name
#   vcp_team_owner_email = var.vcp_team_owner_email

#   depends_on = [module.tlspk, module.gke]
# }
