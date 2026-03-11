generate_hcl "_terramate_generated_providers.tf" {
  content {
    terraform {
      required_version = global.terraform.version

      required_providers {
        tls = {
          source  = "hashicorp/tls"
          version = global.terraform.providers.tls.version
        }
        tlspc = {
          source  = "jetstack/tlspc"
          version = global.terraform.providers.tlspc.version
        }
        google = {
          source  = "hashicorp/google"
          version = global.terraform.providers.google.version
        }
        kubernetes = {
          source  = "hashicorp/kubernetes"
          version = global.terraform.providers.kubernetes.version
        }
        helm = {
          source  = "hashicorp/helm"
          version = global.terraform.providers.helm.version
        }
      }
    }
  }
}