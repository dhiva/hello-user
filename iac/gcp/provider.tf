terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5.1"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 4.80.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 4.80.0"
    }
  }
  required_version = ">= 1.5.6"
  backend "gcs" {}
}


provider "google" {
  project = var.project
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}