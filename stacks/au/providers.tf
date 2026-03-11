provider "google" {
  project = var.gcp_project
  region  = var.gcp_region
  # credentials = file(pathexpand(var.gcp_svc_account_path))
}

provider "kubernetes" {
  host                   = "https://${module.gke.cluster_endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.cluster_certificate)

  ignore_annotations = [
    "^autopilot\\.gke\\.io\\/.*",
    "^cloud\\.google\\.com\\/.*"
  ]
}

provider "helm" {
  kubernetes {
    host                   = "https://${module.gke.cluster_endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(module.gke.cluster_certificate)
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
