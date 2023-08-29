resource "google_compute_network" "vpc" {
  name                    = "${var.app_name}-vpc"
  routing_mode            = "GLOBAL"
  auto_create_subnetworks = true
}

resource "google_compute_global_address" "private_ip_block" {
  name          = "${var.app_name}-ip-block"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  ip_version    = "IPV4"
  prefix_length = 20
  network       = google_compute_network.vpc.self_link
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.vpc.self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_block.name]
}