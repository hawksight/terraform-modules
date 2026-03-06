// An output for the gcloud auth to the GKE cluster:
// gcloud container clusters get-credentials example-autopilot-cluster --location europe-west1
output "gcp_cluster_auth_command" {
  value       = "gcloud container clusters get-credentials ${google_container_cluster.default.name} --location ${google_container_cluster.default.location}"
  sensitive   = false
  description = "Command to authenticate to the cluster for manual kubectl things"
  depends_on  = [google_container_cluster.default]
}

output cluster_certificate {
  value       = google_container_cluster.default.master_auth[0].cluster_ca_certificate
  sensitive   = false
  description = "Certificate for authentication to the cluster. Required for k8s provider."
  depends_on  = []
}

output cluster_endpoint {
  value       = google_container_cluster.default.endpoint
  sensitive   = false
  description = "Cluster default endpoint to autheticate to. Required for k8s provider."
  depends_on  = []
}
