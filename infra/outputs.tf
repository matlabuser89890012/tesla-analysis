output "kubeconfig" {
  description = "Kubeconfig for the GKE cluster"
  value       = google_container_cluster.primary.kubeconfig_raw
}
