
// An output for the gcloud auth to the GKE cluster:
// gcloud container clusters get-credentials example-autopilot-cluster --location europe-west1
output "gcp_cluster_auth_command" {
  value       = module.gke.gcp_cluster_auth_command
  sensitive   = false
  description = "Command to authenticate to the cluster for manual kubectl things"
  depends_on  = [module.gke]
}
