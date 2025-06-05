resource "helm_release" "venafi-connection" {
  name       = "venafi-connection"
  namespace  = var.vcp_namespace
  repository = "oci://registry.venafi.cloud/charts/"
  chart      = "venafi-connection"
  version    = "v0.2.0"
  depends_on = [kubernetes_secret.pull-credentials]

  timeout = 200
}

resource "helm_release" "approver-policy-enterprise" {
  name       = "approver-policy-enterprise"
  namespace  = var.vcp_namespace
  repository = "oci://registry.venafi.cloud/charts/"
  chart      = "approver-policy-enterprise"
  version    = "v0.20.0"

  # venctl values
  set {
    name  = "cert-manager-approver-policy.imagePullSecrets[0].name"
    value = "venafi-image-pull-secret"
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
    value = "${local.private_registry_url}/venafi-approver-policy/approver-policy-enterprise"
  }

  depends_on = [helm_release.venafi-connection, helm_release.cert-manager]

  timeout = 200
}

# resource "helm_release" "trust-manager" {
#   name       = "trust-manager"
#   namespace  = var.vcp_namespace
#   repository = "oci://registry.venafi.cloud/charts/"
#   chart      = "trust-manager"
#   version    = "v0.13.0"

#   # venctl values
#   set {
#     name  = "imagePullSecrets[0].name"
#     value = "venafi-image-pull-secret"
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
#     value = "${local.private_registry_url}/trust-manager/cert-manager-package-debian"
#   }
#   set {
#     name  = "image.repository"
#     value = "${local.private_registry_url}/trust-manager/trust-manager"
#   }
#   depends_on = [helm_release.approver-policy-enterprise, helm_release.cert-manager]
# }

resource "helm_release" "cert-manager" {
  name       = "cert-manager"
  namespace  = var.vcp_namespace
  repository = "oci://registry.venafi.cloud/charts/"
  chart      = "cert-manager"
  version    = "v1.17.1"

  # venctl values
  set {
    name  = "global.imagePullSecrets[0].name"
    value = "venafi-image-pull-secret"
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
    value = "${local.private_registry_url}/cert-manager/cert-manager-acmesolver"
  }
  set {
    name  = "cainjector.image.repository"
    value = "${local.private_registry_url}/cert-manager/cert-manager-cainjector"
  }
  set {
    name  = "image.repository"
    value = "${local.private_registry_url}/cert-manager/cert-manager-controller"
  }
  set {
    name  = "startupapicheck.image.repository"
    value = "${local.private_registry_url}/cert-manager/cert-manager-startupapicheck"
  }
  set {
    name  = "webhook.image.repository"
    value = "${local.private_registry_url}/cert-manager/cert-manager-webhook"
  }

  timeout = 200
}

resource "helm_release" "venafi-enhanced-issuer" {
  name       = "venafi-enhanced-issuer"
  namespace  = var.vcp_namespace
  repository = "oci://registry.venafi.cloud/charts/"
  chart      = "venafi-enhanced-issuer"
  version    = "v0.15.0"

  set {
    name  = "global.imagePullSecrets[0].name"
    value = "venafi-image-pull-secret"
  }
  set {
    name  = "venafiConnection.include"
    value = "false"
  }
  set {
    name  = "venafiEnhancedIssuer.manager.image.repository"
    value = "${local.private_registry_url}/venafi-issuer/venafi-enhanced-issuer"
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
  name       = "venafi-kubernetes-agent"
  namespace  = var.vcp_namespace
  repository = "oci://registry.venafi.cloud/charts/"
  chart      = "venafi-kubernetes-agent"
  version    = "1.4.0"
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
    value = local.api_url
  }
  set {
    name  = "image.repository"
    value = "${local.private_registry_url}/venafi-agent/venafi-agent"
  }
  set {
    name  = "imagePullSecrets[0].name"
    value = "venafi-image-pull-secret"
  }
  set {
    name  = "podDisruptionBudget.enabled"
    value = true
  }
  dependency_update = true

  timeout = 200
}
