resource "kubernetes_namespace" "tlspk" {
  count = var.create_namespace ? 1 : 0
  metadata {
    name = var.vcp_namespace
  }
}

resource "helm_release" "venafi-connection" {
  # count = contains(var.components, "venafi-connection") ? 1 : 0
  name       = "venafi-connection"
  namespace  = var.vcp_namespace
  repository = var.vcp_oci_url
  chart      = "venafi-connection"
  version    = var.chart_versions["venafi-connection"]

  timeout = 200
}

resource "helm_release" "approver-policy-enterprise" {
  # count = contains(var.components, "approver-policy-enterprise") ? 1 : 0
  name       = "approver-policy-enterprise"
  namespace  = var.vcp_namespace
  repository = var.vcp_oci_url
  chart      = "approver-policy-enterprise"
  version    = var.chart_versions["approver-policy-enterprise"]

  # venctl values
  set {
    name  = "cert-manager-approver-policy.imagePullSecrets[0].name"
    value = var.vcp_image_pull_secret
  }
  set_list {
    name = "cert-manager-approver-policy.app.approveSignerNames"
    value = [
      "issuers.cert-manager.io/*",
      "clusterissuers.cert-manager.io/*",
      "venaficlusterissuers.jetstack.io/*",
      "venafiissuers.jetstack.io/*",
      "firefly.venafi.com/*",
    ]
  }

  # venctl set
  set {
    name  = "venafiConnection.include"
    value = false
  }
  set {
    name  = "cert-manager-approver-policy.image.repository"
    value = "${var.vcp_private_registry}/venafi-approver-policy/approver-policy-enterprise"
  }

  depends_on = [helm_release.venafi-connection, helm_release.cert-manager]

  timeout = 200
}

# TODO: Add trust-manager back into the mix
# resource "helm_release" "trust-manager" {
#   name       = "trust-manager"
#   namespace  = var.vcp_namespace
#   repository = "oci://registry.venafi.cloud/charts/"
#   chart      = "trust-manager"
#   version    = "v0.13.0"

#   # venctl values
#   set {
#     name  = "imagePullSecrets[0].name"
#     value = var.vcp_image_pull_secret
#   }

#   # venctl set
#   set {
#     name  = "app.trust.namespace"
#     value = var.vcp_namespace
#   }
#   set {
#     name  = "app.webhook.tls.approverPolicy.enabled"
#     value = true
#   }
#   set {
#     name  = "app.webhook.tls.approverPolicy.certManagerNamespace"
#     value = var.vcp_namespace
#   }
#   set {
#     name  = "defaultPackageImage.repository"
#     value = "${var.vcp_private_registry}/trust-manager/cert-manager-package-debian"
#   }
#   set {
#     name  = "image.repository"
#     value = "${var.vcp_private_registry}/trust-manager/trust-manager"
#   }
#   depends_on = [helm_release.approver-policy-enterprise, helm_release.cert-manager]
# }

resource "helm_release" "cert-manager" {
  # count = contains(var.components, "cert-manager") ? 1 : 0
  name       = "cert-manager"
  namespace  = var.vcp_namespace
  repository = var.vcp_oci_url
  chart      = "cert-manager"
  version    = var.chart_versions["cert-manager"]

  # venctl values
  set {
    name  = "global.imagePullSecrets[0].name"
    value = var.vcp_image_pull_secret
  }
  set {
    name  = "disableAutoApproval"
    value = true
  }

  # venctl "set"
  set {
    name  = "crds.enabled"
    value = true
  }
  set {
    name  = "global.leaderElection.namespace"
    value = var.vcp_namespace
  }
  set {
    name  = "acmesolver.image.repository"
    value = "${var.vcp_private_registry}/cert-manager/cert-manager-acmesolver"
  }
  set {
    name  = "cainjector.image.repository"
    value = "${var.vcp_private_registry}/cert-manager/cert-manager-cainjector"
  }
  set {
    name  = "image.repository"
    value = "${var.vcp_private_registry}/cert-manager/cert-manager-controller"
  }
  set {
    name  = "startupapicheck.image.repository"
    value = "${var.vcp_private_registry}/cert-manager/cert-manager-startupapicheck"
  }
  set {
    name  = "webhook.image.repository"
    value = "${var.vcp_private_registry}/cert-manager/cert-manager-webhook"
  }

  timeout = 200
  # Doing this ensures cert-manager API is operational before continuing.
  wait_for_jobs = true
}

resource "helm_release" "venafi-enhanced-issuer" {
  # count = contains(var.components, "venafi-enhanced-issuer") ? 1 : 0
  name       = "venafi-enhanced-issuer"
  namespace  = var.vcp_namespace
  repository = var.vcp_oci_url
  chart      = "venafi-enhanced-issuer"
  version    = var.chart_versions["venafi-enhanced-issuer"]

  set {
    name  = "global.imagePullSecrets[0].name"
    value = var.vcp_image_pull_secret
  }
  set {
    name  = "venafiConnection.include"
    value = "false"
  }
  set {
    name  = "venafiEnhancedIssuer.manager.image.repository"
    value = "${var.vcp_private_registry}/venafi-issuer/venafi-enhanced-issuer"
  }
  # TODO: Implement this option in chart
  # set {
  #   name  = ""
  #   value = "--zap-log-level=debug"
  # }
  depends_on = [helm_release.venafi-connection, helm_release.cert-manager]

  timeout = 200
}

resource "helm_release" "venafi-agent" {
  # count = contains(var.components, "venafi-kubernetes-agent") ? 1 : 0
  name       = "venafi-kubernetes-agent"
  namespace  = var.vcp_namespace
  repository = var.vcp_oci_url
  chart      = "venafi-kubernetes-agent"
  version    = var.chart_versions["venafi-kubernetes-agent"]
  set {
    name  = "config.clusterName"
    value = var.vcp_cluster_name
  }
  set {
    name  = "config.clusterDescription"
    value = "Terraform auto installed with svc-account: ${var.vcp_cluster_name}-agent"
  }
  # From venctl values files
  set {
    name  = "authentication.venafiConnection.enabled"
    value = true
  }
  set {
    name  = "config.server"
    value = var.vcp_api_url
  }
  set {
    name  = "image.repository"
    value = "${var.vcp_private_registry}/venafi-agent/venafi-agent"
  }
  set {
    name  = "imagePullSecrets[0].name"
    value = var.vcp_image_pull_secret
  }
  set {
    name  = "podDisruptionBudget.enabled"
    value = true
  }
  dependency_update = true

  timeout = 200
}
