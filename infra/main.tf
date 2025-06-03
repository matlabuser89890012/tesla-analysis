provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_container_cluster" "primary" {
  name     = "tesla-cluster"
  location = var.region
  node_config {
    machine_type = "n1-standard-4"
    accelerators {
      accelerator_count = 1
      accelerator_type  = "nvidia-tesla-t4"
    }
  }
}

output "kubeconfig" {
  value = google_container_cluster.primary.kubeconfig_raw
}
