terraform {
  required_providers {
    tlspc = {
      source  = "jetstack/tlspc"
      version = "0.4.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.14.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.32.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "6.12.0"
    }
  }
}

provider "google" {
  project = var.gcp_project
  region  = var.gcp_region
  # credentials = file(pathexpand(var.gcp_svc_account_path))
}

provider "kubernetes" {
  host                   = "https://${google_container_cluster.default.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.default.master_auth[0].cluster_ca_certificate)

  ignore_annotations = [
    "^autopilot\\.gke\\.io\\/.*",
    "^cloud\\.google\\.com\\/.*"
  ]
}

provider "helm" {
  kubernetes {
    host                   = "https://${google_container_cluster.default.endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(google_container_cluster.default.master_auth[0].cluster_ca_certificate)

    # ignore_annotations = [
    #   "^autopilot\\.gke\\.io\\/.*",
    #   "^cloud\\.google\\.com\\/.*"
    # ]
  }
}

provider "tlspc" {
  apikey   = trimspace(var.vcp_api_key)
  endpoint = local.api_url
}
