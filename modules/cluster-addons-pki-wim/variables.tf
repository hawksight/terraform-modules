variable create_namespace {
  type        = bool
  default     = false
  description = "Decide if namespace needs creating, off by default"
}

variable "vcp_namespace" {
  type        = string
  default     = "venafi"
  description = "Namespace where TLSPK addons are installed"
}

variable "vcp_cluster_name" {
  type        = string
  description = "Name of the cluster in Venafi Control Plane"
}

variable vcp_client_id {
  type        = string
  description = "Service account ID from the Venafi Control Plane"
}

variable "vcp_api_url" {
  type        = string
  default     = "api.venafi.cloud"
  description = "API Endpoint for the agent to send data to"
}

variable "vcp_private_registry" {
  type        = string
  default     = "private-registry.venafi.cloud"
  description = "Private registry URL for container images"
}

variable vcp_public_registry {
  type        = string
  default     = "registry.venafi.cloud"
  description = "Public registry URL for helm charts and public container images"
}

variable chart_version {
  type = string
  default = "v1.7.0"
  description = "Chart version for firefly helm release"
}

variable vcp_auth_secret {
  type        = string
  description = "Name of the kubernetes secret with VCP authentication credential"
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
