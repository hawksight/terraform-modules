variable "vcp_firefly_name" {
  type        = string
  default     = "firefly"
  description = "String name for the firefly installation"
}

// TODO: Pass more that one person into the team
# variable vcp_team_users {
#   type        = list(string)
#   description = "A list of users to assign to the "
# }

variable "vcp_team_owner_email" {
  type        = string
  description = "Input an email for the VCP identity you would like to own the VCP Team created"
}

variable "vcp_team_name" {
  type        = string
  description = "Provide a name to the team owning this firefly installation"
}

// TODO: Not possible to lookup team IDs without creating - https://github.com/jetstack/terraform-provider-tlspc/issues/87
variable "vcp_existing_team" {
  type        = bool
  default     = false
  description = "Set to true if the team name already exists to prevent an additional team being created"
}

variable "vcp_namespace" {
  type        = string
  default     = "venafi"
  description = "Set the installation namespace of the firefly in cluster resource dependencies"
}

variable "vcp_sa_private_key" {
  type        = string
  sensitive   = true
  default     = ""
  description = "Optionally provide a pubprivate key for the service account, else one is generated on your behalf. See here for more details: https://docs.venafi.cloud/firefly/service-accounts/"
}

variable "vcp_sa_public_key" {
  type        = string
  default     = ""
  description = "Optionally provide a public key for the service account, else one is generated on your behalf. See here for more details: https://docs.venafi.cloud/firefly/service-accounts/"
}

variable "vcp_certificate_authority" {
  type = map(string)
  default = {
    type           = "BUILTIN"
    ca_name        = "Built-In CA"
    product_option = "Default Product"
  }
  description = "Set the Certifiate Authority properties from wich the subca will issue"
}
