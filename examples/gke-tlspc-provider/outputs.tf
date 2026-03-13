
// An output for the gcloud auth to the GKE cluster:
// gcloud container clusters get-credentials example-autopilot-cluster --location europe-west1
output "gcp_cluster_auth_command" {
  value       = module.gke.gcp_cluster_auth_command
  sensitive   = false
  description = "Command to authenticate to the cluster for manual kubectl things"
  depends_on  = [module.gke]
}

output "vcp_private_registry" {
  value       = module.tlspk.vcp_private_registry
  sensitive   = false
  description = "The computed value for the private registry"
}

output "vcp_public_registry" {
  value       = module.tlspk.vcp_public_registry
  sensitive   = false
  description = "The computed value for the public registry"
}

output "vcp_api_url" {
  value       = module.tlspk.vcp_api_url
  sensitive   = false
  description = "The computed value for the SaaS API URL"
}
