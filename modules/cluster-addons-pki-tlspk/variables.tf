variable "vcp_namespace" {
  type        = string
  default     = "venafi"
  description = "Namespace where TLSPK addons are installed"
}

variable "vcp_cluster_name" {
  type        = string
  description = "Name of the cluster in Venafi Control Plane"
}

variable "vcp_api_url" {
  type        = string
  default     = ""
  description = "API Endpoint for the agent to send data to"
}

variable "vcp_private_registry" {
  type        = string
  default     = ""
  description = "Private registry URL for container images"
}

variable "vcp_public_registry" {
  type        = string
  default     = ""
  description = "Public registry URL for helm charts and public container images"
}

variable "vcp_oci_url" {
  type        = string
  default     = ""
  description = "OCI chart URL for helm charts"
}

variable "chart_versions" {
  type = map(string)
  default = {
    "cert-manager" : "v1.18.0",
    "venafi-connection" : "v0.4.0",
    "venafi-enhanced-issuer" : "v0.15.0",
    "venafi-kubernetes-agent" : "v1.5.0",
    "approver-policy-enterprise" : "v0.20.0"
  }
  description = "description"
}

# # TODO: reconsider this variable. May affect values passed in too. Stick with opinionated install for now.
# variable components {
#   type        = list(string)
#   default     = [
#     "cert-manager",
#     "venafi-connection",
#     "venafi-enhanced-issuer",
#     "venafi-kubernetes-agent",
#     "approver-policy-enterprise",
#   ]
#   description = "description"
# }
