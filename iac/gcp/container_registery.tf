data "google_client_config" "current" {}

resource "google_container_registry" "registry" {
  project  = data.google_client_config.current.project
  location = "EU"
}