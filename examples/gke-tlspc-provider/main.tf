# ------------------------------------------------------------------------- #
# --- 1) Create cluster environment
# ------------------------------------------------------------------------- #
# GKE environment in gke.tf :)
# Lookup here to use details for authentication
data "google_client_config" "default" {}

# ------------------------------------------------------------------------- #
# --- 2) Prepare all TLS Protect Cloud resources for cluster onboarding
# ------------------------------------------------------------------------- #
# Locals to toggle some reusable settings
locals {
  private_registry_url = var.vcp_private_registry_url != "" ? var.vcp_private_registry_url : (var.vcp_endpoints[lower(var.vcp_region)]["private_registry"])
  public_registry_url  = var.vcp_public_registry_url != "" ? var.vcp_public_registry_url : (var.vcp_endpoints[lower(var.vcp_region)]["public_registry"])
  api_url              = var.vcp_api_endpoint != "" ? "https://${var.vcp_api_endpoint}" : ("https://${var.vcp_endpoints[lower(var.vcp_region)]["api"]}")
  issuer_uri           = "https://container.googleapis.com/v1/projects/${var.gcp_project}/locations/${var.gcp_region}/clusters/${var.gcp_cluster_name}"
  jwks_uri             = "https://container.googleapis.com/v1/projects/${var.gcp_project}/locations/${var.gcp_region}/clusters/${var.gcp_cluster_name}/jwks"
}

# We must lookup the owner in order to use the id attribute in team creation.
# Therefore this user must exist in TLS Protect Cloud for this to work.
data "tlspc_user" "team_owner" {
  email = var.vcp_team_owner_email
}

# We create a team here which is owned by the user looked up above.
resource "tlspc_team" "team" {
  name = var.vcp_team_name
  role = "RESOURCE_OWNER"
  # role = "PLATFORM_ADMIN"
  owners = [data.tlspc_user.team_owner.id]
}

# The following three resources create an imagePullSecret in cluster in order
# to pull the Venafi Images from the relevant private registry.
resource "tlspc_registry_account" "oci" {
  name  = "${var.vcp_cluster_name}-oci"
  owner = resource.tlspc_team.team.id
  ## This assumes you have all these scopes accessible in your TLS Protect Cloud account.
  scopes = ["oci-registry-cm", "oci-registry-cm-vei", "oci-registry-cm-ape", "oci-registry-cm-os"]
  ## If not, you can use the following scopes instead:
  # scopes              = ["oci-registry-cm"]
  credential_lifetime = 365
}

# Before creating the secret we must ensure that the namespace exists.
resource "kubernetes_namespace" "tlspk" {
  metadata {
    name = var.vcp_namespace
  }
}

# Put the OCI service account credential in cluster for imagePullSecrets
resource "kubernetes_secret" "pull-credentials" {
  metadata {
    name      = "venafi-image-pull-secret"
    namespace = var.vcp_namespace
  }
  data = {
    ".dockerconfigjson" = jsonencode({ "auths" = { "${local.private_registry_url}" = { "auth" = base64encode("${resource.tlspc_registry_account.oci.oci_account_name}:${resource.tlspc_registry_account.oci.oci_registry_token}") } } })
  }
  type = "kubernetes.io/dockerconfigjson"

  depends_on = [tlspc_registry_account.oci]
}

# Next create an application so all certificates from this cluster are
# associate with this application. The application belongs to the team we
# created previously.
# NOTE: UUID for Issuing templates can be inspected from the browser.
resource "tlspc_application" "app" {
  name                = "${var.vcp_team_name}-tlspk"
  owners              = [{ type = "TEAM", owner = resource.tlspc_team.team.id }]
  ca_template_aliases = var.vcp_issuing_policies
}

# Another TLS Protect Cloud service account, this time for certificate issuance
resource "tlspc_service_account" "issuer" {
  name         = "${var.vcp_cluster_name}-issuance"
  owner        = resource.tlspc_team.team.id
  scopes       = ["certificate-issuance"]
  applications = [resource.tlspc_application.app.id]
  jwks_uri     = local.jwks_uri
  issuer_url   = local.issuer_uri
  subject      = "system:serviceaccount:${var.vcp_namespace}:tlspc-cluster-issuer"
  audience     = local.api_url

  lifecycle {
    ignore_changes        = [credential_lifetime]
    create_before_destroy = false
  }
  depends_on = [resource.tlspc_application.app, resource.tlspc_team.team]
}

# Another TLS Protect Cloud service account, this time for agent discovery.
resource "tlspc_service_account" "agent" {
  name         = "${var.vcp_cluster_name}-agent"
  owner        = resource.tlspc_team.team.id
  scopes       = ["kubernetes-discovery-federated"]
  applications = [resource.tlspc_application.app.id]
  jwks_uri     = local.jwks_uri
  issuer_url   = local.issuer_uri
  subject      = "system:serviceaccount:${var.vcp_namespace}:venafi-components"
  audience     = "vcp"

  lifecycle {
    ignore_changes        = [credential_lifetime]
    create_before_destroy = false
  }
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
  # Zone:                         tiger-response-tlspk\tlspk
  # --- End Example ---- #
  set {
    name  = "issuer.zone"
    value = "${var.vcp_team_name}-tlspk\\\\tlspk"
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
    kubernetes_secret.pull-credentials
    # tlspc_service_account.agent,
    # tlspc_service_account.issuer
  ]
}

# ------------------------------------------------------------------------- #
# --- 4) Configure FireFly resources
# ------------------------------------------------------------------------- #

module firefly {
  source = "../../modules/firefly"

  vcp_existing_team	= false
  vcp_team_name	= var.vcp_team_name
  vcp_team_owner_email = var.vcp_team_owner_email
}
