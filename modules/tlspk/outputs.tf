output vcp_private_registry {
  value       = local.private_registry_url
  sensitive   = false
  description = "The computed value for the private registry"
}

output vcp_public_registry {
  value       = local.public_registry_url
  sensitive   = false
  description = "The computed value for the public registry"
}

output vcp_api_url {
  value       = local.api_url
  sensitive   = false
  description = "The computed value for the SaaS API URL"
}