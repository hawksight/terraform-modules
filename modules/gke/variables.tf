variable "gcp_project" {
  type        = string
  default     = "jetstack-peter-fiddes"
  description = "GCP Account Name"
}

variable "gcp_region" {
  type        = string
  default     = "europe-west1"
  description = "Region to use for GCP resources"
}

variable "gcp_zone" {
  type        = string
  default     = "europe-west1-c"
  description = "Zone for GCP resources"
}

variable "gcp_cluster_name" {
  type        = string
  default     = "example-autopilot-cluster"
  description = "GKE cluster name in GCP"
}
