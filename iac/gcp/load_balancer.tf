# Create new IP address what can be assigned to load balancer.
resource "google_compute_global_address" "default" {
  project    = var.project_id
  name       = "${var.app_name}-address"
  ip_version = "IPV4"
}

# Generate GCP managed SSL certificates for the cloud run application subdomain
resource "google_compute_managed_ssl_certificate" "default" {
  provider = google-beta
  project  = var.project_id
  name     = "${var.app_name}-cert"

  managed {
    domains = [local.fqdn]
  }
}

# Proxy to redirect all HTTP requests to HTTPS endpoint
resource "google_compute_target_http_proxy" "default" {
  project = var.project_id
  name    = "${var.app_name}-http-proxy"
  url_map = google_compute_url_map.https_redirect.self_link
}

# HTTPS proxy to forward all HTTPS requests to load balancer backend
resource "google_compute_target_https_proxy" "default" {
  project          = var.project_id
  name             = "${var.app_name}-https-proxy"
  url_map          = google_compute_url_map.default.self_link
  ssl_certificates = google_compute_managed_ssl_certificate.default.self_link
  ssl_policy       = null
}

# Load balancer rule to forward all http requests to HTTPS
resource "google_compute_global_forwarding_rule" "http" {
  project    = var.project_id
  name       = var.name
  target     = google_compute_target_http_proxy.default.self_link
  ip_address = local.load_balancer_address
  port_range = "80"
}

# Load balancer rule to serve HTTPS request through load balancer backend
resource "google_compute_global_forwarding_rule" "https" {
  project    = var.project_id
  name       = "${var.app_name}-https"
  target     = google_compute_target_https_proxy.default.self_link
  ip_address = local.load_balancer_address
  port_range = "443"
}

resource "google_compute_url_map" "default" {
  project         = var.project_id
  name            = "${var.app_name}-url-map"
  default_service = google_compute_backend_service.default.id
}

resource "google_compute_url_map" "https_redirect" {
  project = var.project_id
  name    = "${var.app_name}-https-redirect"

  default_url_redirect {
    https_redirect         = true
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
    strip_query            = false
  }
}

# Created Network endpoint group for cloud run service
# The Serverless neg must be in same location as the cloud run
resource "google_compute_region_network_endpoint_group" "serverless_neg" {
  provider              = google-beta
  name                  = "${var.app_name}-serverless-neg"
  network_endpoint_type = "SERVERLESS"
  region                = var.location

  cloud_run {
    service = google_cloud_run_service.default.name
  }
}

resource "google_compute_backend_service" "default" {
  name    = "${var.app_name}-backend"
  project = var.project_id

  timeout_sec     = 30
  enable_cdn      = false
  protocol        = "HTTPS"

  backend {
    group = google_compute_region_network_endpoint_group.serverless_neg.id
  }

  log_config {
    enable      = true
    sample_rate = "1.0"
  }
}
