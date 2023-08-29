resource "google_project_service" "apis" {
  for_each                   = toset(local.apis)
  service                    = each.key
  disable_dependent_services = false
}