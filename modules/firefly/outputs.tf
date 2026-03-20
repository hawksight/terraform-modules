output firefly_client_id {
  value       = tlspc_service_account.firefly.id
  sensitive   = false
  description = "The ID of the Firefly service account to use in helm"
  depends_on  = [tlspc_service_account.firefly]
}

output firefly_auth_secret {
  value       = kubernetes_secret.firefly-credentials.metadata[0].name
  sensitive   = false
  description = "Name of the Kubernetes secret with Firefly credentials"
  depends_on  = [kubernetes_secret.firefly-credentials]
}

