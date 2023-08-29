variable "GOOGLE_CREDENTIALS" {
  description = "Needs to be present to suppress TF warning of unused vars"
}

variable "project_id" {
  description = "Target GCP Project ID"
}

variable "region" {description = "GCP region to be deployed"}

variable "app_name" {
  description = "Name of Cloud run app"
  default = "hello-user"
}
variable "app_version" {
  description = "Version to deploy"
  default     = "latest"
}


variable "sql_database_name" {default = "hello-user-db"}