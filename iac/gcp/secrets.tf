resource "google_secret_manager_secret_iam_member" "secret_access" {
  secret_id = google_secret_manager_secret.secret.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com"
  depends_on = [google_secret_manager_secret.secret]
}

resource "google_secret_manager_secret" "database_username" {
  secret_id = "${var.app_name}-database-username"

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "database_username" {
  secret      = google_secret_manager_secret.database_username.id
  secret_data = "${var.app_name}-user"
}

resource "google_secret_manager_secret" "database_password" {
  secret_id = "${var.app_name}-database-password"

  replication {
    automatic = true
  }
}

resource "random_password" "database_password" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=<>?"
  min_lower = 1
  min_upper = 1
  min_numeric = 1
}

resource "google_secret_manager_secret_version" "database_password" {
  secret      = google_secret_manager_secret.database_password.id
  secret_data = random_password.database_password.result
}
