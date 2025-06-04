
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
  type        = string
  default     = "eu"
  description = "Sets the product region. Used to determine URLS"
}

variable "vcp_endpoints" {
  default = {
    "us" : {
      "private_registry" : "private-registry.venafi.cloud",
      "public_registry" : "registry.venafi.cloud",
      "api" : "api.venafi.cloud"
    },
    "eu" : {
      "private_registry" : "private-registry.venafi.eu",
      "public_registry" : "registry.venafi.cloud",
      "api" : "api.venafi.eu"
    },
    "uk" : {
      "private_registry" : "private-registry.venafi.uk",
      "public_registry" : "registry.venafi.cloud",
      "api" : "api.uk.venafi.cloud"
    },
    "ca" : {
      "private_registry" : "private-registry.venafi.ca",
      "public_registry" : "registry.venafi.cloud",
      "api" : "api.ca.venafi.cloud"
    },
    "si" : {
      "private_registry" : "private-registry.venafi.si",
      "public_registry" : "registry.venafi.cloud",
      "api" : "api.si.venafi.cloud"
    },
    "au" : {
      "private_registry" : "private-registry.venafi.au",
      "public_registry" : "registry.venafi.cloud",
      "api" : "api.au.venafi.cloud"
    }
  }
}

variable "vcp_api_endpoint" {
  type        = string
  default     = ""
  description = "Override for TLS Protect Cloud API Endpoint. If not set it is inferred by vcp_region from vcp_endpoints."
}

variable "vcp_private_registry_url" {
  type        = string
  default     = ""
  description = "Override for private registry images. If not set it is inferred by vcp_region from vcp_endpoints."
}

variable "vcp_public_registry_url" {
  type        = string
  default     = ""
  description = "Override for public registry images. If not set it is inferred by vcp_region from vcp_endpoints."
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

# variable "gcp_enable_autopilot" {
#   type        = bool
#   default     = false
#   description = "Option to enable autopilot. Do not enable if using CyberArk Firefly as it does not run in autopilot clusters currently."
# }

# Helm specific
# NOTE this is not a public chart at the moment.
# TODO: make public
variable "helm_chart_venafi_config" {
  type        = string
  default     = "/Users/peter.fiddes/projects/jetstack/venafi-config"
  description = "Local path to the configuration chart"
}
