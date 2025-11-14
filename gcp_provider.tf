# Provider configuration for Google Cloud
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
}


provider "google" {
  project = var.host_project
  region  = var.deploy_region # e.g., us-central1
}

provider "google" {
  project = var.service_project
  region = var.deploy_region
  alias = "service-project"
}