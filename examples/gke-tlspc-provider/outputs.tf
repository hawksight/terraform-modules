
// An output for the gcloud auth to the GKE cluster:
// gcloud container clusters get-credentials example-autopilot-cluster --location europe-west1
output "gcp_cluster_auth_command" {
  value       = "gcloud container clusters get-credentials ${google_container_cluster.default.name} --location ${google_container_cluster.default.location}"
  sensitive   = false
  description = "Command to authenticate to the cluster for manual kubectl things"
  depends_on  = [google_container_cluster.default]
}
