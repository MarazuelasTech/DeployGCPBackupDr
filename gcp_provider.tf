# Provider configuration for Google Cloud
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.10, < 8"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 6.10, < 8"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.1"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.9.1"
    }
    http = {
      source  = "hashicorp/http"
      version = ">= 3.4.0"
    }
  }
  provider_meta "google" {
    module_name = "blueprints/terraform/terraform-google-backup-dr/v0.5.0"
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