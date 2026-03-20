# locals {
#   name = value
# }

// Lookup the team owner to get ID for later
data "tlspc_user" "firefly_team_owner" {
  email = var.vcp_team_owner_email
}

// TODO - already have team, do I need another? https://github.com/jetstack/terraform-provider-tlspc/issues/87
resource "tlspc_team" "firefly_team" {
  name   = "${var.vcp_team_name}-${var.vcp_firefly_name}"
  role   = "PLATFORM_ADMIN"
  owners = [data.tlspc_user.firefly_team_owner.id]
}

// TODO - remove this when Firefly supports JWTs
resource "tls_private_key" "rsa-key" {
  count     = var.vcp_sa_public_key == "" ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

# WARNING: Probably requires admin API key to manage an issuance based service account
// Required because I am using JWT on the cluster service account.
resource "tlspc_service_account" "firefly" {
  # TODO: change to being the cluster name rather than team - see UI for example
  # Makes it consistent with tlspk module
  name                = "${var.vcp_team_name}-${var.vcp_firefly_name}-issuance"
  owner               = resource.tlspc_team.firefly_team.id
  scopes              = ["distributed-issuance"]
  credential_lifetime = 365
  public_key          = var.vcp_sa_public_key == "" ? trimspace(resource.tls_private_key.rsa-key[0].public_key_pem) : trimspace(var.vcp_sa_public_key)
}

# Put the Firefly issuance service account credential in cluster for firefly
resource "kubernetes_secret" "firefly-credentials" {
  metadata {
    name      = "${var.vcp_team_name}-${var.vcp_firefly_name}-issuance"
    namespace = var.vcp_namespace
  }
  data = {
    "svc-acct.key" = var.vcp_sa_private_key == "" ? trimspace(resource.tls_private_key.rsa-key[0].private_key_pem) : trimspace(var.vcp_sa_private_key)
  }
  type = "kubernetes.io/generic"

  depends_on = [tlspc_service_account.firefly]
}

resource "tlspc_firefly_policy" "policy" {
  name                = "${var.vcp_team_name}/${var.vcp_firefly_name}"
  extended_key_usages = ["ANY"]
  key_usages          = ["digitalSignature", "keyEncipherment"]
  validity_period     = "P30D"
  key_algorithm = {
    allowed_values = ["RSA_2048"]
    default_value  = "RSA_2048"
  }
  sans = {
    dns_names = {
      type            = "OPTIONAL"
      min_occurrences = 0
      max_occurrences = 1000
      allowed_values  = []
      default_values  = []
    }
    ip_addresses = {
      type            = "OPTIONAL"
      min_occurrences = 0
      max_occurrences = 1000
      allowed_values  = []
      default_values  = []
    }
    rfc822_names = {
      type            = "OPTIONAL"
      min_occurrences = 0
      max_occurrences = 1000
      allowed_values  = []
      default_values  = []
    }
    uris = {
      type            = "OPTIONAL"
      min_occurrences = 0
      max_occurrences = 1000
      allowed_values  = []
      default_values  = []
    }
  }
  subject = {
    country = {
      type            = "OPTIONAL"
      min_occurrences = 0
      max_occurrences = 1000
      allowed_values  = []
      default_values  = []
    }
    common_name = {
      type            = "OPTIONAL"
      min_occurrences = 0
      max_occurrences = 1000
      allowed_values  = []
      default_values  = []
    }
    locality = {
      type            = "OPTIONAL"
      min_occurrences = 0
      max_occurrences = 1000
      allowed_values  = []
      default_values  = []
    }
    organization = {
      type            = "OPTIONAL"
      min_occurrences = 0
      max_occurrences = 1000
      allowed_values  = []
      default_values  = []
    }
    organizational_unit = {
      type            = "OPTIONAL"
      min_occurrences = 0
      max_occurrences = 1000
      allowed_values  = []
      default_values  = []
    }
    state_or_province = {
      type            = "OPTIONAL"
      min_occurrences = 0
      max_occurrences = 1000
      allowed_values  = []
      default_values  = []
    }
  }
}

data "tlspc_ca_product" "built_in_ca" {
  type           = var.vcp_certificate_authority["type"]
  ca_name        = var.vcp_certificate_authority["ca_name"]
  product_option = var.vcp_certificate_authority["product_option"]
}

resource "tlspc_firefly_subca" "subca" {
  name                 = "${var.vcp_team_name}/${var.vcp_firefly_name}"
  ca_type              = data.tlspc_ca_product.built_in_ca.type
  ca_account_id        = data.tlspc_ca_product.built_in_ca.account_id
  ca_product_option_id = data.tlspc_ca_product.built_in_ca.id
  common_name          = "foobar"
  key_algorithm        = "RSA_2048"
  validity_period      = "P30D"
}

resource "tlspc_firefly_config" "config" {
  name             = "${var.vcp_team_name}/${var.vcp_firefly_name}"
  subca_provider   = resource.tlspc_firefly_subca.subca.id
  service_accounts = [resource.tlspc_service_account.firefly.id]
  policies         = [resource.tlspc_firefly_policy.policy.id]
}
