resource "google_dns_managed_zone" "zone-ext" {
  name     = "com-ext-${var.region}-${var.app_name}"
  dns_name = "${var.region}.ext.hellworld.com."
}

resource "google_dns_managed_zone" "zone-int" {
  name     = "com-int-${var.region}-${var.app_name}"
  dns_name = "${var.region}.int.hellworld.com."
}

resource "google_dns_record_set" "database" {
  name = "database0.${data.google_dns_managed_zone.zone_int.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = google_dns_managed_zone.zone_int.name

  rrdatas = [google_sql_database_instance.main_primary.private_ip_address]
}

# Create A record pointing to HTTPS load balancer created for the cloud run
resource "google_dns_record_set" "a" {
  name  = "app.${data.google_dns_managed_zone.zone-ext.dns_name}"
  type  = "A"
  ttl   = 43200

  managed_zone = data.google_dns_managed_zone.zone-ext.name

  rrdatas = [ google_compute_global_address.default.address]
}
