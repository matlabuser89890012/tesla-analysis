resource "google_container_registry" "default" {
  project = var.project_id
}

output "registry_url" {
  value = "gcr.io/${var.project_id}"
}
