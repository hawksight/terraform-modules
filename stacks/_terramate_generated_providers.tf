// TERRAMATE: GENERATED AUTOMATICALLY DO NOT EDIT

terraform {
  required_version = "1.10.5"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.17"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.38"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.2.1"
    }
    tlspc = {
      source  = "jetstack/tlspc"
      version = "~> 0.5"
    }
  }
}
