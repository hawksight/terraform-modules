// Configure default Terraform version and default providers
globals "terraform" {
  version = "1.10.5"
}

globals "terraform" "backend" "gcs" {
  bucket = "jetstack-pf-tofu-state"
}

globals "terraform" "providers" "google" {
  version = "~> 7.23"
}

globals "terraform" "providers" "kubernetes" {
  version = "~> 2.38.0"
}

globals "terraform" "providers" "helm" {
  version = "~> 2.17.0"
}

globals "terraform" "providers" "tls" {
  version = "~> 4.2.1"
}

globals "terraform" "providers" "tlspc" {
  version = "~> 0.5.0"
}

import {
  source = "../imports/generate_backend.tm.hcl"
}

import {
  source = "../imports/generate_providers.tm.hcl"
}