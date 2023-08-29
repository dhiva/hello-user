data "google_compute_default_service_account" "compute_service_account" {
}

resource "google_cloud_run_v2_service" "default" {
  name     = "${var.app_name}-service"
  location = var.region
  ingress = "INGRESS_TRAFFIC_ALL"

  service_account= data.google_compute_default_service_account.compute_service_account.email

  template {
    scaling {
      max_instance_count = 2
    }

    volumes {
      name = "cloudsql"
      cloud_sql_instance {
        instances = [google_sql_database_instance.main_primary.connection_name]
      }
    }

    containers {
      image = "gcr.io/hello-user/${var.app_name}:${var.app_version}"
      command = "gunicorn"
      args="main:api -c gunicorn_config.py"

      env {
        name = "APP_VERSION"
        value = var.app_version
      }
      env {
        name = "DATABASE_PASSWORD"
        value_source {
          secret_key_ref {
            secret = google_secret_manager_secret_version.database_password.secret_id
            version = "1"
          }
        }
      }

      env {
        name = "DATABASE_USERNAME"
        value_source {
          secret_key_ref {
            secret = google_secret_manager_secret_version.database_username.secret_id
            version = "1"
          }
        }
      }

      env {
        name = "DATABASE_HOST"
        value = google_dns_record_set.database.name
      }
      volume_mounts {
        name = "cloudsql"
        mount_path = "/cloudsql"
      }
    }
  }

  traffic {
    type = "TRAFFIC_TARGET_ALLOCATION_TYPE_REVISION"
    percent = 0
    tag = "green"
  }
  depends_on = [
    google_secret_manager_secret_version.database_password,
    google_secret_manager_secret_version.database_username
  ]
  lifecycle {
    ignore_changes = [
      traffic[0].percent,
      traffic[0].tag,
    ]
  }
}


resource "google_cloud_run_v2_job" "default" {
  name     = "${var.app_name}-job"
  location = "us-central1"

  template {
    template{
      volumes {
        name = "cloudsql"
        cloud_sql_instance {
          instances = [google_sql_database_instance.instance.connection_name]
        }
      }

      containers {
        image = "gcr.io/hello-user/${var.app_name}:${var.app_version}"
        command = "alembic"
        args="upgrade head"

        env {
        name = "APP_VERSION"
        value = var.app_version
      }
      env {
        name = "DATABASE_PASSWORD"
        value_source {
          secret_key_ref {
            secret = google_secret_manager_secret_version.database_password.secret_id
            version = "1"
          }
        }
      }

      env {
        name = "DATABASE_USERNAME"
        value_source {
          secret_key_ref {
            secret = google_secret_manager_secret_version.database_username.secret_id
            version = "1"
          }
        }
      }

      env {
        name = "DATABASE_HOST"
        value = google_dns_record_set.database.name
        }
        volume_mounts {
          name = "cloudsql"
          mount_path = "/cloudsql"
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [
      launch_stage,
    ]
  }
}

data "google_iam_policy" "noauth" {
  binding {
    role    = "roles/run.invoker"
    members = var.auth_members
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location    = google_cloud_run_v2_service.default.location
  project     = google_cloud_run_v2_service.default.project
  service     = google_cloud_run_v2_service.default.name
  policy_data = data.google_iam_policy.noauth.policy_data
}
