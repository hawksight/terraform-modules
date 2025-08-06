output firefly_id {
  value       = tlspc_service_account.firefly.id
  sensitive   = false
  description = "The ID of the Firefly service account to use in helm"
  depends_on  = [tlspc_service_account.firefly]
}
