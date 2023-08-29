resource "random_id" "database_suffix" {
  byte_length = 4
}

resource "google_sql_database" "main" {
  name     = var.sql_database_name
  instance = google_sql_database_instance.main_primary.name
}

resource "google_sql_user" "db_user" {
  depends_on = [
    google_sql_database.main,
    google_sql_database_instance.read_replica,
    google_secret_manager_secret_version.database_password,
    google_secret_manager_secret_version.database_username
  ]

  name     = data.google_secret_manager_secret_version.database_username.secret_data
  instance = google_sql_database_instance.main_primary.name
  password = data.google_secret_manager_secret_version.database_password.secret_data
}

resource "google_sql_database_instance" "main_primary" {
  depends_on = [
    google_service_networking_connection.private_vpc_connection
  ]

  name                = "${var.sql_database_name}-primary-${random_id.database_suffix.hex}"
  database_version    = "MYSQL_8_0"
  region              = var.region
  deletion_protection = false

  settings {
    tier              = "db-f1-micro"
    availability_type = "REGIONAL"
    disk_size         = 10

    ip_configuration {
      ipv4_enabled    = true
      private_network = google_compute_network.vpc.self_link
    }
  }
}

resource "google_sql_database_instance" "read_replica" {
  name                 = "${var.sql_database_name}-replica-${random_id.database_suffix.hex}"
  master_instance_name = google_sql_database_instance.main_primary.name
  database_version     = "MYSQL_8_0"
  region               = var.region
  deletion_protection  = false

  replica_configuration {
    failover_target = false
  }

  settings {
    tier              = "db-f1-micro"
    availability_type = "ZONAL"
    disk_size         = 10

    backup_configuration {
      enabled = false
    }

    ip_configuration {
      ipv4_enabled    = true
      private_network = google_compute_network.vpc.self_link
    }
  }
}