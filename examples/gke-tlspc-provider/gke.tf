# /**
# * Copyright 2024 Google LLC
# *
# * Licensed under the Apache License, Version 2.0 (the "License");
# * you may not use this file except in compliance with the License.
# * You may obtain a copy of the License at
# *
# *      http://www.apache.org/licenses/LICENSE-2.0
# *
# * Unless required by applicable law or agreed to in writing, software
# * distributed under the License is distributed on an "AS IS" BASIS,
# * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# * See the License for the specific language governing permissions and
# * limitations under the License.
# */

resource "google_compute_network" "default" {
  # Remove hard coded default for naming customisation
  name = "${var.gcp_cluster_name}-network"

  auto_create_subnetworks  = false
  enable_ula_internal_ipv6 = true
}

resource "google_compute_subnetwork" "default" {
  # Remove hard coded default for naming customisation
  name = "${var.gcp_cluster_name}-subnet"

  ip_cidr_range = "10.0.0.0/16"
  region        = var.gcp_region

  stack_type       = "IPV4_IPV6"
  ipv6_access_type = "INTERNAL" # Change to "EXTERNAL" if creating an external loadbalancer

  network = google_compute_network.default.id

  secondary_ip_range {
    range_name    = "services-range"
    ip_cidr_range = "192.168.0.0/24"
  }

  secondary_ip_range {
    range_name    = "pod-ranges"
    ip_cidr_range = "192.168.64.0/22"
  }
}

resource "google_container_cluster" "default" {
  name = var.gcp_cluster_name

  location                 = var.gcp_region
  enable_l4_ilb_subsetting = true

  network    = google_compute_network.default.id
  subnetwork = google_compute_subnetwork.default.id

  ip_allocation_policy {
    cluster_secondary_range_name  = "pod-ranges"
    services_secondary_range_name = google_compute_subnetwork.default.secondary_ip_range.0.range_name
  }

  # Removes the implicit default node pool, recommended when using
  # google_container_node_pool.
  remove_default_node_pool = true
  initial_node_count       = 1

  deletion_protection = false
}

resource "google_service_account" "nodes" {
  account_id   = "${var.gcp_cluster_name}-nodes"
  display_name = "GKE Node service account"
}


# Small Linux node pool to run some Linux-only Kubernetes Pods.
resource "google_container_node_pool" "pool-1" {
  name     = "${var.gcp_cluster_name}-pool-1"
  project  = google_container_cluster.default.project
  cluster  = google_container_cluster.default.name
  location = google_container_cluster.default.location

  # node_count = 2
  autoscaling {
    min_node_count = 0
    max_node_count = 4
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_locations = [
    "${var.gcp_zone}",
  ]

  node_config {
    image_type   = "COS_CONTAINERD"
    preemptible  = true
    machine_type = "e2-medium"

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.nodes.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}