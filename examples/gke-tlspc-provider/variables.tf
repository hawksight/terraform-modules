
variable "vcp_cluster_name" {
  type        = string
  default     = "tiger-east-1"
  description = "Name of the cluster and service account for Venafi Control Planes"
}

variable "vcp_api_key" {
  type        = string
  sensitive   = true
  description = "Venafi API Key"
}

variable "vcp_tenant_id" {
  type        = string
  sensitive   = false
  description = "UUID Unique to your VCP Tenant"
}

variable "vcp_namespace" {
  type        = string
  default     = "venafi"
  description = "Namespace to install the Venafi Kubernetes Agent in cluster"
}

variable "vcp_team_owner_email" {
  type        = string
  description = "Input an email for the VCP identity you would like to own the VCP Team created"
}

variable "vcp_team_name" {
  type        = string
  description = "Input a VCP identity you would like to own the VCP Team"
}

variable "vcp_region" {
  type    = string
  default = "eu"
}

variable "vcp_api_endpoint" {
  type        = string
  default     = "https://api.venafi.cloud"
  description = "Venafi API Endpoint - different between US and EU regions"
}

variable "vcp_issuing_policies" {
  type = map(string)
  default = {
    "alias" = "UUID"
  }
  description = "A map of CA aliases and associate IDs"
}

## GKE Specifics
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

# Helm specific
# NOTE this is not a public chart at the moment.
# TODO: make public
variable "helm_chart_venafi_config" {
  type        = string
  default     = "/Users/peter.fiddes/projects/jetstack/venafi-config"
  description = "Local path to the configuration chart"
}
