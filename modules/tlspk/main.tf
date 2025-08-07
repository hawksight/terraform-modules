# Locals to toggle some reusable settings
locals {
  private_registry_url = var.vcp_private_registry_url != "" ? var.vcp_private_registry_url : (var.vcp_endpoints[lower(var.vcp_region)]["private_registry"])
  public_registry_url  = var.vcp_public_registry_url != "" ? var.vcp_public_registry_url : (var.vcp_endpoints[lower(var.vcp_region)]["public_registry"])
  api_url              = var.vcp_api_endpoint != "" ? "https://${var.vcp_api_endpoint}" : ("https://${var.vcp_endpoints[lower(var.vcp_region)]["api"]}")
  # TODO: remove these later and just use vars directly.
  issuer_uri           = var.cluster_issuer_uri # "https://container.googleapis.com/v1/projects/${var.gcp_project}/locations/${var.gcp_region}/clusters/${var.gcp_cluster_name}"
  jwks_uri             = var.cluster_jwks_uri  # "https://container.googleapis.com/v1/projects/${var.gcp_project}/locations/${var.gcp_region}/clusters/${var.gcp_cluster_name}/jwks"
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
  # TODO: Add PSP baseline annotations
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
  # TODO: replace tlspc-cluster-issuer with a variable for SA name
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
  # Using venafi-components just because it is a default in the venafi-kubernetes-agent
  # See here: https://github.com/jetstack/jetstack-secure/blob/master/deploy/charts/venafi-kubernetes-agent/values.yaml#L212
  subject      = "system:serviceaccount:${var.vcp_namespace}:venafi-components"
  audience     = "vcp"

  lifecycle {
    ignore_changes        = [credential_lifetime]
    create_before_destroy = false
  }
}