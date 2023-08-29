/*
 To be able to deploy from CI/CD pipeline
*/
resource "google_service_account" "github_sa" {
  account_id   = "registry"
  description  = "GitHub"
  display_name = "GitHub SA"
}

resource "google_storage_bucket_iam_binding" "binding" {
  role   = "roles/storage.admin"
  bucket = google_container_registry.registry.id
  members = [
    format("serviceAccount:%s", google_service_account.github_sa.email)
  ]
}

resource "google_project_iam_member" "default_compute_engine_secretmanager_secretaccessor" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:data.google_compute_default_service_account.compute_service_account.email"
}
